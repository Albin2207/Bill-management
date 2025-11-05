import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/business_provider.dart';
import '../../domain/entities/business_entity.dart';

class BusinessOnboardingPage extends StatefulWidget {
  const BusinessOnboardingPage({super.key});

  @override
  State<BusinessOnboardingPage> createState() => _BusinessOnboardingPageState();
}

class _BusinessOnboardingPageState extends State<BusinessOnboardingPage> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  
  int _currentPage = 0;
  
  // Form Controllers
  final _businessNameController = TextEditingController();
  final _tradeNameController = TextEditingController();
  final _gstinController = TextEditingController();
  final _panController = TextEditingController();
  final _tanController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _branchController = TextEditingController();
  final _upiIdController = TextEditingController();
  final _termsController = TextEditingController();
  final _paymentTermsController = TextEditingController();
  
  BusinessType _selectedBusinessType = BusinessType.soleProprietor;
  bool _addBankDetails = false;

  @override
  void dispose() {
    _pageController.dispose();
    _businessNameController.dispose();
    _tradeNameController.dispose();
    _gstinController.dispose();
    _panController.dispose();
    _tanController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _accountHolderController.dispose();
    _branchController.dispose();
    _upiIdController.dispose();
    _termsController.dispose();
    _paymentTermsController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completOnboarding() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    final bankAccounts = <BankAccount>[];
    if (_addBankDetails &&
        _bankNameController.text.isNotEmpty &&
        _accountNumberController.text.isNotEmpty &&
        _ifscController.text.isNotEmpty) {
      bankAccounts.add(BankAccount(
        bankName: _bankNameController.text,
        accountNumber: _accountNumberController.text,
        ifscCode: _ifscController.text,
        accountHolderName: _accountHolderController.text.isEmpty
            ? _businessNameController.text
            : _accountHolderController.text,
        branchName: _branchController.text.isEmpty ? null : _branchController.text,
        isPrimary: true,
      ));
    }

    final business = BusinessEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: authProvider.user!.uid,
      businessName: _businessNameController.text,
      tradeName: _tradeNameController.text.isEmpty ? null : _tradeNameController.text,
      businessType: _selectedBusinessType,
      gstin: _gstinController.text,
      pan: _panController.text.isEmpty ? null : _panController.text,
      tan: _tanController.text.isEmpty ? null : _tanController.text,
      phone: _phoneController.text,
      email: _emailController.text.isEmpty ? null : _emailController.text,
      website: _websiteController.text.isEmpty ? null : _websiteController.text,
      address: _addressController.text,
      city: _cityController.text.isEmpty ? null : _cityController.text,
      state: _stateController.text.isEmpty ? null : _stateController.text,
      pincode: _pincodeController.text.isEmpty ? null : _pincodeController.text,
      country: 'India',
      bankAccounts: bankAccounts,
      upiId: _upiIdController.text.isEmpty ? null : _upiIdController.text,
      termsAndConditions: _termsController.text.isEmpty ? null : _termsController.text,
      paymentTerms: _paymentTermsController.text.isEmpty ? null : _paymentTermsController.text,
      isOnboardingComplete: true,
      createdAt: DateTime.now(),
    );

    final success = await businessProvider.saveBusiness(business);

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(businessProvider.errorMessage ?? 'Failed to save business'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.03),
              Colors.white,
              AppColors.primary.withOpacity(0.02),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern Progress Indicator
              _buildProgressIndicator(),
              
              // Page Content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) {
                      // Only update if page actually changed to prevent unnecessary rebuilds
                      if (_currentPage != page) {
                        setState(() => _currentPage = page);
                      }
                    },
                    children: [
                      _buildWelcomePage(),
                      _buildBasicInfoPage(),
                      _buildContactPage(),
                      _buildBankDetailsPage(),
                      _buildTermsPage(),
                      _buildCompletePage(),
                    ],
                  ),
                ),
              ),
              
              // Modern Navigation Buttons
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentPage + 1} of 6',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '${(((_currentPage + 1) / 6) * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / 6,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withOpacity(0.2),
                          AppColors.primary.withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.business_center,
                      size: 90,
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                  Text(
                    'Let\'s Setup Your Business',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Set up your business profile\nto get started with professional billing',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_outlined, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Takes only 2-3 minutes',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.business_center, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          const Text(
            'Basic Information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about your business',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Business Name
          TextFormField(
            controller: _businessNameController,
            decoration: InputDecoration(
              labelText: 'Business Name *',
              hintText: 'ABC Traders Pvt Ltd',
              prefixIcon: const Icon(Icons.business),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          // Trade Name
          TextFormField(
            controller: _tradeNameController,
            decoration: InputDecoration(
              labelText: 'Trade Name (Optional)',
              hintText: 'ABC Store',
              prefixIcon: const Icon(Icons.store),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),

          // Business Type
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
          const SizedBox(height: 16),

          // GSTIN
          TextFormField(
            controller: _gstinController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 15,
            decoration: InputDecoration(
              labelText: 'GSTIN *',
              hintText: '22AAAAA0000A1Z5',
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

          // PAN (Optional)
          TextFormField(
            controller: _panController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 10,
            decoration: InputDecoration(
              labelText: 'PAN (Optional)',
              hintText: 'AAAAA0000A',
              prefixIcon: const Icon(Icons.credit_card),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.contact_phone, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          const Text(
            'Contact Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'How can customers reach you?',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Phone
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            decoration: InputDecoration(
              labelText: 'Phone Number *',
              hintText: '9876543210',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Required';
              if (value!.length != 10) return 'Enter valid 10 digit number';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email (Optional)',
              hintText: 'business@example.com',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),

          // Website
          TextFormField(
            controller: _websiteController,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: 'Website (Optional)',
              hintText: 'www.yourbusiness.com',
              prefixIcon: const Icon(Icons.language),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),

          // Address
          TextFormField(
            controller: _addressController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Business Address *',
              hintText: 'Shop No, Street, Landmark',
              prefixIcon: const Icon(Icons.location_on),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              alignLabelWithHint: true,
            ),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          // City & State
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'City',
                    prefixIcon: const Icon(Icons.location_city),
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
                    prefixIcon: const Icon(Icons.map),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pincode
          TextFormField(
            controller: _pincodeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: 'Pincode',
              prefixIcon: const Icon(Icons.pin_drop),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.account_balance, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          const Text(
            'Bank Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Optional - You can add this later',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Add Bank Details Switch
          SwitchListTile(
            title: const Text('Add Bank Account'),
            subtitle: const Text('For receiving payments'),
            value: _addBankDetails,
            onChanged: (value) => setState(() => _addBankDetails = value),
          ),
          const SizedBox(height: 16),

          if (_addBankDetails) ...[
            TextFormField(
              controller: _bankNameController,
              decoration: InputDecoration(
                labelText: 'Bank Name',
                hintText: 'State Bank of India',
                prefixIcon: const Icon(Icons.account_balance),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _accountHolderController,
              decoration: InputDecoration(
                labelText: 'Account Holder Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _accountNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Account Number',
                prefixIcon: const Icon(Icons.numbers),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ifscController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 11,
              decoration: InputDecoration(
                labelText: 'IFSC Code',
                hintText: 'SBIN0001234',
                prefixIcon: const Icon(Icons.code),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _branchController,
              decoration: InputDecoration(
                labelText: 'Branch Name (Optional)',
                prefixIcon: const Icon(Icons.business),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const Divider(height: 32),
            TextFormField(
              controller: _upiIdController,
              decoration: InputDecoration(
                labelText: 'UPI ID (Optional)',
                hintText: 'business@upi',
                prefixIcon: const Icon(Icons.qr_code),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTermsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.description, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          const Text(
            'Terms & Conditions',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Optional - Add your invoice terms',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          TextFormField(
            controller: _paymentTermsController,
            decoration: InputDecoration(
              labelText: 'Payment Terms (Optional)',
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
              labelText: 'Terms & Conditions (Optional)',
              hintText: 'Enter your terms and conditions...',
              prefixIcon: const Icon(Icons.notes),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 60),
          
          // Success Animation - Fast and smooth
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.green.shade400,
                        Colors.green.shade600,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 40),
          
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                Text(
                  '🎉 All Set!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your business profile is ready.\nLet\'s start managing your billing!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              children: [
                _buildSummaryRow(Icons.business, _businessNameController.text),
                const Divider(height: 24),
                _buildSummaryRow(Icons.receipt_long, _gstinController.text),
                const Divider(height: 24),
                _buildSummaryRow(Icons.phone, _phoneController.text),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousPage,
                icon: const Icon(Icons.arrow_back, size: 20),
                label: const Text('Back'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.primary, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentPage == 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: () {
                if (_currentPage == 5) {
                  _completOnboarding();
                } else if (_currentPage == 1) {
                  // Validate basic info before proceeding
                  if (_businessNameController.text.isNotEmpty &&
                      _gstinController.text.length == 15) {
                    _nextPage();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill required fields')),
                    );
                  }
                } else if (_currentPage == 2) {
                  // Validate contact before proceeding
                  if (_phoneController.text.length == 10 &&
                      _addressController.text.isNotEmpty) {
                    _nextPage();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill required fields')),
                    );
                  }
                } else {
                  _nextPage();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Consumer<BusinessProvider>(
                builder: (context, businessProvider, child) {
                  if (businessProvider.isLoading && _currentPage == 5) {
                    return const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Saving...',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage == 5 ? 'Complete Setup' : 'Continue',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _currentPage == 5 ? Icons.check : Icons.arrow_forward,
                        size: 20,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

