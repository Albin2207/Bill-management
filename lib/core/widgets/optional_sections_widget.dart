import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/document_constants.dart';

class OptionalSectionsWidget extends StatefulWidget {
  final Map<String, dynamic> optionalData;
  final Function(Map<String, dynamic>) onDataChanged;

  const OptionalSectionsWidget({
    super.key,
    required this.optionalData,
    required this.onDataChanged,
  });

  @override
  State<OptionalSectionsWidget> createState() => _OptionalSectionsWidgetState();
}

class _OptionalSectionsWidgetState extends State<OptionalSectionsWidget> {
  late TextEditingController _dispatchAddressController;
  late TextEditingController _signatureController;
  late TextEditingController _notesController;
  late TextEditingController _termsController;
  late TextEditingController _extraDiscountController;
  late TextEditingController _deliveryChargesController;
  late TextEditingController _shippingChargesController;
  late TextEditingController _packagingChargesController;
  
  String? _paymentMethod;
  bool _showDispatchAddress = false;
  bool _showSignature = false;
  bool _showPaymentMethod = false;
  bool _showNotes = false;
  bool _showTerms = false;
  bool _showExtraDiscount = false;
  bool _showCharges = false;

  @override
  void initState() {
    super.initState();
    _dispatchAddressController = TextEditingController(
      text: widget.optionalData['dispatchAddress'] ?? '',
    );
    _signatureController = TextEditingController(
      text: widget.optionalData['signature'] ?? '',
    );
    _notesController = TextEditingController(
      text: widget.optionalData['notes'] ?? '',
    );
    _termsController = TextEditingController(
      text: widget.optionalData['terms'] ?? '',
    );
    _extraDiscountController = TextEditingController(
      text: widget.optionalData['extraDiscount']?.toString() ?? '0',
    );
    _deliveryChargesController = TextEditingController(
      text: widget.optionalData['deliveryCharges']?.toString() ?? '0',
    );
    _shippingChargesController = TextEditingController(
      text: widget.optionalData['shippingCharges']?.toString() ?? '0',
    );
    _packagingChargesController = TextEditingController(
      text: widget.optionalData['packagingCharges']?.toString() ?? '0',
    );
    _paymentMethod = widget.optionalData['paymentMethod'];
  }

  @override
  void dispose() {
    _dispatchAddressController.dispose();
    _signatureController.dispose();
    _notesController.dispose();
    _termsController.dispose();
    _extraDiscountController.dispose();
    _deliveryChargesController.dispose();
    _shippingChargesController.dispose();
    _packagingChargesController.dispose();
    super.dispose();
  }

  void _updateData() {
    widget.onDataChanged({
      'dispatchAddress': _dispatchAddressController.text,
      'signature': _signatureController.text,
      'paymentMethod': _paymentMethod,
      'notes': _notesController.text,
      'terms': _termsController.text,
      'extraDiscount': double.tryParse(_extraDiscountController.text) ?? 0,
      'deliveryCharges': double.tryParse(_deliveryChargesController.text) ?? 0,
      'shippingCharges': double.tryParse(_shippingChargesController.text) ?? 0,
      'packagingCharges': double.tryParse(_packagingChargesController.text) ?? 0,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Optional Fields',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Add Optional Fields Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (!_showDispatchAddress)
                  _buildAddButton(
                    'Dispatch Address',
                    Icons.location_on,
                    () => setState(() => _showDispatchAddress = true),
                  ),
                if (!_showSignature)
                  _buildAddButton(
                    'Signature',
                    Icons.edit,
                    () => setState(() => _showSignature = true),
                  ),
                if (!_showPaymentMethod)
                  _buildAddButton(
                    'Payment Method',
                    Icons.payment,
                    () => setState(() => _showPaymentMethod = true),
                  ),
                if (!_showNotes)
                  _buildAddButton(
                    'Notes',
                    Icons.note,
                    () => setState(() => _showNotes = true),
                  ),
                if (!_showTerms)
                  _buildAddButton(
                    'Terms & Conditions',
                    Icons.description,
                    () => setState(() => _showTerms = true),
                  ),
                if (!_showExtraDiscount)
                  _buildAddButton(
                    'Extra Discount',
                    Icons.discount,
                    () => setState(() => _showExtraDiscount = true),
                  ),
                if (!_showCharges)
                  _buildAddButton(
                    'Delivery/Charges',
                    Icons.local_shipping,
                    () => setState(() => _showCharges = true),
                  ),
              ],
            ),
            
            // Optional Fields
            const SizedBox(height: 16),
            
            if (_showDispatchAddress) ...[
              _buildSectionHeader(
                'Dispatch Address',
                () => setState(() {
                  _showDispatchAddress = false;
                  _dispatchAddressController.clear();
                  _updateData();
                }),
              ),
              TextFormField(
                controller: _dispatchAddressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                  hintText: 'Enter dispatch address',
                ),
                maxLines: 3,
                onChanged: (_) => _updateData(),
              ),
              const SizedBox(height: 16),
            ],
            
