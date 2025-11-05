import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/payment_entity.dart';
import '../../../../core/constants/app_colors.dart';

class AddPaymentDialog extends StatefulWidget {
  final String documentId;
  final String documentNumber;
  final String documentType;
  final String partyId;
  final String partyName;
  final double totalAmount;
  final double alreadyPaid;
  final PaymentDirection direction;
  final Function(PaymentEntity) onPaymentAdded;

  const AddPaymentDialog({
    super.key,
    required this.documentId,
    required this.documentNumber,
    required this.documentType,
    required this.partyId,
    required this.partyName,
    required this.totalAmount,
    required this.alreadyPaid,
    required this.direction,
    required this.onPaymentAdded,
  });

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  bool _isLoading = false;

  double get _outstanding => widget.totalAmount - widget.alreadyPaid;

  @override
  void initState() {
    super.initState();
    // Set outstanding amount as default
    _amountController.text = _outstanding.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final payment = PaymentEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        documentId: widget.documentId,
        documentNumber: widget.documentNumber,
        documentType: widget.documentType,
        partyId: widget.partyId,
        partyName: widget.partyName,
        amount: double.parse(_amountController.text),
        paymentDate: _selectedDate,
        method: _selectedMethod,
        referenceNumber: _referenceController.text.isEmpty ? null : _referenceController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        status: TransactionStatus.success,
        direction: widget.direction,
        userId: '',  // Will be set by provider
        createdAt: DateTime.now(),
      );

      widget.onPaymentAdded(payment);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.payment, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.direction == PaymentDirection.inward ? 'Record Receipt' : 'Record Payment',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.documentNumber,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Total Amount', widget.totalAmount),
                    const Divider(height: 16),
                    _buildSummaryRow(
                      widget.direction == PaymentDirection.inward ? 'Already Received' : 'Already Paid',
                      widget.alreadyPaid,
                      color: widget.direction == PaymentDirection.inward ? Colors.green : Colors.red,
                    ),
                    const Divider(height: 16),
                    _buildSummaryRow(
                      widget.direction == PaymentDirection.inward ? 'Outstanding (To Receive)' : 'Outstanding (To Pay)',
                      _outstanding,
                      color: Colors.orange,
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: widget.direction == PaymentDirection.inward ? 'Receipt Amount *' : 'Payment Amount *',
                  prefixIcon: const Icon(Icons.currency_rupee),
                  suffixIcon: TextButton(
                    onPressed: () {
                      _amountController.text = _outstanding.toStringAsFixed(2);
                    },
                    child: const Text('Full'),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  if (amount > _outstanding) {
                    return 'Amount cannot exceed outstanding (₹${_outstanding.toStringAsFixed(2)})';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date Field
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Payment Date *',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    DateFormat('dd MMM yyyy').format(_selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Payment Method
              DropdownButtonFormField<PaymentMethod>(
                value: _selectedMethod,
                decoration: InputDecoration(
                  labelText: 'Payment Method *',
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: PaymentMethod.values.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(_getMethodName(method)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedMethod = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Reference Number
              TextFormField(
                controller: _referenceController,
                decoration: InputDecoration(
                  labelText: 'Reference Number (Optional)',
                  hintText: 'Transaction ID, Cheque No, etc.',
                  prefixIcon: const Icon(Icons.tag),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add any additional information',
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              widget.direction == PaymentDirection.inward ? 'Save Receipt' : 'Save Payment',
                              style: const TextStyle(fontSize: 16),
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
    );
  }

  Widget _buildSummaryRow(String label, double amount, {Color? color, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  String _getMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.cheque:
        return 'Cheque';
      case PaymentMethod.razorpayOnline:
        return 'Razorpay Online';
      case PaymentMethod.razorpayLink:
        return 'Razorpay Link';
      case PaymentMethod.other:
        return 'Other';
    }
  }
}

