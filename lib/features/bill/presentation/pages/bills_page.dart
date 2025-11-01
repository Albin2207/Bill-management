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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.onPrimary,
          labelColor: AppColors.onPrimary,
          unselectedLabelColor: AppColors.onPrimary.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Sales'),
            Tab(text: 'Purchases'),
            Tab(text: 'Quotation'),
            Tab(text: 'More'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSalesTab(),
          _buildPurchasesTab(),
          _buildQuotationTab(),
          _buildMoreTab(),
        ],
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
          subtitle: 'Create sales invoice',
          color: Colors.blue,
          onTap: () => Navigator.pushNamed(context, AppRouter.createInvoice),
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
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
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

