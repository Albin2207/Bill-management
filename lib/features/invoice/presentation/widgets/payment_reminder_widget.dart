import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/invoice_entity.dart';

class PaymentReminderWidget extends StatelessWidget {
  final InvoiceEntity invoice;
  final VoidCallback onSendReminder;

  const PaymentReminderWidget({
    super.key,
    required this.invoice,
    required this.onSendReminder,
  });

  @override
  Widget build(BuildContext context) {
    // Only show if unpaid/pending and has due date
    if (invoice.paymentStatus == PaymentStatus.paid || 
        invoice.paymentStatus == PaymentStatus.cancelled ||
        invoice.dueDate == null) {
      return const SizedBox.shrink();
    }

    final daysOverdue = DateTime.now().difference(invoice.dueDate!).inDays;
    final isOverdue = daysOverdue > 0;

    return Card(
      color: isOverdue ? Colors.red.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isOverdue ? Icons.warning : Icons.schedule,
              color: isOverdue ? Colors.red : Colors.orange,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOverdue 
                        ? 'Payment Overdue by $daysOverdue days'
                        : 'Payment Due Soon',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isOverdue ? Colors.red.shade900 : Colors.orange.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Outstanding: ₹${invoice.balanceAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: onSendReminder,
              icon: const Icon(Icons.send, size: 16),
              label: const Text('Remind'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isOverdue ? Colors.red : Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

