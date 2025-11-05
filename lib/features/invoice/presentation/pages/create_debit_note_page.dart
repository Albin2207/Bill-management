import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/document_constants.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/widgets/document_details_dialog.dart';
import '../../../../core/widgets/export_section_widget.dart';
import '../../../../core/widgets/customer_selection_widget.dart';
import '../../../../core/widgets/invoice_items_widget.dart';
import '../../../../core/widgets/optional_sections_widget.dart';
import '../../../../core/models/invoice_item.dart';
import '../../../party/presentation/providers/party_provider.dart';
import '../../../party/domain/entities/party_entity.dart';
import '../../../product/presentation/providers/product_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/invoice_provider.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/invoice_item_entity.dart';

class CreateDebitNotePage extends StatefulWidget {
  const CreateDebitNotePage({super.key});

  @override
  State<CreateDebitNotePage> createState() => _CreateDebitNotePageState();
}

class _CreateDebitNotePageState extends State<CreateDebitNotePage> {
  // Document Details
  String _prefix = DocumentConstants.debitNotePrefixes.first;
  String _documentNumber = '';
  DateTime _documentDate = DateTime.now();
  DateTime? _dueDate;
  String _documentTitle = 'Debit Note';
  double _discount = 0;
  String _discountType = DocumentConstants.discountTypes.first;
  
  // Export Data
  Map<String, dynamic>? _exportData;
  
  // Supplier
  PartyEntity? _selectedSupplier;
  
  // Items (products being credited back)
  List<InvoiceItem> _items = [];
  
  // Optional Data
  Map<String, dynamic> _optionalData = {};

  // Reason for debit note
  final TextEditingController _reasonController = TextEditingController(
    text: 'Goods returned to supplier/Price correction',
  );

  @override
  void initState() {
    super.initState();
    _documentNumber = _generateDocumentNumber();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final partyProvider = Provider.of<PartyProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    final userId = authProvider.user?.uid;
    if (userId != null) {
      partyProvider.loadParties(userId);
      productProvider.loadProducts(userId);
    }
  }

