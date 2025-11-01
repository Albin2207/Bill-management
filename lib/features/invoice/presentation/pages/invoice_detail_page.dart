import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/invoice_entity.dart';
import '../providers/invoice_provider.dart';

class InvoiceDetailPage extends StatelessWidget {
  final InvoiceEntity invoice;

  const InvoiceDetailPage({super.key, required this.invoice});

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
                            invoice.invoiceNumber,
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
                          color: _getStatusColor(invoice.paymentStatus),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          invoice.paymentStatus.name.toUpperCase(),
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
                              DateFormat('dd MMM yyyy').format(invoice.invoiceDate),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (invoice.dueDate != null)
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
                                DateFormat('dd MMM yyyy').format(invoice.dueDate!),
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
                    invoice.partyName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (invoice.partyGstin != null) ...[
                    const SizedBox(height: 4),
                    Text('GSTIN: ${invoice.partyGstin}'),
                  ],
                  if (invoice.partyAddress != null) ...[
                    const SizedBox(height: 4),
                    Text(invoice.partyAddress!),
                  ],
                  if (invoice.partyCity != null || invoice.partyState != null) ...[
                    const SizedBox(height: 4),
                    Text('${invoice.partyCity ?? ''} ${invoice.partyState ?? ''}'),
                  ],
                  if (invoice.partyPhone != null) ...[
                    const SizedBox(height: 4),
                    Text('Phone: ${invoice.partyPhone}'),
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
                  ...invoice.items.asMap().entries.map((entry) {
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
                  _buildTotalRow('Subtotal', invoice.subtotal),
                  if (invoice.totalDiscount > 0)
                    _buildTotalRow('Discount', -invoice.totalDiscount, isDiscount: true),
                  _buildTotalRow('Taxable Amount', invoice.taxableAmount),
                  if (invoice.cgst > 0) ...[
                    _buildTotalRow('CGST', invoice.cgst),
                    _buildTotalRow('SGST', invoice.sgst),
                  ],
                  if (invoice.igst > 0)
                    _buildTotalRow('IGST', invoice.igst),
                  const Divider(height: 24),
                  _buildTotalRow('Grand Total', invoice.grandTotal, isBold: true),
                  
                  if (invoice.notes != null) ...[
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
                    Text(invoice.notes!),
                  ],
                  
                  if (invoice.termsAndConditions != null) ...[
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
                    Text(invoice.termsAndConditions!),
                  ],
                ],
              ),
            ),
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
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Share invoice
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share feature coming soon')),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Generate PDF
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PDF generation coming soon')),
                    );
                  },
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
                // TODO: Share
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Download PDF'),
              onTap: () {
                Navigator.pop(context);
                // TODO: PDF
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateStatus(BuildContext context, PaymentStatus newStatus) async {
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    
    // Calculate paid amount based on status
    double paidAmount = 0;
    if (newStatus == PaymentStatus.paid) {
      paidAmount = invoice.grandTotal;
    } else if (newStatus == PaymentStatus.partial) {
      // TODO: Show dialog to enter partial amount
      paidAmount = invoice.grandTotal / 2; // Default to 50%
    }

    final success = await invoiceProvider.updateInvoiceStatus(
      invoice.id,
      newStatus,
      paidAmount,
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice marked as ${newStatus.name}'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Return to list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(invoiceProvider.errorMessage ?? 'Failed to update status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Invoice'),
        content: const Text('Are you sure you want to cancel this invoice? This action cannot be undone.'),
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

