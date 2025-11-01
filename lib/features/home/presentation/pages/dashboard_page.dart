import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../invoice/presentation/providers/invoice_provider.dart';
import '../../../invoice/domain/entities/invoice_entity.dart';
import '../../../../core/navigation/app_router.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/document_type_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _selectedDateFilter = 'Today';
  final List<String> _dateFilters = [
    'Today',
    'Yesterday',
    'This Week',
    'Last Week',
    'This Month',
    'Last Month',
    'This Year',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  void _loadDashboardData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    
    final userId = authProvider.user?.uid;
    if (userId != null) {
      invoiceProvider.loadInvoices(userId);
    }
  }

  List<InvoiceEntity> _getFilteredInvoices(List<InvoiceEntity> invoices) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (_selectedDateFilter) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
        endDate = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
        break;
      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'Last Week':
        final lastWeek = now.subtract(Duration(days: now.weekday + 6));
        startDate = DateTime(lastWeek.year, lastWeek.month, lastWeek.day);
        endDate = startDate.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Last Month':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        startDate = lastMonth;
        endDate = DateTime(now.year, now.month, 0, 23, 59, 59);
        break;
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day);
    }

    return invoices.where((invoice) {
      return invoice.invoiceDate.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
             invoice.invoiceDate.isBefore(endDate.add(const Duration(seconds: 1)));
    }).toList();
  }

  double _calculateSales(List<InvoiceEntity> invoices) {
    return invoices
        .where((i) => i.invoiceType == InvoiceType.invoice && 
                     i.paymentStatus != PaymentStatus.cancelled)
        .fold(0.0, (sum, invoice) => sum + invoice.grandTotal);
  }

  double _calculatePurchases(List<InvoiceEntity> invoices) {
    return invoices
        .where((i) => i.invoiceType == InvoiceType.bill && 
                     i.paymentStatus != PaymentStatus.cancelled)
        .fold(0.0, (sum, invoice) => sum + invoice.grandTotal);
  }

  double _calculateTotalRevenue(List<InvoiceEntity> invoices) {
    return invoices
        .where((i) => i.paymentStatus == PaymentStatus.paid)
        .fold(0.0, (sum, invoice) => sum + invoice.grandTotal);
  }

  double _calculateGSTCollected(List<InvoiceEntity> invoices) {
    return invoices
        .where((i) => i.invoiceType == InvoiceType.invoice && 
                     i.paymentStatus == PaymentStatus.paid)
        .fold(0.0, (sum, invoice) => sum + invoice.totalTax);
  }

  double _calculateReceivables(List<InvoiceEntity> invoices) {
    return invoices
        .where((i) => i.invoiceType == InvoiceType.invoice && 
                     i.paymentStatus != PaymentStatus.paid &&
                     i.paymentStatus != PaymentStatus.cancelled)
        .fold(0.0, (sum, invoice) => sum + invoice.balanceAmount);
  }

  double _calculatePayables(List<InvoiceEntity> invoices) {
    return invoices
        .where((i) => i.invoiceType == InvoiceType.bill && 
                     i.paymentStatus != PaymentStatus.paid &&
                     i.paymentStatus != PaymentStatus.cancelled)
        .fold(0.0, (sum, invoice) => sum + invoice.balanceAmount);
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final filteredInvoices = _getFilteredInvoices(invoiceProvider.invoices);
    
    final salesAmount = _calculateSales(filteredInvoices);
    final purchasesAmount = _calculatePurchases(filteredInvoices);
    final totalRevenue = _calculateTotalRevenue(filteredInvoices);
    final gstCollected = _calculateGSTCollected(filteredInvoices);
    final receivables = _calculateReceivables(invoiceProvider.invoices); // All time
    final payables = _calculatePayables(invoiceProvider.invoices); // All time
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
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
                          (user?.displayName != null && user!.displayName!.isNotEmpty)
                              ? user.displayName!.substring(0, 1).toUpperCase()
                              : 'U',
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
            
            // Date Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Business Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onBackground,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDateFilter,
                      isDense: true,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      items: _dateFilters.map((filter) {
                        return DropdownMenuItem(
                          value: filter,
                          child: Text(filter),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDateFilter = value!;
                        });
                        // TODO: Reload data based on filter
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTodayStatCard(
                    'Sales',
                    '₹${salesAmount.toStringAsFixed(2)}',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTodayStatCard(
                    'Purchases',
                    '₹${purchasesAmount.toStringAsFixed(2)}',
                    Icons.shopping_cart,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickButton(
                    context,
                    'New Bill',
                    Icons.add,
                    AppColors.primary,
                    () {
                      Navigator.pushNamed(context, AppRouter.createBill);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickButton(
                    context,
                    'Add Product',
                    Icons.inventory_2,
                    Colors.green,
                    () {
                      Navigator.pushNamed(context, AppRouter.addProduct);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickButton(
                    context,
                    'Add Party',
                    Icons.person_add,
                    Colors.orange,
                    () {
                      Navigator.pushNamed(context, AppRouter.addParty);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Create Documents Section
            Text(
              'Create',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                DocumentTypeCard(
                  title: 'Invoice',
                  icon: Icons.receipt_long,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.invoices);
                  },
                ),
                DocumentTypeCard(
                  title: 'Purchase',
                  icon: Icons.shopping_cart,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.createPurchase);
                  },
                ),
                DocumentTypeCard(
                  title: 'Quotation',
                  icon: Icons.description,
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.createQuotation);
                  },
                ),
                DocumentTypeCard(
                  title: 'Sales Order',
                  icon: Icons.point_of_sale,
                  color: Colors.cyan,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.createSalesOrder);
                  },
                ),
                DocumentTypeCard(
                  title: 'Delivery Challan',
                  icon: Icons.local_shipping,
                  color: Colors.teal,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.createDeliveryChallan);
                  },
                ),
                DocumentTypeCard(
                  title: 'Credit Note',
                  icon: Icons.credit_card,
                  color: Colors.green,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.createCreditNote);
                  },
                ),
                DocumentTypeCard(
                  title: 'Debit Note',
                  icon: Icons.card_giftcard,
                  color: Colors.pink,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.createDebitNote);
                  },
                ),
                DocumentTypeCard(
                  title: 'Purchase Order',
                  icon: Icons.shopping_bag,
                  color: Colors.deepOrange,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.createPurchaseOrder);
                  },
                ),
                DocumentTypeCard(
                  title: 'Expenses',
                  icon: Icons.account_balance_wallet,
                  color: Colors.red,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.createExpense);
                  },
                ),
                DocumentTypeCard(
                  title: 'Indirect Income',
                  icon: Icons.attach_money,
                  color: Colors.lightGreen,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.createIndirectIncome);
                  },
                ),
                DocumentTypeCard(
                  title: 'Pro Forma',
                  icon: Icons.insert_drive_file,
                  color: Colors.indigo,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.createProForma);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Quick Access Section
            Text(
              'Quick Access',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.8,
              children: [
                QuickActionCard(
                  title: 'E-Way Bill',
                  icon: Icons.description,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.eWayBill);
                  },
                ),
                QuickActionCard(
                  title: 'E-Invoice',
                  icon: Icons.receipt_long,
                  color: Colors.green,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.eInvoice);
                  },
                ),
                QuickActionCard(
                  title: 'Payments Timeline',
                  icon: Icons.payment,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.paymentsTimeline);
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
                  title: 'Insights',
                  icon: Icons.insights,
                  color: Colors.teal,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.insights);
                  },
                ),
                QuickActionCard(
                  title: 'Invoice Templates',
                  icon: Icons.insert_drive_file,
                  color: Colors.indigo,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.invoiceTemplates);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Analytics Summary
            Text(
              'Analytics Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 12),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAnalyticsItem('Total Revenue', '₹${totalRevenue.toStringAsFixed(2)}', Icons.trending_up),
                      _buildAnalyticsItem('GST Collected', '₹${gstCollected.toStringAsFixed(2)}', Icons.account_balance),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAnalyticsItem('Receivables', '₹${receivables.toStringAsFixed(2)}', Icons.call_received, color: Colors.orange),
                      _buildAnalyticsItem('Payables', '₹${payables.toStringAsFixed(2)}', Icons.call_made, color: Colors.red),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Pending Payments Widget
            Text(
              'Pending Payments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 12),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Receivable',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onBackground,
                        ),
                      ),
                      Text(
                        '₹0',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payable',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onBackground,
                        ),
                      ),
                      Text(
                        '₹0',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Recent Bills List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Bills',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onBackground,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.bills);
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.onBackground.withOpacity(0.1),
                ),
              ),
              child: _buildEmptyState(
                icon: Icons.receipt,
                message: 'No bills yet',
                subtitle: 'Create your first bill to get started',
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.onBackground.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.onBackground.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsItem(String label, String value, IconData icon, {Color? color}) {
    final iconColor = color ?? AppColors.primary;
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.onBackground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.onBackground.withOpacity(0.6),
          ),
        ),
      ],
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
            size: 48,
            color: AppColors.onBackground.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.onBackground.withOpacity(0.7),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
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
}
