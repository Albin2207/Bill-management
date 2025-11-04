import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/services/share_service.dart';
import '../../domain/entities/invoice_entity.dart';
import '../providers/invoice_provider.dart';
import '../widgets/payment_reminder_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/presentation/providers/document_settings_provider.dart';
import '../../../product/presentation/providers/product_provider.dart';
import '../../../payment/presentation/providers/payment_provider.dart';
import '../../../payment/domain/entities/payment_entity.dart';
import '../../../payment/data/models/payment_model.dart';
import '../../../payment/presentation/widgets/payment_section_widget.dart';

class InvoiceDetailPage extends StatefulWidget {
  final InvoiceEntity invoice;

  const InvoiceDetailPage({super.key, required this.invoice});

  @override
  State<InvoiceDetailPage> createState() => _InvoiceDetailPageState();
}

class _InvoiceDetailPageState extends State<InvoiceDetailPage> {
  List<PaymentEntity> _payments = [];
  bool _isLoadingPayments = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    final payments = await paymentProvider.getPaymentsByDocument(widget.invoice.id);
    setState(() {
      _payments = payments;
      _isLoadingPayments = false;
    });
  }

  Future<void> _handlePaymentAdded(BuildContext context, PaymentEntity payment) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    
    // Set user ID
    final updatedPayment = PaymentModel.fromEntity(payment).copyWith(
      userId: authProvider.user!.uid,
    );
    
    // Add payment
    final success = await paymentProvider.addPayment(updatedPayment);
    
    if (success) {
      // Reload payments
      await _loadPayments();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment recorded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to record payment: ${paymentProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            onPressed: () {
              _showStatusOptions(context);
            },
            icon: const Icon(Icons.more_vert),
            tooltip: 'More Options',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Payment Reminder (if applicable)
            PaymentReminderWidget(
              invoice: widget.invoice,
              onSendReminder: () => _sendPaymentReminder(context),
            ),
            
            // Invoice Document View
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TAX INVOICE',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.invoice.invoiceNumber,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(widget.invoice.paymentStatus),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.invoice.paymentStatus.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  
                  // Dates
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Invoice Date',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              DateFormat('dd MMM yyyy').format(widget.invoice.invoiceDate),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.invoice.dueDate != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Due Date',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                DateFormat('dd MMM yyyy').format(widget.invoice.dueDate!),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const Divider(height: 32),
                  
                  // Customer Details
                  Text(
                    'Bill To',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.invoice.partyName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (widget.invoice.partyGstin != null) ...[
                    const SizedBox(height: 4),
                    Text('GSTIN: ${widget.invoice.partyGstin}'),
                  ],
                  if (widget.invoice.partyAddress != null) ...[
                    const SizedBox(height: 4),
                    Text(widget.invoice.partyAddress!),
                  ],
                  if (widget.invoice.partyCity != null || widget.invoice.partyState != null) ...[
                    const SizedBox(height: 4),
                    Text('${widget.invoice.partyCity ?? ''} ${widget.invoice.partyState ?? ''}'),
                  ],
                  if (widget.invoice.partyPhone != null) ...[
                    const SizedBox(height: 4),
                    Text('Phone: ${widget.invoice.partyPhone}'),
                  ],
                  const Divider(height: 32),
                  
                  // Items Table
                  Text(
                    'Items',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.invoice.items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Column(
                      children: [
                        if (index > 0) const Divider(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'HSN: ${item.hsnCode}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.quantity} ${item.unit} × ₹${item.rate.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${item.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  'GST ${item.gstRate}%',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  }).toList(),
                  const Divider(height: 32),
                  
                  // Totals
                  _buildTotalRow('Subtotal', widget.invoice.subtotal),
                  if (widget.invoice.totalDiscount > 0)
                    _buildTotalRow('Discount', -widget.invoice.totalDiscount, isDiscount: true),
                  _buildTotalRow('Taxable Amount', widget.invoice.taxableAmount),
                  if (widget.invoice.cgst > 0) ...[
                    _buildTotalRow('CGST', widget.invoice.cgst),
                    _buildTotalRow('SGST', widget.invoice.sgst),
                  ],
                  if (widget.invoice.igst > 0)
                    _buildTotalRow('IGST', widget.invoice.igst),
                  const Divider(height: 24),
                  _buildTotalRow('Grand Total', widget.invoice.grandTotal, isBold: true),
                  
                  if (widget.invoice.notes != null) ...[
                    const Divider(height: 32),
                    Text(
                      'Notes',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(widget.invoice.notes!),
                  ],
                  
                  if (widget.invoice.termsAndConditions != null) ...[
                    const Divider(height: 32),
                    Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(widget.invoice.termsAndConditions!),
                  ],
                ],
              ),
            ),
            
            // Payment Section
            if (!_isLoadingPayments)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PaymentSectionWidget(
                  invoice: widget.invoice,
                  payments: _payments,
                  onPaymentAdded: (payment) => _handlePaymentAdded(context, payment),
                  onRefresh: _loadPayments,
                ),
              ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
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
          child:             Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareInvoice(context),
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadPDF(context),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Download PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isDiscount = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.red : Colors.black,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isBold ? 18 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isDiscount ? Colors.red : (isBold ? AppColors.primary : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Mark as Paid'),
              onTap: () {
                Navigator.pop(context);
                _updateStatus(context, PaymentStatus.paid);
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.orange),
              title: const Text('Mark as Pending'),
              onTap: () {
                Navigator.pop(context);
                _updateStatus(context, PaymentStatus.pending);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Mark as Unpaid'),
              onTap: () {
                Navigator.pop(context);
                _updateStatus(context, PaymentStatus.unpaid);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.grey),
              title: const Text('Cancel Invoice'),
              onTap: () {
                Navigator.pop(context);
                _confirmCancel(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: const Text('Share Invoice'),
              onTap: () {
                Navigator.pop(context);
                _shareInvoice(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Download PDF'),
              onTap: () {
                Navigator.pop(context);
                _downloadPDF(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.print, color: Colors.purple),
              title: const Text('Print Invoice'),
              onTap: () {
                Navigator.pop(context);
                _printInvoice(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateStatus(BuildContext context, PaymentStatus newStatus) async {
    debugPrint('🔵 _updateStatus called');
    debugPrint('   Document: ${widget.invoice.invoiceType.name} - ${widget.invoice.invoiceNumber}');
    debugPrint('   Current status: ${widget.invoice.paymentStatus.name}');
    debugPrint('   New status: ${newStatus.name}');
    
    // GET ALL PROVIDERS AT THE START - before any async operations!
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    debugPrint('   ✓ Providers captured successfully');
    
    // Calculate paid amount based on status
    double paidAmount = 0;
    if (newStatus == PaymentStatus.paid) {
      paidAmount = widget.invoice.grandTotal;
    } else if (newStatus == PaymentStatus.partial) {
      // TODO: Show dialog to enter partial amount
      paidAmount = widget.invoice.grandTotal / 2; // Default to 50%
    }

    // Handle stock restoration when cancelling
    final shouldRestoreStock = newStatus == PaymentStatus.cancelled && 
                                widget.invoice.paymentStatus != PaymentStatus.cancelled;
    
    debugPrint('   Should restore stock? $shouldRestoreStock');
    debugPrint('   Reason: newStatus==cancelled? ${newStatus == PaymentStatus.cancelled}');
    debugPrint('   Reason: currentStatus!=cancelled? ${widget.invoice.paymentStatus != PaymentStatus.cancelled}');
    
    debugPrint('   Calling updateInvoiceStatus...');
    final success = await invoiceProvider.updateInvoiceStatus(
      widget.invoice.id,
      newStatus,
      paidAmount,
    );

    debugPrint('   Update success: $success');

    if (success) {
      // Restore stock if invoice is being cancelled (DO THIS FIRST, before checking context)
      if (shouldRestoreStock) {
        debugPrint('   ✅ Calling _restoreStock now...');
        // Use auth provider we captured at the start
        await _restoreStock(authProvider, productProvider);
      } else {
        debugPrint('   ⏭️ Skipping stock restoration');
      }
      
      // NOW check if context is still mounted before showing UI
      if (!context.mounted) {
        debugPrint('   ⚠️ Context unmounted, skipping UI updates');
        return;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice marked as ${newStatus.name}${shouldRestoreStock ? ' (Stock restored)' : ''}'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Return to list
    } else {
      if (!context.mounted) {
        debugPrint('   ⚠️ Context unmounted, skipping error message');
        return;
      }
      
      debugPrint('   ❌ Update failed: ${invoiceProvider.errorMessage}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(invoiceProvider.errorMessage ?? 'Failed to update status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _restoreStock(AuthProvider authProvider, ProductProvider productProvider) async {
    debugPrint('🔄 _restoreStock called for ${widget.invoice.invoiceType.name} - ${widget.invoice.invoiceNumber}');
    debugPrint('📦 Items count: ${widget.invoice.items.length}');
    
    // Skip documents that don't affect stock
    if (widget.invoice.invoiceType == InvoiceType.proFormaInvoice ||
        widget.invoice.invoiceType == InvoiceType.quotation ||
        widget.invoice.invoiceType == InvoiceType.expense ||
        widget.invoice.invoiceType == InvoiceType.indirectIncome) {
      debugPrint('⏭️ Skipping - document type does not affect stock');
      return; // These documents never touch stock
    }

    try {
      // Load current products using the auth provider we got earlier
      final userId = authProvider.user?.uid;
      if (userId != null) {
        await productProvider.loadProducts(userId);
      }

      debugPrint('📋 Processing ${widget.invoice.items.length} items...');
      
      // Process each item
      for (final item in widget.invoice.items) {
        debugPrint('  → Item: ${item.productName} (ID: ${item.productId})');

        // Find the product
        final product = productProvider.products.firstWhere(
          (p) => p.id == item.productId,
          orElse: () {
            debugPrint('  ❌ Product not found for ID: ${item.productId}');
            throw Exception('Product not found: ${item.productId}');
          },
        );
        
        debugPrint('  ✓ Found product: ${product.name}, Current stock: ${product.stock}');
        
        if (!product.trackStock) {
          debugPrint('  ⏭️ Skipping - product tracking disabled');
          continue; // Skip non-tracked items
        }
        
        // Calculate stock adjustment based on document type
        double stockAdjustment = 0;
        
        debugPrint('  📊 Document type: ${widget.invoice.invoiceType.name}');
        
        switch (widget.invoice.invoiceType) {
          // SALES DOCUMENTS (originally deducted stock, so ADD BACK on cancel)
          case InvoiceType.invoice:
          case InvoiceType.salesOrder:
          case InvoiceType.deliveryChalan:
            stockAdjustment = item.quantity; // ADD back
            debugPrint('  📈 Sales document - will ADD ${item.quantity} (restore stock)');
            break;
          
          // PURCHASE DOCUMENTS (originally added stock, so DEDUCT on cancel)
          case InvoiceType.bill:
          case InvoiceType.purchaseOrder:
            stockAdjustment = -item.quantity; // DEDUCT
            debugPrint('  📉 Purchase document - will DEDUCT ${item.quantity} (reverse addition)');
            break;
          
          // CREDIT NOTE (originally ADDED stock when created, so DEDUCT on cancel)
          case InvoiceType.creditNote:
            stockAdjustment = -item.quantity; // DEDUCT (reverse the addition)
            debugPrint('  📉 Credit Note - will DEDUCT ${item.quantity} (reverse return)');
            break;
          
          // DEBIT NOTE (originally DEDUCTED stock when created, so ADD on cancel)
          case InvoiceType.debitNote:
            stockAdjustment = item.quantity; // ADD (reverse the deduction)
            debugPrint('  📈 Debit Note - will ADD ${item.quantity} (reverse return to supplier)');
            break;
          
          // Should never reach here due to initial check
          default:
            debugPrint('  ⚠️ Unknown document type: ${widget.invoice.invoiceType.name}');
            continue;
        }
        
        // Apply stock adjustment
        final newStock = product.stock + stockAdjustment;
        
        debugPrint('  🔢 Calculation: ${product.stock} ${stockAdjustment > 0 ? '+' : ''}$stockAdjustment = $newStock');
        
        // Prevent negative stock
        if (newStock < 0) {
          debugPrint('  ⛔ Stock would be negative for ${product.name}. Skipping adjustment.');
          // Don't show snackbar here - context might be invalid
          continue;
        }
        
        final updatedProduct = product.copyWith(
          stock: newStock,
          updatedAt: DateTime.now(),
        );
        
        debugPrint('  💾 Updating product in database...');
        await productProvider.updateProduct(updatedProduct);
        
        debugPrint('  ✅ Stock restored for ${product.name}: ${product.stock} → $newStock (${stockAdjustment > 0 ? '+' : ''}$stockAdjustment)');
      }
      
      debugPrint('✅ Stock restoration completed successfully!');
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error restoring stock: $e');
      debugPrint('Stack trace: $stackTrace');
      // Don't show error snackbar - context might be invalid and status update was successful
    }
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Invoice'),
        content: const Text('Are you sure you want to cancel this invoice? Stock will be restored.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(context, PaymentStatus.cancelled);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel Invoice'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPDF(BuildContext context) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating PDF...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Load document settings
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final settingsProvider = Provider.of<DocumentSettingsProvider>(context, listen: false);
      
      final userId = authProvider.user?.uid;
      if (userId != null && settingsProvider.settings == null) {
        await settingsProvider.loadSettings(userId);
      }

      // Generate PDF with settings
      final pdfFile = await PDFService.generateInvoicePDF(
        widget.invoice,
        settings: settingsProvider.settings,
      );

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Open the PDF automatically
      await PDFService.openPDF(pdfFile);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PDF downloaded and opened!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Share',
            onPressed: () => _shareInvoice(context),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareInvoice(BuildContext context) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Preparing to share...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Load document settings
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final settingsProvider = Provider.of<DocumentSettingsProvider>(context, listen: false);
      
      final userId = authProvider.user?.uid;
      if (userId != null && settingsProvider.settings == null) {
        await settingsProvider.loadSettings(userId);
      }

      // Generate PDF with settings
      final pdfFile = await PDFService.generateInvoicePDF(
        widget.invoice,
        settings: settingsProvider.settings,
      );

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Share
      await ShareService.shareFile(
        file: pdfFile,
        subject: 'Invoice ${widget.invoice.invoiceNumber}',
        text: 'Please find the invoice for ${widget.invoice.partyName}\n\nTotal Amount: ₹${widget.invoice.grandTotal.toStringAsFixed(2)}',
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _printInvoice(BuildContext context) async {
    // TODO: Implement printing using printing package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Print feature coming soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _sendPaymentReminder(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Payment Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text('WhatsApp'),
              subtitle: Text(widget.invoice.partyPhone ?? 'No phone number'),
              onTap: widget.invoice.partyPhone != null ? () {
                Navigator.pop(context);
                _sendReminderViaWhatsApp(context);
              } : null,
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text('Email'),
              subtitle: const Text('Send reminder via email'),
              onTap: () {
                Navigator.pop(context);
                _sendReminderViaEmail(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sms, color: Colors.orange),
              title: const Text('SMS'),
              subtitle: Text(widget.invoice.partyPhone ?? 'No phone number'),
              onTap: widget.invoice.partyPhone != null ? () {
                Navigator.pop(context);
                _sendReminderViaSMS(context);
              } : null,
            ),
          ],
        ),
      ),
    );
  }

  void _sendReminderViaWhatsApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening WhatsApp...'),
        backgroundColor: Colors.green,
      ),
    );
    // TODO: Implement WhatsApp integration
  }

  void _sendReminderViaEmail(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening Email...'),
        backgroundColor: Colors.blue,
      ),
    );
    // TODO: Implement Email integration
  }

  void _sendReminderViaSMS(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening SMS...'),
        backgroundColor: Colors.orange,
      ),
    );
    // TODO: Implement SMS integration
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.unpaid:
      case PaymentStatus.pending:
        return Colors.red;
      case PaymentStatus.partial:
        return Colors.orange;
      case PaymentStatus.cancelled:
        return Colors.grey;
    }
  }
}


