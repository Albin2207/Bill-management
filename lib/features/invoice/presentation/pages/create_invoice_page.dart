import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class CreateInvoicePage extends StatefulWidget {
  const CreateInvoicePage({super.key});

  @override
  State<CreateInvoicePage> createState() => _CreateInvoicePageState();
}

class _CreateInvoicePageState extends State<CreateInvoicePage> {
  // Document Details
  String _prefix = DocumentConstants.invoicePrefixOptions.first;
  String _documentNumber = '';
  DateTime _documentDate = DateTime.now();
  DateTime? _dueDate;
  String _documentTitle = 'Tax Invoice';
  double _discount = 0;
  String _discountType = DocumentConstants.discountTypes.first;
  
  // Export Data
  Map<String, dynamic>? _exportData;
  
  // Customer
  PartyEntity? _selectedCustomer;
  
  // Items
  List<InvoiceItem> _items = [];
  
  // Optional Data
  Map<String, dynamic> _optionalData = {};

  @override
  void initState() {
    super.initState();
    _documentNumber = _generateDocumentNumber();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final partyProvider = Provider.of<PartyProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    final userId = authProvider.user?.uid;
    debugPrint('Loading data for user: $userId');
    if (userId != null) {
      partyProvider.loadParties(userId);
      productProvider.loadProducts(userId);
      debugPrint('Load initiated - Parties: ${partyProvider.parties.length}, Products: ${productProvider.products.length}');
    } else {
      debugPrint('No user ID found!');
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
        prefixOptions: DocumentConstants.invoicePrefixOptions,
        showDueDate: true,
        onSave: (data) {
          setState(() {
            _prefix = data['prefix'];
            _documentNumber = data['documentNumber'];
            _documentDate = data['documentDate'];
            _dueDate = data['dueDate'];
            _documentTitle = data['documentTitle'];
            _discount = data['discount'];
            _discountType = data['discountType'];
          });
        },
      ),
    );
  }

  double _calculateSubtotal() {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
  }

  double _calculateTotalDiscount() {
    double itemsDiscount = _items.fold(0, (sum, item) => sum + item.discountAmount);
    double docDiscount = _discount;
    double extraDiscount = _optionalData['extraDiscount'] ?? 0;
    return itemsDiscount + docDiscount + extraDiscount;
  }

  double _calculateTotalTax() {
    return _items.fold(0, (sum, item) => sum + item.taxAmount);
  }

  double _calculateAdditionalCharges() {
    double delivery = _optionalData['deliveryCharges'] ?? 0;
    double shipping = _optionalData['shippingCharges'] ?? 0;
    double packaging = _optionalData['packagingCharges'] ?? 0;
    return delivery + shipping + packaging;
  }

  double _calculateGrandTotal() {
    return _calculateSubtotal() - _calculateTotalDiscount() + _calculateTotalTax() + _calculateAdditionalCharges();
  }

  Future<void> _saveInvoice() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer')),
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
      final subtotal = item.subtotal;
      final discountAmount = item.discountAmount;
      final taxableAmount = item.amountAfterDiscount;
      final taxAmount = item.taxAmount;
      
      // Calculate GST breakdown based on customer state
      final isInterState = _selectedCustomer!.state != null && 
                           _selectedCustomer!.state != 'Your State'; // TODO: Get business state
      
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

    // Calculate totals
    final subtotal = _calculateSubtotal();
    final totalDiscount = _calculateTotalDiscount();
    final totalTax = _calculateTotalTax();
    final grandTotal = _calculateGrandTotal();
    
    final isInterState = _selectedCustomer!.state != null && 
                         _selectedCustomer!.state != 'Your State'; // TODO: Get business state

    final invoice = InvoiceEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      invoiceNumber: '$_prefix-$_documentNumber',
      invoiceType: InvoiceType.invoice,
      invoiceDate: _documentDate,
      dueDate: _dueDate,
      partyId: _selectedCustomer!.id!,
      partyName: _selectedCustomer!.name,
      partyGstin: _selectedCustomer!.gstin,
      partyAddress: _selectedCustomer!.address,
      partyCity: _selectedCustomer!.city,
      partyState: _selectedCustomer!.state,
      partyPhone: _selectedCustomer!.phoneNumber,
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
      notes: _optionalData['notes'],
      termsAndConditions: _optionalData['terms'],
      isInterState: isInterState,
      userId: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save invoice
    final success = await invoiceProvider.addInvoice(invoice);

    if (!mounted) return;

    if (success) {
      // Deduct stock for each item
      for (final item in _items) {
        if (item.product.trackStock && item.product.id != null) {
          final updatedProduct = item.product.copyWith(
            stock: item.product.stock - item.quantity,
            updatedAt: DateTime.now(),
          );
          await productProvider.updateProduct(updatedProduct);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invoice saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(invoiceProvider.errorMessage ?? 'Failed to save invoice'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final partyProvider = Provider.of<PartyProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    
    final customers = partyProvider.parties.where((p) => 
      p.partyType == PartyType.customer || p.partyType == PartyType.both
    ).toList();
    
    // Debug: Print product count
    debugPrint('Products available: ${productProvider.products.length}');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Invoice'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Preview invoice
            },
            icon: const Icon(Icons.visibility),
            tooltip: 'Preview',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Document Details Card
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
                              'Document Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              onPressed: _showDocumentDetailsDialog,
                              icon: const Icon(Icons.edit),
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                        const Divider(),
                        _buildDetailRow('Number', '$_prefix-$_documentNumber'),
                        _buildDetailRow('Title', _documentTitle),
                        _buildDetailRow('Date', _formatDate(_documentDate)),
                        if (_dueDate != null)
                          _buildDetailRow('Due Date', _formatDate(_dueDate!)),
                        if (_discount > 0)
                          _buildDetailRow('Discount', '$_discount ${_discountType == "Percentage (%)" ? "%" : "₹"}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
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
                
                // Customer Selection
                CustomerSelectionWidget(
                  selectedCustomer: _selectedCustomer,
                  customers: customers,
                  onCustomerSelected: (customer) {
                    setState(() {
                      _selectedCustomer = customer;
                    });
                  },
                  onAddNew: () {
                    Navigator.pushNamed(context, AppRouter.addParty);
                  },
                ),
                const SizedBox(height: 16),
                
                  // Invoice Items
                  InvoiceItemsWidget(
                    items: _items,
                    products: productProvider.products,
                    invoiceType: InvoiceType.invoice, // Sales Invoice
                    onItemsChanged: (items) {
                      setState(() {
                        _items = items;
                      });
                    },
                    onAddNewProduct: () async {
                    final result = await Navigator.pushNamed(context, AppRouter.addProduct);
                    // Reload products after adding new one
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
                const SizedBox(height: 100), // Space for bottom summary
              ],
            ),
          ),
          
          // Bottom Summary & Actions
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Grand Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${_calculateGrandTotal().toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Save as draft
                            },
                            icon: const Icon(Icons.save),
                            label: const Text('Save Draft'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _saveInvoice,
                            icon: const Icon(Icons.check),
                            label: const Text('Save Invoice'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