            if (_showSignature) ...[
              _buildSectionHeader(
                'Signature',
                () => setState(() {
                  _showSignature = false;
                  _signatureController.clear();
                  _updateData();
                }),
              ),
              TextFormField(
                controller: _signatureController,
                decoration: const InputDecoration(
                  labelText: 'Authorized Signatory',
                  border: OutlineInputBorder(),
                  hintText: 'Name of signatory',
                ),
                onChanged: (_) => _updateData(),
              ),
              const SizedBox(height: 16),
            ],
            
            if (_showPaymentMethod) ...[
              _buildSectionHeader(
                'Payment Method',
                () => setState(() {
                  _showPaymentMethod = false;
                  _paymentMethod = null;
                  _updateData();
                }),
              ),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Select Method',
                  border: OutlineInputBorder(),
                ),
                items: DocumentConstants.paymentMethods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value;
                  });
                  _updateData();
                },
              ),
              const SizedBox(height: 16),
            ],
            
            if (_showNotes) ...[
              _buildSectionHeader(
                'Notes',
                () => setState(() {
                  _showNotes = false;
                  _notesController.clear();
                  _updateData();
                }),
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Add Notes',
                  border: OutlineInputBorder(),
                  hintText: 'Any additional notes',
                ),
                maxLines: 3,
                onChanged: (_) => _updateData(),
              ),
              const SizedBox(height: 16),
            ],
            
            if (_showTerms) ...[
              _buildSectionHeader(
                'Terms & Conditions',
                () => setState(() {
                  _showTerms = false;
                  _termsController.clear();
                  _updateData();
                }),
              ),
              TextFormField(
                controller: _termsController,
                decoration: const InputDecoration(
                  labelText: 'Terms & Conditions',
                  border: OutlineInputBorder(),
                  hintText: 'Enter terms and conditions',
                ),
                maxLines: 4,
                onChanged: (_) => _updateData(),
              ),
              const SizedBox(height: 16),
            ],
            
            if (_showExtraDiscount) ...[
              _buildSectionHeader(
                'Extra Discount',
                () => setState(() {
                  _showExtraDiscount = false;
                  _extraDiscountController.text = '0';
                  _updateData();
                }),
              ),
              TextFormField(
                controller: _extraDiscountController,
                decoration: const InputDecoration(
                  labelText: 'Extra Discount',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _updateData(),
              ),
              const SizedBox(height: 16),
            ],
            
            if (_showCharges) ...[
              _buildSectionHeader(
                'Additional Charges',
                () => setState(() {
                  _showCharges = false;
                  _deliveryChargesController.text = '0';
                  _shippingChargesController.text = '0';
                  _packagingChargesController.text = '0';
                  _updateData();
                }),
              ),
              TextFormField(
                controller: _deliveryChargesController,
                decoration: const InputDecoration(
                  labelText: 'Delivery Charges',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _updateData(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _shippingChargesController,
                decoration: const InputDecoration(
                  labelText: 'Shipping Charges',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _updateData(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _packagingChargesController,
                decoration: const InputDecoration(
                  labelText: 'Packaging Charges',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _updateData(),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(String label, IconData icon, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 20),
            color: Colors.red,
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

