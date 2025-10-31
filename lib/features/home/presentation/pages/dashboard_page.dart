import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/navigation/app_router.dart';
import '../widgets/stat_card.dart';
import '../widgets/quick_action_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GST Billing'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final user = authProvider.user;
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.onPrimary,
                        child: Text(
                          user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 24,
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
                              'Welcome, ${user?.displayName ?? "User"}!',
                              style: TextStyle(
                                color: AppColors.onPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage your GST billing efficiently',
                              style: TextStyle(
                                color: AppColors.onPrimary.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            
            // Statistics Section
            Text(
              'Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                StatCard(
                  title: 'Total Sales',
                  value: '₹0',
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
                StatCard(
                  title: 'Total Purchase',
                  value: '₹0',
                  icon: Icons.trending_down,
                  color: Colors.blue,
                ),
                StatCard(
                  title: 'Pending Invoices',
                  value: '0',
                  icon: Icons.pending,
                  color: Colors.orange,
                ),
                StatCard(
                  title: 'GST Liability',
                  value: '₹0',
                  icon: Icons.account_balance,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                QuickActionCard(
                  title: 'Create Invoice',
                  icon: Icons.receipt_long,
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.createInvoice);
                  },
                ),
                QuickActionCard(
                  title: 'Create Bill',
                  icon: Icons.receipt,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.createBill);
                  },
                ),
                QuickActionCard(
                  title: 'Parties',
                  icon: Icons.people,
                  color: Colors.green,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.parties);
                  },
                ),
                QuickActionCard(
                  title: 'Products',
                  icon: Icons.inventory_2,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.products);
                  },
                ),
                QuickActionCard(
                  title: 'Reports',
                  icon: Icons.assessment,
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.reports);
                  },
                ),
                QuickActionCard(
                  title: 'GST Returns',
                  icon: Icons.description,
                  color: Colors.red,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.gstReturns);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Recent Transactions
            Text(
              'Recent Invoices',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.onBackground.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  _buildEmptyState(
                    icon: Icons.receipt_long,
                    message: 'No invoices yet',
                    subtitle: 'Create your first invoice to get started',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.createInvoice);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('New Invoice'),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final user = authProvider.user;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.onPrimary,
                      child: Text(
                        user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.displayName ?? 'User',
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (user?.email != null)
                      Text(
                        user!.email!,
                        style: TextStyle(
                          color: AppColors.onPrimary.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            route: AppRouter.home,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.receipt_long,
            title: 'Invoices',
            route: AppRouter.invoices,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.receipt,
            title: 'Bills',
            route: AppRouter.bills,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.people,
            title: 'Parties',
            route: AppRouter.parties,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.inventory_2,
            title: 'Products',
            route: AppRouter.products,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.account_balance_wallet,
            title: 'Ledger',
            route: AppRouter.ledger,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.assessment,
            title: 'Reports',
            route: AppRouter.reports,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.description,
            title: 'GST Returns',
            route: AppRouter.gstReturns,
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            route: AppRouter.settings,
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, route);
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.onBackground.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.onBackground.withOpacity(0.7),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onBackground.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed(AppRouter.login);
    }
  }
}

