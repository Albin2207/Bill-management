import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/business_provider.dart';
import '../../domain/entities/business_entity.dart';

class EditBusinessPage extends StatefulWidget {
  final BusinessEntity business;

  const EditBusinessPage({
    super.key,
    required this.business,
  });

  @override
  State<EditBusinessPage> createState() => _EditBusinessPageState();
}

class _EditBusinessPageState extends State<EditBusinessPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _businessNameController;
  late TextEditingController _tradeNameController;
  late TextEditingController _gstinController;
  late TextEditingController _panController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  late TextEditingController _upiIdController;
  late TextEditingController _termsController;
  late TextEditingController _paymentTermsController;
  
  late BusinessType _selectedBusinessType;
  late List<BankAccount> _bankAccounts;

  @override
  void initState() {
    super.initState();
    _businessNameController = TextEditingController(text: widget.business.businessName);
    _tradeNameController = TextEditingController(text: widget.business.tradeName);
    _gstinController = TextEditingController(text: widget.business.gstin);
    _panController = TextEditingController(text: widget.business.pan);
    _phoneController = TextEditingController(text: widget.business.phone);
    _emailController = TextEditingController(text: widget.business.email);
    _websiteController = TextEditingController(text: widget.business.website);
    _addressController = TextEditingController(text: widget.business.address);
    _cityController = TextEditingController(text: widget.business.city);
    _stateController = TextEditingController(text: widget.business.state);
    _pincodeController = TextEditingController(text: widget.business.pincode);
    _upiIdController = TextEditingController(text: widget.business.upiId);
    _termsController = TextEditingController(text: widget.business.termsAndConditions);
    _paymentTermsController = TextEditingController(text: widget.business.paymentTerms);
    _selectedBusinessType = widget.business.businessType;
    _bankAccounts = List.from(widget.business.bankAccounts);
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _tradeNameController.dispose();
    _gstinController.dispose();
    _panController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _upiIdController.dispose();
    _termsController.dispose();
    _paymentTermsController.dispose();
    super.dispose();
  }

  Future<void> _addBankAccount() async {
    await _showBankAccountDialog();
  }

  Future<void> _editBankAccount(int index) async {
    await _showBankAccountDialog(existingBank: _bankAccounts[index], index: index);
  }

  void _deleteBankAccount(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bank Account'),
        content: const Text('Are you sure you want to delete this bank account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _bankAccounts.removeAt(index);
                // If deleted primary, make first bank primary
                if (_bankAccounts.isNotEmpty && !_bankAccounts.any((b) => b.isPrimary)) {
                  _bankAccounts[0] = _bankAccounts[0].copyWith(isPrimary: true);
                }
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _showBankAccountDialog({BankAccount? existingBank, int? index}) async {
    final bankNameController = TextEditingController(text: existingBank?.bankName);
    final accountHolderController = TextEditingController(text: existingBank?.accountHolderName);
    final accountNumberController = TextEditingController(text: existingBank?.accountNumber);
    final ifscController = TextEditingController(text: existingBank?.ifscCode);
    final branchController = TextEditingController(text: existingBank?.branchName);
    bool isPrimary = existingBank?.isPrimary ?? _bankAccounts.isEmpty;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingBank == null ? 'Add Bank Account' : 'Edit Bank Account'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bankNameController,
                decoration: const InputDecoration(
                  labelText: 'Bank Name *',
                  hintText: 'State Bank of India',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: accountHolderController,
                decoration: const InputDecoration(
                  labelText: 'Account Holder Name *',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: accountNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Account Number *',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ifscController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 11,
                decoration: const InputDecoration(
                  labelText: 'IFSC Code *',
                  hintText: 'SBIN0001234',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: branchController,
                decoration: const InputDecoration(
                  labelText: 'Branch Name (Optional)',
                ),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setDialogState) {
                  return CheckboxListTile(
                    title: const Text('Set as Primary Account'),
                    value: isPrimary,
                    onChanged: (value) {
                      setDialogState(() {
                        isPrimary = value ?? false;
                      });
                    },
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (bankNameController.text.isNotEmpty &&
                  accountHolderController.text.isNotEmpty &&
                  accountNumberController.text.isNotEmpty &&
                  ifscController.text.isNotEmpty) {
                final newBank = BankAccount(
                  bankName: bankNameController.text,
                  accountHolderName: accountHolderController.text,
                  accountNumber: accountNumberController.text,
                  ifscCode: ifscController.text,
                  branchName: branchController.text.isEmpty ? null : branchController.text,
                  isPrimary: isPrimary,
                );

                setState(() {
                  if (index != null) {
                    // Edit existing
                    _bankAccounts[index] = newBank;
                  } else {
                    // Add new
                    _bankAccounts.add(newBank);
                  }

                  // If this is set as primary, update others
                  if (isPrimary) {
                    for (var i = 0; i < _bankAccounts.length; i++) {
                      if (i != (index ?? _bankAccounts.length - 1)) {
                        _bankAccounts[i] = _bankAccounts[i].copyWith(isPrimary: false);
                      }
                    }
                  }
                });

                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all required fields')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(existingBank == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );

    bankNameController.dispose();
    accountHolderController.dispose();
    accountNumberController.dispose();
    ifscController.dispose();
    branchController.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    final updated = widget.business.copyWith(
      businessName: _businessNameController.text,
      tradeName: _tradeNameController.text.isEmpty ? null : _tradeNameController.text,
      businessType: _selectedBusinessType,
      gstin: _gstinController.text,
      pan: _panController.text.isEmpty ? null : _panController.text,
      phone: _phoneController.text,
      email: _emailController.text.isEmpty ? null : _emailController.text,
      website: _websiteController.text.isEmpty ? null : _websiteController.text,
      address: _addressController.text,
      city: _cityController.text.isEmpty ? null : _cityController.text,
      state: _stateController.text.isEmpty ? null : _stateController.text,
      pincode: _pincodeController.text.isEmpty ? null : _pincodeController.text,
      bankAccounts: _bankAccounts,
      upiId: _upiIdController.text.isEmpty ? null : _upiIdController.text,
      termsAndConditions: _termsController.text.isEmpty ? null : _termsController.text,
      paymentTerms: _paymentTermsController.text.isEmpty ? null : _paymentTermsController.text,
      updatedAt: DateTime.now(),
    );

    final success = await businessProvider.updateBusiness(updated);

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Business updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Business'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Info
              const Text('Basic Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _businessNameController,
                decoration: InputDecoration(
                  labelText: 'Business Name *',
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tradeNameController,
                decoration: InputDecoration(
                  labelText: 'Trade Name',
                  prefixIcon: const Icon(Icons.store),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<BusinessType>(
                value: _selectedBusinessType,
                decoration: InputDecoration(
                  labelText: 'Business Type *',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: BusinessType.soleProprietor, child: Text('Sole Proprietor')),
                  DropdownMenuItem(value: BusinessType.partnership, child: Text('Partnership')),
                  DropdownMenuItem(value: BusinessType.llp, child: Text('LLP')),
                  DropdownMenuItem(value: BusinessType.privateLimited, child: Text('Private Limited')),
                  DropdownMenuItem(value: BusinessType.publicLimited, child: Text('Public Limited')),
                  DropdownMenuItem(value: BusinessType.other, child: Text('Other')),
                ],
                onChanged: (value) => setState(() => _selectedBusinessType = value!),
              ),
              const SizedBox(height: 24),

              // GST Details
              const Text('GST & Tax Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _gstinController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 15,
                decoration: InputDecoration(
                  labelText: 'GSTIN *',
                  prefixIcon: const Icon(Icons.receipt_long),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (value!.length != 15) return 'GSTIN must be 15 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _panController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: 'PAN',
                  prefixIcon: const Icon(Icons.credit_card),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),

              // Contact
              const Text('Contact Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: 'Phone *',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _websiteController,
                decoration: InputDecoration(
                  labelText: 'Website',
                  prefixIcon: const Icon(Icons.language),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),

              // Address
              const Text('Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Address *',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  alignLabelWithHint: true,
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: InputDecoration(
                        labelText: 'State',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'Pincode',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),

              // Bank Accounts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Bank Accounts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  OutlinedButton.icon(
                    onPressed: _addBankAccount,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_bankAccounts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Center(
                    child: Text(
                      'No bank accounts added',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                )
              else
                ..._bankAccounts.asMap().entries.map((entry) {
                  final index = entry.key;
                  final bank = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: const Icon(Icons.account_balance, color: AppColors.primary, size: 20),
                      ),
                      title: Text(bank.bankName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${bank.accountHolderName}\n****${bank.accountNumber.substring(bank.accountNumber.length - 4)}'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (bank.isPrimary)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'PRIMARY',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _editBankAccount(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                            onPressed: () => _deleteBankAccount(index),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              const SizedBox(height: 24),

              // UPI
              const Text('Payment Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _upiIdController,
                decoration: InputDecoration(
                  labelText: 'UPI ID',
                  hintText: 'business@upi',
                  prefixIcon: const Icon(Icons.qr_code),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),

              // Terms
              const Text('Terms & Conditions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _paymentTermsController,
                decoration: InputDecoration(
                  labelText: 'Payment Terms',
                  hintText: 'Payment due within 15 days',
                  prefixIcon: const Icon(Icons.payment),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _termsController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Terms & Conditions',
                  prefixIcon: const Icon(Icons.notes),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

