import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/app_router.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.onPrimary,
          indicatorWeight: 3,
          labelColor: AppColors.onPrimary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelColor: AppColors.onPrimary.withOpacity(0.7),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          tabs: const [
            Tab(text: 'Sales'),
            Tab(text: 'Purchases'),
            Tab(text: 'Quotation'),
            Tab(text: 'More'),
          ],
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
        child: TabBarView(
        controller: _tabController,
        children: [
          _buildSalesTab(),
          _buildPurchasesTab(),
          _buildQuotationTab(),
          _buildMoreTab(),
        ],
        ),
      ),
    );
  }

  Widget _buildSalesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDocumentTypeButton(
          icon: Icons.receipt_long,
          label: 'Invoice',
          subtitle: 'View & create sales invoices',
          color: Colors.blue,
          onTap: () => Navigator.pushNamed(context, AppRouter.invoices),
        ),
        const SizedBox(height: 12),
        _buildDocumentTypeButton(
          icon: Icons.point_of_sale,
          label: 'Sales Order',
          subtitle: 'Create sales order',
          color: Colors.cyan,
          onTap: () => Navigator.pushNamed(context, AppRouter.createSalesOrder),
        ),
        const SizedBox(height: 12),
        _buildDocumentTypeButton(
          icon: Icons.credit_card,
          label: 'Credit Note',
          subtitle: 'Issue credit note',
          color: Colors.green,
          onTap: () => Navigator.pushNamed(context, AppRouter.createCreditNote),
        ),
        const SizedBox(height: 12),
        _buildDocumentTypeButton(
          icon: Icons.insert_drive_file,
          label: 'Pro Forma Invoice',
          subtitle: 'Create pro forma invoice',
          color: Colors.indigo,
          onTap: () => Navigator.pushNamed(context, AppRouter.createProForma),
        ),
        const SizedBox(height: 24),
        const Text(
          'Recent Sales Documents',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildEmptyState('No sales documents yet'),
      ],
    );
  }

  Widget _buildPurchasesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDocumentTypeButton(
          icon: Icons.shopping_cart,
          label: 'Purchase',
          subtitle: 'Create purchase bill',
          color: Colors.orange,
          onTap: () => Navigator.pushNamed(context, AppRouter.createPurchase),
        ),
        const SizedBox(height: 12),
        _buildDocumentTypeButton(
          icon: Icons.shopping_bag,
          label: 'Purchase Order',
          subtitle: 'Create purchase order',
          color: Colors.deepOrange,
          onTap: () => Navigator.pushNamed(context, AppRouter.createPurchaseOrder),
        ),
        const SizedBox(height: 12),
        _buildDocumentTypeButton(
          icon: Icons.card_giftcard,
          label: 'Debit Note',
          subtitle: 'Issue debit note',
          color: Colors.pink,
          onTap: () => Navigator.pushNamed(context, AppRouter.createDebitNote),
        ),
        const SizedBox(height: 24),
        const Text(
          'Recent Purchase Documents',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildEmptyState('No purchase documents yet'),
      ],
    );
  }

  Widget _buildQuotationTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDocumentTypeButton(
          icon: Icons.description,
          label: 'Quotation',
          subtitle: 'Create quotation',
          color: Colors.purple,
          onTap: () => Navigator.pushNamed(context, AppRouter.createQuotation),
        ),
        const SizedBox(height: 24),
        const Text(
          'Recent Quotations',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildEmptyState('No quotations yet'),
      ],
    );
  }

  Widget _buildMoreTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Other Documents',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildDocumentTypeButton(
          icon: Icons.local_shipping,
          label: 'Delivery Challan',
          subtitle: 'Create delivery challan',
          color: Colors.teal,
          onTap: () => Navigator.pushNamed(context, AppRouter.createDeliveryChallan),
        ),
        const SizedBox(height: 12),
        _buildDocumentTypeButton(
          icon: Icons.account_balance_wallet,
          label: 'Expenses',
          subtitle: 'Record expenses',
          color: Colors.red,
          onTap: () => Navigator.pushNamed(context, AppRouter.createExpense),
        ),
        const SizedBox(height: 12),
        _buildDocumentTypeButton(
          icon: Icons.attach_money,
          label: 'Indirect Income',
          subtitle: 'Record other income',
          color: Colors.lightGreen,
          onTap: () => Navigator.pushNamed(context, AppRouter.createIndirectIncome),
        ),
        const SizedBox(height: 24),
        const Text(
          'Recent Documents',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildEmptyState('No other documents yet'),
      ],
    );
  }

  Widget _buildDocumentTypeButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: Card(
        elevation: 2,
        shadowColor: color.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_forward_ios, size: 14, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: AppColors.onBackground.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: AppColors.onBackground.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

