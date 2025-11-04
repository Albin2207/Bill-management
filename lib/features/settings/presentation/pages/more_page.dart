import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          return ListView(
            children: [
              // Profile Section
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        (user?.displayName != null && user!.displayName!.isNotEmpty)
                            ? user.displayName!.substring(0, 1).toUpperCase()
                            : 'U',
                        style: TextStyle(
                          color: AppColors.onPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
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
                              color: AppColors.onBackground,
                            ),
                          ),
                          if (user?.email != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              user!.email!,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.onBackground.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
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
                  Navigator.pushNamed(context, AppRouter.businessProfile);
                },
              ),
              _buildListTile(
                context,
                icon: Icons.image,
                title: 'Business Logo',
                subtitle: 'Upload your business logo',
                onTap: () {},
              ),
              
              const Divider(height: 1),
              
              // Documents Section
              _buildSectionTitle('Documents'),
              _buildListTile(
                context,
                icon: Icons.description,
                title: 'E-Way Bill',
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.eWayBill);
                },
              ),
              _buildListTile(
                context,
                icon: Icons.receipt_long,
                title: 'E-Invoice',
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.eInvoice);
                },
              ),
              _buildListTile(
                context,
                icon: Icons.payment,
                title: 'Payments Timeline',
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.paymentsTimeline);
                },
              ),
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
                icon: Icons.description,
                title: 'Invoice Templates',
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.invoiceTemplates);
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
                icon: Icons.settings,
                title: 'App Settings',
                subtitle: 'Theme, Notifications, etc.',
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.settings);
                },
              ),
              _buildListTile(
                context,
                icon: Icons.backup,
                title: 'Backup & Restore',
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.backupRestore);
                },
              ),
              _buildListTile(
                context,
                icon: Icons.security,
                title: 'Privacy & Security',
                onTap: () {},
              ),
              
              const Divider(height: 1),
              
              // Support Section
              _buildSectionTitle('Support'),
              _buildListTile(
                context,
                icon: Icons.help_outline,
                title: 'Help & FAQ',
                onTap: () {},
              ),
              _buildListTile(
                context,
                icon: Icons.chat,
                title: 'WhatsApp Support',
                onTap: () {},
              ),
              _buildListTile(
                context,
                icon: Icons.email,
                title: 'Contact Us',
                onTap: () {},
              ),
              _buildListTile(
                context,
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'Version 1.0.0',
                onTap: () {},
              ),
              
              const SizedBox(height: 20),
              
              // Logout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await authProvider.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed(AppRouter.login);
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.onBackground.withOpacity(0.6),
          letterSpacing: 0.5,
        ),
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
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