  String _generateDocumentNumber() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}001';
  }

  void _showDocumentDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) => DocumentDetailsDialog(
        prefix: _prefix,
        documentNumber: _documentNumber,
        documentDate: _documentDate,
        dueDate: _dueDate,
        documentTitle: _documentTitle,
        discount: _discount,
        discountType: _discountType,
        prefixOptions: DocumentConstants.debitNotePrefixes,
        showDueDate: false, // Debit notes don't usually have due dates
        onSave: (data) {
          setState(() {
            _prefix = data['prefix'];
            _documentNumber = data['documentNumber'];
            _documentDate = data['documentDate'];
            _documentTitle = data['documentTitle'];
            _discount = data['discount'];
            _discountType = data['discountType'];
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  double _calculateSubtotal() {
    return _items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  double _calculateTotalDiscount() {
    final itemDiscounts = _items.fold(0.0, (sum, item) => sum + item.discountAmount);
    final docDiscount = _discountType == 'Percentage (%)'
        ? _calculateSubtotal() * (_discount / 100)
        : _discount;
    final extraDiscount = _optionalData['extraDiscountType'] == 'Percentage (%)'
        ? _calculateSubtotal() * ((double.tryParse(_optionalData['extraDiscount']?.toString() ?? '0') ?? 0) / 100)
        : (double.tryParse(_optionalData['extraDiscount']?.toString() ?? '0') ?? 0);
    return itemDiscounts + docDiscount + extraDiscount;
  }

  double _calculateTotalTax() {
    return _items.fold(0.0, (sum, item) => sum + item.taxAmount);
  }

  double _calculateAdditionalCharges() {
    return (double.tryParse(_optionalData['deliveryCharges']?.toString() ?? '0') ?? 0) +
           (double.tryParse(_optionalData['shippingCharges']?.toString() ?? '0') ?? 0) +
           (double.tryParse(_optionalData['packagingCharges']?.toString() ?? '0') ?? 0);
  }

  double _calculateGrandTotal() {
    return _calculateSubtotal() - _calculateTotalDiscount() + _calculateTotalTax() + _calculateAdditionalCharges();
  }

  Future<void> _saveDebitNote() async {
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a supplier')),
      );
      return;
    }
    
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    final userId = authProvider.user?.uid;
    if (userId == null) return;

    // Convert InvoiceItem to InvoiceItemEntity
    final invoiceItems = _items.map((item) {
      final taxableAmount = item.amountAfterDiscount;
      final taxAmount = item.taxAmount;
      
      final isInterState = _selectedSupplier!.state != null && 
                           _selectedSupplier!.state != 'Your State';
      
      return InvoiceItemEntity(
        productId: item.product.id!,
        productName: item.product.name,
        hsnCode: item.product.hsnCode,
        quantity: item.quantity,
        unit: item.product.unit.name,
        rate: item.rate,
        discount: item.discount,
        gstRate: item.taxRate,
        cgst: isInterState ? null : taxAmount / 2,
        sgst: isInterState ? null : taxAmount / 2,
        igst: isInterState ? taxAmount : null,
        taxableAmount: taxableAmount,
        totalAmount: item.total,
      );
    }).toList();

    final subtotal = _calculateSubtotal();
    final totalDiscount = _calculateTotalDiscount();
    final totalTax = _calculateTotalTax();
    final grandTotal = _calculateGrandTotal();
    
    final isInterState = _selectedSupplier!.state != null && 
                         _selectedSupplier!.state != 'Your State';

    final debitNote = InvoiceEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      invoiceNumber: '$_prefix-$_documentNumber',
      invoiceType: InvoiceType.debitNote,
      invoiceDate: _documentDate,
      dueDate: null, // Debit notes don't have due dates
      partyId: _selectedSupplier!.id!,
      partyName: _selectedSupplier!.name,
      partyGstin: _selectedSupplier!.gstin,
      partyAddress: _selectedSupplier!.address,
      partyCity: _selectedSupplier!.city,
      partyState: _selectedSupplier!.state,
      partyPhone: _selectedSupplier!.phoneNumber,
      items: invoiceItems,
      subtotal: subtotal,
      totalDiscount: totalDiscount,
      taxableAmount: subtotal - totalDiscount,
      cgst: isInterState ? 0 : totalTax / 2,
      sgst: isInterState ? 0 : totalTax / 2,
      igst: isInterState ? totalTax : 0,
      totalTax: totalTax,
      grandTotal: grandTotal,
      paymentStatus: PaymentStatus.pending,
      paidAmount: 0,
      balanceAmount: grandTotal,
      notes: _reasonController.text.isNotEmpty 
          ? 'Reason: ${_reasonController.text}\n${_optionalData['notes'] ?? ''}'
          : _optionalData['notes'],
      termsAndConditions: _optionalData['terms'],
      isInterState: isInterState,
      userId: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save debit note
    final success = await invoiceProvider.addInvoice(debitNote);

    if (!mounted) return;

    if (success) {
      // DEDUCT stock (opposite of credit note - debit DECREASES stock when returning to supplier)
      for (final item in _items) {
        if (item.product.trackStock && item.product.id != null) {
          final updatedProduct = item.product.copyWith(
            stock: item.product.stock - item.quantity, // DEDUCT from stock (returning to supplier)
            updatedAt: DateTime.now(),
          );
          await productProvider.updateProduct(updatedProduct);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debit Note saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(invoiceProvider.errorMessage ?? 'Failed to save debit note'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final partyProvider = Provider.of<PartyProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    
    final suppliers = partyProvider.parties.where((p) => 
      p.partyType == PartyType.vendor || p.partyType == PartyType.both
    ).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Debit Note'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDebitNote,
            tooltip: 'Save Debit Note',
          ),
        ],
      ),
      body: Column(
        children: [
          // Info Banner
          Container(
            color: Colors.pink.shade50,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.pink.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Debit Note reduces your payables when returning goods to supplier.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.pink.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Document Details
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Document Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: _showDocumentDetailsDialog,
                                tooltip: 'Edit Document Details',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('Title: $_documentTitle'),
                          Text('Number: $_prefix-$_documentNumber'),
                          Text('Date: ${DateFormat('dd MMM yyyy').format(_documentDate)}'),
                          if (_discount > 0)
                            Text('Discount: $_discount $_discountType'),
                        ],
                      ),
                    ),
                  ),
                  
                  // Reason for Debit Note
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reason for Debit Note',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _reasonController,
                            decoration: const InputDecoration(
                              labelText: 'Reason',
                              border: OutlineInputBorder(),
                              hintText: 'e.g., Damaged goods, Quality issue',
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Export Section
                  ExportSectionWidget(
                    isExport: _exportData != null,
                    exportData: _exportData,
                    onChanged: (data) {
                      setState(() {
                        _exportData = data;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Select Supplier
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Select Supplier',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.pushNamed(context, AppRouter.addParty);
                                  if (result == true && mounted) {
                                    _loadData();
                                  }
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add Supplier'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_selectedSupplier == null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.store, color: Colors.grey.shade400),
                                  const SizedBox(width: 12),
                                  Text(
                                    'No supplier selected',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.pink.shade50,
                                border: Border.all(color: Colors.pink.shade200),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.pink,
                                    child: Text(
                                      _selectedSupplier!.name[0].toUpperCase(),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedSupplier!.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (_selectedSupplier!.phoneNumber != null)
                                          Text(
                                            _selectedSupplier!.phoneNumber!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        _selectedSupplier = null;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          if (suppliers.isNotEmpty && _selectedSupplier == null) ...[
                            const SizedBox(height: 12),
                            DropdownButtonFormField<PartyEntity>(
                              decoration: const InputDecoration(
                                labelText: 'Choose Supplier',
                                border: OutlineInputBorder(),
                              ),
                              items: suppliers.map((supplier) {
                                return DropdownMenuItem(
                                  value: supplier,
                                  child: Text(supplier.name),
                                );
                              }).toList(),
                              onChanged: (supplier) {
                                setState(() {
                                  _selectedSupplier = supplier;
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Credit Note Items
                  InvoiceItemsWidget(
                    items: _items,
                    products: productProvider.products,
                    invoiceType: InvoiceType.debitNote, // Debit Note
                    onItemsChanged: (items) {
                      setState(() {
                        _items = items;
                      });
                    },
                    onAddNewProduct: () async {
                      final result = await Navigator.pushNamed(context, AppRouter.addProduct);
                      if (result == true && mounted) {
                        _loadData();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Optional Sections
                  OptionalSectionsWidget(
                    optionalData: _optionalData,
                    onDataChanged: (data) {
                      setState(() {
                        _optionalData = data;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Totals Summary
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildTotalRow('Subtotal', _calculateSubtotal()),
                          _buildTotalRow('Discount', _calculateTotalDiscount(), isNegative: true),
                          const Divider(),
                          _buildTotalRow('Taxable Amount', _calculateSubtotal() - _calculateTotalDiscount()),
                          _buildTotalRow('Total Tax', _calculateTotalTax()),
                          _buildTotalRow('Additional Charges', _calculateAdditionalCharges()),
                          const Divider(height: 24),
                          _buildTotalRow('Debit Amount', _calculateGrandTotal(), isBold: true, isCredit: true),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Fixed bottom bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isBold = false, bool isNegative = false, bool isCredit = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 18 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isCredit ? Colors.red : (isNegative ? Colors.red : AppColors.onBackground),
            ),
          ),
          Text(
            '${isNegative ? '-' : ''}₹${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isBold ? 20 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isCredit ? Colors.red : (isNegative ? Colors.red : AppColors.onBackground),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Debit Amount',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.onBackground.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '-₹${_calculateGrandTotal().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _saveDebitNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save Debit Note',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

