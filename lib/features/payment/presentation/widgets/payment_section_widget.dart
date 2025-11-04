import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/payment_entity.dart';
import '../../../invoice/domain/entities/invoice_entity.dart';
import '../../../../core/constants/app_colors.dart';
import 'add_payment_dialog.dart';

class PaymentSectionWidget extends StatelessWidget {
  final InvoiceEntity invoice;
  final List<PaymentEntity> payments;
  final Function(PaymentEntity) onPaymentAdded;
  final Function() onRefresh;

  const PaymentSectionWidget({
    super.key,
    required this.invoice,
    required this.payments,
    required this.onPaymentAdded,
    required this.onRefresh,
  });

  double get _totalPaid {
    return payments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  double get _outstanding {
    return invoice.grandTotal - _totalPaid;
  }

  String get _statusText {
    if (_outstanding <= 0) return 'PAID';
    if (_totalPaid > 0) return 'PARTIALLY PAID';
    return 'UNPAID';
  }

  Color get _statusColor {
    if (_outstanding <= 0) return Colors.green;
    if (_totalPaid > 0) return Colors.orange;
    return Colors.red;
  }

  // Determine payment direction based on document type
  PaymentDirection get _paymentDirection {
    // Sales documents - Money IN (received from customers)
    if (invoice.invoiceType == InvoiceType.invoice ||
        invoice.invoiceType == InvoiceType.salesOrder ||
        invoice.invoiceType == InvoiceType.deliveryChalan ||
        invoice.invoiceType == InvoiceType.creditNote) {
      return PaymentDirection.inward;
    }
    // Purchase documents - Money OUT (paid to vendors)
    else if (invoice.invoiceType == InvoiceType.bill ||
        invoice.invoiceType == InvoiceType.purchaseOrder ||
        invoice.invoiceType == InvoiceType.debitNote) {
      return PaymentDirection.outward;
    }
    // Default to inward for others
    return PaymentDirection.inward;
  }

  String get _amountLabel {
    return _paymentDirection == PaymentDirection.inward ? 'Received' : 'Paid';
  }

  String get _outstandingLabel {
    return _paymentDirection == PaymentDirection.inward 
        ? 'Outstanding (To Receive)' 
        : 'Outstanding (To Pay)';
  }

  String get _buttonText {
    return _paymentDirection == PaymentDirection.inward 
        ? 'Record Receipt' 
        : 'Record Payment';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.payment, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Payment Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusText,
                    style: TextStyle(
                      color: _statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Payment Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildAmountRow('Total Amount', invoice.grandTotal, isTotal: true),
                  const Divider(height: 20),
                  _buildAmountRow('$_amountLabel Amount', _totalPaid, color: _paymentDirection == PaymentDirection.inward ? Colors.green : Colors.red),
                  const Divider(height: 20),
                  _buildAmountRow(_outstandingLabel, _outstanding, color: _outstanding > 0 ? Colors.orange : Colors.green, isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Add Payment Button (only if outstanding > 0)
            if (_outstanding > 0 && invoice.paymentStatus != PaymentStatus.cancelled)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddPaymentDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(_paymentDirection == PaymentDirection.inward ? Icons.arrow_downward : Icons.arrow_upward),
                  label: Text(_buttonText, style: const TextStyle(fontSize: 16)),
                ),
              ),
            
            if (payments.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Payment History Header
              Row(
                children: [
                  Text(
                    _paymentDirection == PaymentDirection.inward ? 'Receipt History' : 'Payment History',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${payments.length}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Payment List
              ...payments.map((payment) => _buildPaymentItem(payment)).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, {Color? color, bool isTotal = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 15,
            color: isTotal ? Colors.black87 : Colors.grey[700],
            fontWeight: isBold || isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: color ?? (isTotal ? Colors.black87 : Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentItem(PaymentEntity payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.check_circle, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${payment.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${payment.paymentMethodName} • ${DateFormat('dd MMM yyyy').format(payment.paymentDate)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                if (payment.referenceNumber != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Ref: ${payment.referenceNumber}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (payment.notes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    payment.notes!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentDialog(BuildContext context) {
      showDialog(
      context: context,
      builder: (context) => AddPaymentDialog(
        documentId: invoice.id,
        documentNumber: invoice.invoiceNumber,
        documentType: invoice.invoiceType.toString().split('.').last,
        partyId: invoice.partyId,
        partyName: invoice.partyName,
        totalAmount: invoice.grandTotal,
        alreadyPaid: _totalPaid,
        direction: _paymentDirection,
        onPaymentAdded: (payment) {
          Navigator.pop(context);
          onPaymentAdded(payment);
        },
      ),
    );
  }
}

