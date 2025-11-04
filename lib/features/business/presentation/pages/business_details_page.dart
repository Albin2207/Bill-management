import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/business_provider.dart';
import '../../domain/entities/business_entity.dart';
import 'edit_business_page.dart';

class BusinessDetailsPage extends StatefulWidget {
  const BusinessDetailsPage({super.key});

  @override
  State<BusinessDetailsPage> createState() => _BusinessDetailsPageState();
}

class _BusinessDetailsPageState extends State<BusinessDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBusiness();
    });
  }

  void _loadBusiness() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    if (authProvider.user != null) {
      businessProvider.loadBusiness(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
              if (businessProvider.business != null) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditBusinessPage(business: businessProvider.business!),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<BusinessProvider>(
        builder: (context, businessProvider, child) {
          if (businessProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (businessProvider.business == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.business, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No business profile found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/business-onboarding');
                    },
                    child: const Text('Set Up Business'),
                  ),
                ],
              ),
            );
          }

          final business = businessProvider.business!;

          return RefreshIndicator(
            onRefresh: () async => _loadBusiness(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Business Header Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          if (business.logoUrl != null)
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(business.logoUrl!),
                            )
                          else
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              child: Text(
                                business.businessName.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          Text(
                            business.businessName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (business.tradeName != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              business.tradeName!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getBusinessTypeName(business.businessType),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // GST & Tax Details
                  _buildSectionCard(
                    'GST & Tax Details',
                    Icons.receipt_long,
                    [
                      _buildDetailRow('GSTIN', business.gstin),
                      if (business.pan != null) _buildDetailRow('PAN', business.pan!),
                      if (business.tan != null) _buildDetailRow('TAN', business.tan!),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Contact Information
                  _buildSectionCard(
                    'Contact Information',
                    Icons.contact_phone,
                    [
                      _buildDetailRow('Phone', business.phone),
                      if (business.email != null) _buildDetailRow('Email', business.email!),
                      if (business.website != null) _buildDetailRow('Website', business.website!),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Address
                  _buildSectionCard(
                    'Address',
                    Icons.location_on,
                    [
                      _buildDetailRow('Address', business.address),
                      if (business.city != null) _buildDetailRow('City', business.city!),
                      if (business.state != null) _buildDetailRow('State', business.state!),
                      if (business.pincode != null) _buildDetailRow('Pincode', business.pincode!),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Bank Accounts
                  if (business.bankAccounts.isNotEmpty)
                    _buildSectionCard(
                      'Bank Accounts',
                      Icons.account_balance,
                      business.bankAccounts.map((bank) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow('Bank', bank.bankName),
                            _buildDetailRow('Account Holder', bank.accountHolderName),
                            _buildDetailRow('Account Number', '****${bank.accountNumber.substring(bank.accountNumber.length - 4)}'),
                            _buildDetailRow('IFSC', bank.ifscCode),
                            if (bank.branchName != null) _buildDetailRow('Branch', bank.branchName!),
                            if (bank.isPrimary)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
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
                          ],
                        );
                      }).toList(),
                    ),
                  
                  if (business.upiId != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.qr_code, color: AppColors.primary),
                        title: const Text('UPI ID'),
                        subtitle: Text(business.upiId!),
                      ),
                    ),
                  ],

                  // Terms & Conditions
                  if (business.termsAndConditions != null || business.paymentTerms != null) ...[
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      'Terms & Conditions',
                      Icons.description,
                      [
                        if (business.paymentTerms != null)
                          _buildDetailRow('Payment Terms', business.paymentTerms!),
                        if (business.termsAndConditions != null)
                          _buildDetailRow('Terms', business.termsAndConditions!),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getBusinessTypeName(BusinessType type) {
    switch (type) {
      case BusinessType.soleProprietor:
        return 'Sole Proprietor';
      case BusinessType.partnership:
        return 'Partnership';
      case BusinessType.llp:
        return 'LLP';
      case BusinessType.privateLimited:
        return 'Private Limited';
      case BusinessType.publicLimited:
        return 'Public Limited';
      case BusinessType.other:
        return 'Other';
    }
  }
}

