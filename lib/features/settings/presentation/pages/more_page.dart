import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../business/presentation/providers/business_provider.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.user;
            return ListView(
              children: [
                // Modern Profile Section with Glassmorphism
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.9),
                        AppColors.primaryDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)],
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                child: Text(
                                  (user?.displayName != null && user!.displayName!.isNotEmpty)
                                      ? user.displayName!.substring(0, 1).toUpperCase()
                                      : 'U',
                                  style: TextStyle(
                                    color: AppColors.onPrimary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.displayName ?? 'User',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onPrimary,
                                    ),
                                  ),
                                  if (user?.email != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      user!.email!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.onPrimary.withOpacity(0.8),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
              
              // Business Profile
              _buildSectionTitle('Business Profile'),
              _buildListTile(
                context,
                icon: Icons.business,
                title: 'Business Details',
                subtitle: 'GSTIN, Address, Contact',
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.businessDetails);
                },
              ),
              _buildListTile(
                context,
                icon: Icons.image,
                title: 'Business Logo',
                subtitle: 'Upload your business logo',
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.businessLogo);
                },
              ),
              
              const Divider(height: 1),
              
              // Documents Section
              _buildSectionTitle('Documents'),
              _buildListTile(
                context,
                icon: Icons.assessment,
                title: 'Reports',
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.reports);
                },
              ),
              _buildListTile(
                context,
                icon: Icons.insights,
                title: 'Insights',
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.insights);
                },
              ),
              _buildListTile(
                context,
                icon: Icons.settings,
                title: 'Document Settings',
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.documentSettings);
                },
              ),
              
              const Divider(height: 1),
              
              // Account & Bookkeeping Section
              _buildSectionTitle('Account & Bookkeeping'),
              _buildListTile(
                context,
                icon: Icons.account_balance,
                title: 'Profit & Loss',
                subtitle: 'P&L Statement',
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.profitLoss);
                },
              ),
              _buildListTile(
                context,
                icon: Icons.book,
                title: 'Ledger',
                subtitle: 'Party-wise account statements',
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.ledger);
                },
              ),
              _buildListTile(
                context,
                icon: Icons.receipt_long,
                title: 'GST Reports',
                subtitle: 'GST collected, paid & summary',
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.gstReport);
                },
              ),
              _buildListTile(
                context,
                icon: Icons.inventory_2,
                title: 'Stock Report',
                subtitle: 'Stock valuation & movements',
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.stockReport);
                },
              ),
              _buildListTile(
                context,
                icon: Icons.balance,
                title: 'Trial Balance',
                subtitle: 'Simplified books balance',
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.trialBalance);
                },
              ),
              
              const Divider(height: 1),
              
              // Settings Section
              _buildSectionTitle('Settings'),
              _buildListTile(
                context,
                icon: Icons.security,
                title: 'Privacy & Security',
                subtitle: 'Privacy policy & data protection',
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.privacyPolicy);
                },
              ),
              
              const Divider(height: 1),
              
              // Support Section
              _buildSectionTitle('Support'),
              _buildListTile(
                context,
                icon: Icons.feedback,
                title: 'Send Feedback',
                subtitle: 'Share your thoughts & suggestions',
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.feedback);
                },
              ),
              _buildListTile(
                context,
                icon: Icons.info_outline,
                title: 'About Us',
                subtitle: 'Learn more about the app',
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
              
              const SizedBox(height: 20),
              
              // Logout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // Show confirmation dialog
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirmed == true && context.mounted) {
                      // Clear all provider data before logout
                      final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
                      businessProvider.clearBusiness();
                      
                      // Sign out
                      await authProvider.signOut();
                      
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed(AppRouter.login);
                      }
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              )
            : null,
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.chevron_right,
            color: AppColors.primary,
            size: 18,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Image.asset(
              'assets/billing-management-logo.png',
              width: 36,
              height: 36,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            const Text('About'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Billing Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'A comprehensive billing and business management solution designed to simplify invoicing, inventory management, and financial tracking for small and medium businesses.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.verified, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                const Text('Version 1.0.0', style: TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.code, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                const Text('Built with Flutter', style: TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.copyright, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                const Text('© 2025 Growblic', style: TextStyle(fontSize: 13)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

