import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/document_settings_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../business/presentation/providers/business_provider.dart';
import '../providers/document_settings_provider.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/utils/sample_invoice_generator.dart';

class DocumentSettingsPage extends StatefulWidget {
  const DocumentSettingsPage({super.key});

  @override
  State<DocumentSettingsPage> createState() => _DocumentSettingsPageState();
}

class _DocumentSettingsPageState extends State<DocumentSettingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Text Controllers
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _companyGSTINController = TextEditingController();
  final TextEditingController _companyAddressController = TextEditingController();
  final TextEditingController _companyPhoneController = TextEditingController();
  final TextEditingController _companyEmailController = TextEditingController();
  final TextEditingController _companyWebsiteController = TextEditingController();
  
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();
  final TextEditingController _branchNameController = TextEditingController();
  final TextEditingController _upiIdController = TextEditingController();
  
  final TextEditingController _customHeaderController = TextEditingController();
  final TextEditingController _customFooterController = TextEditingController();
  final TextEditingController _defaultTermsController = TextEditingController();
  
  // Settings state
  DocumentTemplate _selectedTemplate = DocumentTemplate.classic;
  DocumentOrientation _orientation = DocumentOrientation.portrait;
  FontStyle _fontStyle = FontStyle.roboto;
  double _fontSize = 12.0;
  String _primaryColor = '#2196F3';
  
  bool _showLogo = true;
  bool _showCompanyDetails = true;
  bool _showBankDetails = true;
  bool _showSignature = true;
  bool _showTerms = true;
  bool _showQRCode = false;
  bool _includeHSN = true;
  bool _includeTax = true;
  bool _roundOff = false;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _companyNameController.dispose();
    _companyGSTINController.dispose();
    _companyAddressController.dispose();
    _companyPhoneController.dispose();
    _companyEmailController.dispose();
    _companyWebsiteController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _branchNameController.dispose();
    _upiIdController.dispose();
    _customHeaderController.dispose();
    _customFooterController.dispose();
    _defaultTermsController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settingsProvider = Provider.of<DocumentSettingsProvider>(context, listen: false);
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    
    final userId = authProvider.user?.uid;
    if (userId != null) {
      // Load both settings and business data
      await Future.wait([
        settingsProvider.loadSettings(userId),
        businessProvider.loadBusiness(userId),
      ]);
      
      final settings = settingsProvider.settings;
      final business = businessProvider.business;
      
      // Get primary bank from business
      final primaryBank = business?.bankAccounts.isNotEmpty == true
          ? business!.bankAccounts.firstWhere((b) => b.isPrimary, orElse: () => business.bankAccounts.first)
          : null;
      
      setState(() {
        // Load template settings (if available)
        if (settings != null) {
          _selectedTemplate = settings.template;
          _orientation = settings.orientation;
          _fontStyle = settings.fontStyle;
          _fontSize = settings.fontSize;
          _primaryColor = settings.primaryColor;
          
          _showLogo = settings.showLogo;
          _showCompanyDetails = settings.showCompanyDetails;
          _showBankDetails = settings.showBankDetails;
          _showSignature = settings.showSignature;
          _showTerms = settings.showTerms;
          _showQRCode = settings.showQRCode;
          _includeHSN = settings.includeHSNColumn;
          _includeTax = settings.includeTaxColumn;
          _roundOff = settings.roundOffTotal;
          
          _customHeaderController.text = settings.customHeader ?? '';
          _customFooterController.text = settings.customFooter ?? '';
        }
        
        // Load company/bank details: Use settings first, fallback to business data
        _companyNameController.text = (settings?.companyName?.isNotEmpty == true 
            ? settings!.companyName 
            : business?.businessName) ?? '';
        
        _companyGSTINController.text = (settings?.companyGSTIN?.isNotEmpty == true 
            ? settings!.companyGSTIN 
            : business?.gstin) ?? '';
        
        _companyAddressController.text = (settings?.companyAddress?.isNotEmpty == true 
            ? settings!.companyAddress 
            : business?.address) ?? '';
        
        _companyPhoneController.text = (settings?.companyPhone?.isNotEmpty == true 
            ? settings!.companyPhone 
            : business?.phone) ?? '';
        
        _companyEmailController.text = (settings?.companyEmail?.isNotEmpty == true 
            ? settings!.companyEmail 
            : business?.email) ?? '';
        
        _companyWebsiteController.text = (settings?.companyWebsite?.isNotEmpty == true 
            ? settings!.companyWebsite 
            : business?.website) ?? '';
        
        // Bank details: settings first, then business bank account
        _bankNameController.text = (settings?.bankName?.isNotEmpty == true 
            ? settings!.bankName 
            : primaryBank?.bankName) ?? '';
        
        _accountNumberController.text = (settings?.accountNumber?.isNotEmpty == true 
            ? settings!.accountNumber 
            : primaryBank?.accountNumber) ?? '';
        
        _ifscCodeController.text = (settings?.ifscCode?.isNotEmpty == true 
            ? settings!.ifscCode 
            : primaryBank?.ifscCode) ?? '';
        
        _branchNameController.text = (settings?.branchName?.isNotEmpty == true 
            ? settings!.branchName 
            : primaryBank?.branchName) ?? '';
        
        _upiIdController.text = (settings?.upiId?.isNotEmpty == true 
            ? settings!.upiId 
            : business?.upiId) ?? '';
        
        // Terms: settings first, then business
        _defaultTermsController.text = (settings?.defaultTerms?.isNotEmpty == true 
            ? settings!.defaultTerms 
            : business?.termsAndConditions) ?? '';
        
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.onPrimary,
          labelColor: AppColors.onPrimary,
          unselectedLabelColor: AppColors.onPrimary.withOpacity(0.7),
          isScrollable: true,
          tabs: const [
            Tab(text: 'Templates'),
            Tab(text: 'Appearance'),
            Tab(text: 'Company'),
            Tab(text: 'Bank Details'),
            Tab(text: 'Advanced'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTemplatesTab(),
                _buildAppearanceTab(),
                _buildCompanyTab(),
                _buildBankDetailsTab(),
                _buildAdvancedTab(),
              ],
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
                flex: 2,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: _previewPDF,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Preview'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Consumer<DocumentSettingsProvider>(
                  builder: (context, provider, child) {
                    return ElevatedButton.icon(
                      onPressed: provider.status == DocumentSettingsStatus.saving
                          ? null
                          : _saveSettings,
                      icon: provider.status == DocumentSettingsStatus.saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        provider.status == DocumentSettingsStatus.saving
                            ? 'Saving...'
                            : 'Save Settings',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplatesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Choose a template for your documents',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        ...DocumentTemplate.values.map((template) {
          return _buildTemplateCard(template);
        }),
      ],
    );
  }

  Widget _buildTemplateCard(DocumentTemplate template) {
    final isSelected = _selectedTemplate == template;
    final templateInfo = _getTemplateInfo(template);
    
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTemplate = template;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 100,
                decoration: BoxDecoration(
                  color: templateInfo['color'],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Icon(
                  templateInfo['icon'],
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      templateInfo['name'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.primary : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      templateInfo['description'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getTemplateInfo(DocumentTemplate template) {
    switch (template) {
      case DocumentTemplate.classic:
        return {
          'name': 'Classic',
          'description': 'Traditional business invoice layout',
          'color': Colors.blue.shade700,
          'icon': Icons.description,
        };
      case DocumentTemplate.modern:
        return {
          'name': 'Modern',
          'description': 'Clean and contemporary design',
          'color': Colors.purple.shade600,
          'icon': Icons.auto_awesome,
        };
      case DocumentTemplate.minimal:
        return {
          'name': 'Minimal',
          'description': 'Simple and elegant',
          'color': Colors.grey.shade700,
          'icon': Icons.layers_clear,
        };
      case DocumentTemplate.professional:
        return {
          'name': 'Professional',
          'description': 'Corporate-style layout',
          'color': Colors.indigo.shade800,
          'icon': Icons.business_center,
        };
      case DocumentTemplate.colorful:
        return {
          'name': 'Colorful',
          'description': 'Vibrant and eye-catching',
          'color': Colors.orange.shade600,
          'icon': Icons.palette,
        };
      case DocumentTemplate.elegant:
        return {
          'name': 'Elegant',
          'description': 'Sophisticated and refined',
          'color': Colors.teal.shade700,
          'icon': Icons.diamond,
        };
    }
  }

  Widget _buildAppearanceTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Color Theme
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Color Theme',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Primary Color', style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildColorOption('#2196F3', Colors.blue),
                              _buildColorOption('#9C27B0', Colors.purple),
                              _buildColorOption('#4CAF50', Colors.green),
                              _buildColorOption('#FF9800', Colors.orange),
                              _buildColorOption('#F44336', Colors.red),
                              _buildColorOption('#009688', Colors.teal),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Language
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Language',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'PDFs use English labels as per GST standards. All documents are bilingual-ready.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Orientation
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Page Orientation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<DocumentOrientation>(
                  segments: const [
                    ButtonSegment(
                      value: DocumentOrientation.portrait,
                      label: Text('Portrait'),
                      icon: Icon(Icons.smartphone),
                    ),
                    ButtonSegment(
                      value: DocumentOrientation.landscape,
                      label: Text('Landscape'),
                      icon: Icon(Icons.tablet),
                    ),
                  ],
                  selected: {_orientation},
                  onSelectionChanged: (Set<DocumentOrientation> newSelection) {
                    setState(() {
                      _orientation = newSelection.first;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Font Style
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Font Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<FontStyle>(
                  value: _fontStyle,
                  decoration: const InputDecoration(
                    labelText: 'Font Style',
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true,
                  items: FontStyle.values.map((font) {
                    return DropdownMenuItem(
                      value: font,
                      child: Text(font.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _fontStyle = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Font Size:'),
                    Expanded(
                      child: Slider(
                        value: _fontSize,
                        min: 8,
                        max: 16,
                        divisions: 8,
                        label: _fontSize.toStringAsFixed(0),
                        onChanged: (value) {
                          setState(() {
                            _fontSize = value;
                          });
                        },
                      ),
                    ),
                    Text('${_fontSize.toStringAsFixed(0)}pt'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Display Options
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Display Options',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Show Company Logo'),
                  subtitle: const Text('Display logo in header'),
                  value: _showLogo,
                  onChanged: (value) {
                    setState(() {
                      _showLogo = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Show Company Details'),
                  subtitle: const Text('Display address, GSTIN, contact'),
                  value: _showCompanyDetails,
                  onChanged: (value) {
                    setState(() {
                      _showCompanyDetails = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Show Bank Details'),
                  subtitle: const Text('Display payment information'),
                  value: _showBankDetails,
                  onChanged: (value) {
                    setState(() {
                      _showBankDetails = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Show Signature'),
                  subtitle: const Text('Display authorized signatory'),
                  value: _showSignature,
                  onChanged: (value) {
                    setState(() {
                      _showSignature = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Show Terms & Conditions'),
                  value: _showTerms,
                  onChanged: (value) {
                    setState(() {
                      _showTerms = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Show QR Code'),
                  subtitle: const Text('Payment QR code'),
                  value: _showQRCode,
                  onChanged: (value) {
                    setState(() {
                      _showQRCode = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Company Information',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: _companyNameController,
                  decoration: const InputDecoration(
                    labelText: 'Company Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _companyGSTINController,
                  decoration: const InputDecoration(
                    labelText: 'GSTIN',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.confirmation_number),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _companyAddressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _companyPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _companyEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _companyWebsiteController,
                  decoration: const InputDecoration(
                    labelText: 'Website',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.language),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBankDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Bank Account Information',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: _bankNameController,
                  decoration: const InputDecoration(
                    labelText: 'Bank Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _accountNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Account Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ifscCodeController,
                  decoration: const InputDecoration(
                    labelText: 'IFSC Code',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.qr_code),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _branchNameController,
                  decoration: const InputDecoration(
                    labelText: 'Branch Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.store),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _upiIdController,
                  decoration: const InputDecoration(
                    labelText: 'UPI ID',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.payment),
                    hintText: 'yourname@bank',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Column(
            children: [
              const ListTile(
                title: Text('Auto Numbering'),
                subtitle: Text('Automatically generate document numbers'),
                leading: Icon(Icons.tag),
                trailing: Icon(Icons.check_circle, color: Colors.green),
              ),
              SwitchListTile(
                title: const Text('Include HSN Column'),
                subtitle: const Text('Show HSN/SAC code in items table'),
                value: _includeHSN,
                onChanged: (value) {
                  setState(() {
                    _includeHSN = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Include Tax Column'),
                subtitle: const Text('Show tax breakdown in table'),
                value: _includeTax,
                onChanged: (value) {
                  setState(() {
                    _includeTax = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Round Off Total'),
                subtitle: const Text('Round grand total to nearest rupee'),
                value: _roundOff,
                onChanged: (value) {
                  setState(() {
                    _roundOff = value;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Custom Header',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customHeaderController,
                  decoration: const InputDecoration(
                    labelText: 'Custom Header Text',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., "Thank you for your business!"',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Custom Footer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customFooterController,
                  decoration: const InputDecoration(
                    labelText: 'Custom Footer Text',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., "This is computer generated invoice"',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Default Terms & Conditions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _defaultTermsController,
                  decoration: const InputDecoration(
                    labelText: 'Terms & Conditions',
                    border: OutlineInputBorder(),
                    hintText: 'Enter default T&C for all documents',
                  ),
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildColorOption(String hexColor, Color displayColor) {
    final isSelected = _primaryColor == hexColor;
    return GestureDetector(
      onTap: () {
        setState(() {
          _primaryColor = hexColor;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: displayColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: isSelected ? 3 : 2,
          ),
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }

  Future<void> _previewPDF() async {
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
                  Text('Generating Preview...'),
                ],
              ),
            ),
          ),
        ),
      );

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
      final userId = authProvider.user?.uid ?? 'preview_user';

      // Get business data for logo/signature
      final business = businessProvider.business;

      // Create temporary settings with current form values (NOT saved yet)
      final previewSettings = DocumentSettingsEntity(
        id: userId,
        userId: userId,
        template: _selectedTemplate,
        primaryColor: _primaryColor,
        secondaryColor: '#FFC107',
        fontStyle: _fontStyle,
        fontSize: _fontSize,
        orientation: _orientation,
        showLogo: _showLogo,
        showCompanyDetails: _showCompanyDetails,
        showBankDetails: _showBankDetails,
        showSignature: _showSignature,
        showTerms: _showTerms,
        showQRCode: _showQRCode,
        customHeader: _customHeaderController.text.isNotEmpty 
            ? _customHeaderController.text 
            : null,
        customFooter: _customFooterController.text.isNotEmpty 
            ? _customFooterController.text 
            : null,
        defaultTerms: _defaultTermsController.text.isNotEmpty 
            ? _defaultTermsController.text 
            : null,
        defaultNotes: null,
        companyName: _companyNameController.text.isNotEmpty 
            ? _companyNameController.text 
            : 'Your Company Name',
        companyGSTIN: _companyGSTINController.text.isNotEmpty 
            ? _companyGSTINController.text 
            : '29AABCT1234C1Z5',
        companyAddress: _companyAddressController.text.isNotEmpty 
            ? _companyAddressController.text 
            : 'Your Company Address',
        companyPhone: _companyPhoneController.text.isNotEmpty 
            ? _companyPhoneController.text 
            : '+91 1234567890',
        companyEmail: _companyEmailController.text.isNotEmpty 
            ? _companyEmailController.text 
            : 'info@yourcompany.com',
        companyWebsite: _companyWebsiteController.text.isNotEmpty 
            ? _companyWebsiteController.text 
            : 'www.yourcompany.com',
        companyLogo: null,
        bankName: _bankNameController.text.isNotEmpty 
            ? _bankNameController.text 
            : 'State Bank of India',
        accountNumber: _accountNumberController.text.isNotEmpty 
            ? _accountNumberController.text 
            : '1234567890',
        ifscCode: _ifscCodeController.text.isNotEmpty 
            ? _ifscCodeController.text 
            : 'SBIN0001234',
        branchName: _branchNameController.text.isNotEmpty 
            ? _branchNameController.text 
            : 'Main Branch',
        upiId: _upiIdController.text.isNotEmpty 
            ? _upiIdController.text 
            : 'yourcompany@sbi',
        signatureUrl: null,
        authorizedSignatory: null,
        autoNumbering: true,
        includeHSNColumn: _includeHSN,
        includeTaxColumn: _includeTax,
        showItemImages: false,
        roundOffTotal: _roundOff,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Generate sample invoice
      final sampleInvoice = SampleInvoiceGenerator.generateSampleInvoice();

      // Generate PDF with preview settings and business data (saved to temp folder, not Downloads)
      final pdfFile = await PDFService.generateInvoicePDF(
        sampleInvoice,
        settings: previewSettings,
        business: business, // Pass business for logo/signature
        isPreview: true, // This saves to temp folder instead of Downloads
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Open the PDF automatically
      await PDFService.openPDF(pdfFile);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preview generated! (Temporary file - not saved to Downloads)'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate preview: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveSettings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settingsProvider = Provider.of<DocumentSettingsProvider>(context, listen: false);
    
    final userId = authProvider.user?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final settings = DocumentSettingsEntity(
      id: userId,
      userId: userId,
      template: _selectedTemplate,
      primaryColor: _primaryColor,
      secondaryColor: '#FFC107',
      fontStyle: _fontStyle,
      fontSize: _fontSize,
      orientation: _orientation,
      showLogo: _showLogo,
      showCompanyDetails: _showCompanyDetails,
      showBankDetails: _showBankDetails,
      showSignature: _showSignature,
      showTerms: _showTerms,
      showQRCode: _showQRCode,
      customHeader: _customHeaderController.text.isNotEmpty 
          ? _customHeaderController.text 
          : null,
      customFooter: _customFooterController.text.isNotEmpty 
          ? _customFooterController.text 
          : null,
      defaultTerms: _defaultTermsController.text.isNotEmpty 
          ? _defaultTermsController.text 
          : null,
      defaultNotes: null,
      companyName: _companyNameController.text.isNotEmpty 
          ? _companyNameController.text 
          : null,
      companyGSTIN: _companyGSTINController.text.isNotEmpty 
          ? _companyGSTINController.text 
          : null,
      companyAddress: _companyAddressController.text.isNotEmpty 
          ? _companyAddressController.text 
          : null,
      companyPhone: _companyPhoneController.text.isNotEmpty 
          ? _companyPhoneController.text 
          : null,
      companyEmail: _companyEmailController.text.isNotEmpty 
          ? _companyEmailController.text 
          : null,
      companyWebsite: _companyWebsiteController.text.isNotEmpty 
          ? _companyWebsiteController.text 
          : null,
      companyLogo: null,
      bankName: _bankNameController.text.isNotEmpty 
          ? _bankNameController.text 
          : null,
      accountNumber: _accountNumberController.text.isNotEmpty 
          ? _accountNumberController.text 
          : null,
      ifscCode: _ifscCodeController.text.isNotEmpty 
          ? _ifscCodeController.text 
          : null,
      branchName: _branchNameController.text.isNotEmpty 
          ? _branchNameController.text 
          : null,
      upiId: _upiIdController.text.isNotEmpty 
          ? _upiIdController.text 
          : null,
      signatureUrl: null,
      authorizedSignatory: null,
      autoNumbering: true,
      includeHSNColumn: _includeHSN,
      includeTaxColumn: _includeTax,
      showItemImages: false,
      roundOffTotal: _roundOff,
      createdAt: settingsProvider.settings?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await settingsProvider.saveSettings(settings);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(settingsProvider.errorMessage ?? 'Failed to save settings'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
