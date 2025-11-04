import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/party_entity.dart';
import '../../../invoice/domain/entities/invoice_entity.dart';
import '../../../invoice/presentation/providers/invoice_provider.dart';
import '../../../payment/domain/entities/payment_entity.dart';
import '../../../payment/presentation/providers/payment_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/app_colors.dart';
import 'edit_party_page.dart';

class PartyDetailPage extends StatefulWidget {
  final PartyEntity party;

  const PartyDetailPage({
    super.key,
    required this.party,
  });

  @override
  State<PartyDetailPage> createState() => _PartyDetailPageState();
}

class _PartyDetailPageState extends State<PartyDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<InvoiceEntity> _partyInvoices = [];
  List<PaymentEntity> _partyPayments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    if (authProvider.user != null) {
      await Future.wait([
        invoiceProvider.loadInvoices(authProvider.user!.uid),
        paymentProvider.loadPaymentsByParty(authProvider.user!.uid, widget.party.id),
      ]);

      // Filter invoices for this party
      _partyInvoices = invoiceProvider.invoices
          .where((inv) => inv.partyId == widget.party.id)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _partyPayments = paymentProvider.partyPayments;
    }

    setState(() => _isLoading = false);
  }

  // Calculate financial metrics
  double get _totalSales {
    return _partyInvoices
        .where((inv) => _isSalesDocument(inv.invoiceType) && inv.paymentStatus != PaymentStatus.cancelled)
        .fold(0.0, (sum, inv) => sum + inv.grandTotal);
  }

  double get _totalPurchases {
    return _partyInvoices
        .where((inv) => _isPurchaseDocument(inv.invoiceType) && inv.paymentStatus != PaymentStatus.cancelled)
        .fold(0.0, (sum, inv) => sum + inv.grandTotal);
  }

  double get _totalReceived {
    return _partyPayments
        .where((p) => p.direction == PaymentDirection.inward)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  double get _totalPaid {
    return _partyPayments
        .where((p) => p.direction == PaymentDirection.outward)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  double get _outstandingReceivable {
    return _totalSales - _totalReceived;
  }

  double get _outstandingPayable {
    return _totalPurchases - _totalPaid;
  }

  double get _netBalance {
    return _outstandingReceivable - _outstandingPayable;
  }

  bool _isSalesDocument(InvoiceType type) {
    return type == InvoiceType.invoice ||
        type == InvoiceType.salesOrder ||
        type == InvoiceType.deliveryChalan ||
        type == InvoiceType.creditNote;
  }

  bool _isPurchaseDocument(InvoiceType type) {
    return type == InvoiceType.bill ||
        type == InvoiceType.purchaseOrder ||
        type == InvoiceType.debitNote;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.party.name),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPartyPage(party: widget.party),
                ),
              );
              if (result == true && mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Party Info Card
                    _buildPartyInfoCard(),
                    const SizedBox(height: 16),

                    // Financial Summary Card
                    _buildFinancialSummaryCard(),
                    const SizedBox(height: 16),

                    // Outstanding Card
                    _buildOutstandingCard(),
                    const SizedBox(height: 24),

                    // Tabs Section
                    _buildTabsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPartyInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _getPartyColor(widget.party.partyType),
                  backgroundImage: widget.party.imageUrl != null
                      ? NetworkImage(widget.party.imageUrl!)
                      : null,
                  child: widget.party.imageUrl == null
                      ? Text(
                          widget.party.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.party.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getPartyColor(widget.party.partyType).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getPartyTypeLabel(widget.party.partyType),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getPartyColor(widget.party.partyType),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (widget.party.phoneNumber != null) ...[
              _buildInfoRow(Icons.phone, 'Phone', widget.party.phoneNumber!),
              const SizedBox(height: 12),
            ],
            if (widget.party.email != null) ...[
              _buildInfoRow(Icons.email, 'Email', widget.party.email!),
              const SizedBox(height: 12),
            ],
            if (widget.party.gstin != null) ...[
              _buildInfoRow(Icons.receipt_long, 'GSTIN', widget.party.gstin!),
              const SizedBox(height: 12),
            ],
            if (widget.party.address != null) ...[
              _buildInfoRow(Icons.location_on, 'Address', widget.party.address!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildMetricColumn(
                    'Total Sales',
                    _totalSales,
                    Colors.green,
                    Icons.arrow_upward,
                  ),
                ),
                Container(width: 1, height: 50, color: Colors.grey[300]),
                Expanded(
                  child: _buildMetricColumn(
                    'Total Purchases',
                    _totalPurchases,
                    Colors.blue,
                    Icons.arrow_downward,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildMetricColumn(
                    'Received',
                    _totalReceived,
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                Container(width: 1, height: 50, color: Colors.grey[300]),
                Expanded(
                  child: _buildMetricColumn(
                    'Paid',
                    _totalPaid,
                    Colors.red,
                    Icons.payment,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutstandingCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _netBalance >= 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              _netBalance >= 0 ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Text(
              'Outstanding Balance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            if (_outstandingReceivable > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.arrow_downward, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'To Receive',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Text(
                    '₹${_outstandingReceivable.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              if (_outstandingPayable > 0) const Divider(height: 24),
            ],
            if (_outstandingPayable > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.arrow_upward, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'To Pay',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Text(
                    '₹${_outstandingPayable.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
            if (_outstandingReceivable == 0 && _outstandingPayable == 0) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 8),
              const Text(
                'All Settled!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
            if (_netBalance != 0 && (_outstandingReceivable > 0 || _outstandingPayable > 0)) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Net ${_netBalance >= 0 ? "Receivable" : "Payable"}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹${_netBalance.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _netBalance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabsSection() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Transactions'),
            Tab(text: 'Payments'),
            Tab(text: 'Statistics'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTransactionsTab(),
              _buildPaymentsTab(),
              _buildStatisticsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsTab() {
    if (_partyInvoices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No transactions yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _partyInvoices.length,
      itemBuilder: (context, index) {
        final invoice = _partyInvoices[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getInvoiceTypeColor(invoice.invoiceType),
              child: Icon(
                _getInvoiceTypeIcon(invoice.invoiceType),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              invoice.invoiceNumber,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.invoiceType.toString().split('.').last.toUpperCase(),
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(invoice.invoiceDate),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${invoice.grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(invoice.paymentStatus).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    invoice.paymentStatus.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStatusColor(invoice.paymentStatus),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {
              // Navigate to invoice detail
              Navigator.pushNamed(
                context,
                '/invoice_detail',
                arguments: invoice,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPaymentsTab() {
    if (_partyPayments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No payments yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _partyPayments.length,
      itemBuilder: (context, index) {
        final payment = _partyPayments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: payment.direction == PaymentDirection.inward
                  ? Colors.green
                  : Colors.red,
              child: Icon(
                payment.direction == PaymentDirection.inward
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color: Colors.white,
              ),
            ),
            title: Text(
              payment.documentNumber,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.paymentMethodName,
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(payment.paymentDate),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: Text(
              '₹${payment.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: payment.direction == PaymentDirection.inward
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsTab() {
    final salesCount = _partyInvoices.where((inv) => _isSalesDocument(inv.invoiceType)).length;
    final purchaseCount = _partyInvoices.where((inv) => _isPurchaseDocument(inv.invoiceType)).length;
    final paymentCount = _partyPayments.length;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildStatCard('Total Transactions', _partyInvoices.length.toString(), Icons.receipt, Colors.blue),
          const SizedBox(height: 12),
          _buildStatCard('Sales Documents', salesCount.toString(), Icons.shopping_cart, Colors.green),
          const SizedBox(height: 12),
          _buildStatCard('Purchase Documents', purchaseCount.toString(), Icons.shopping_bag, Colors.orange),
          const SizedBox(height: 12),
          _buildStatCard('Payments Made', paymentCount.toString(), Icons.payment, Colors.purple),
          const SizedBox(height: 12),
          _buildStatCard(
            'Average Transaction',
            _partyInvoices.isEmpty
                ? '₹0'
                : '₹${((_totalSales + _totalPurchases) / _partyInvoices.length).toStringAsFixed(2)}',
            Icons.trending_up,
            Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(label),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricColumn(String label, double amount, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getPartyColor(PartyType type) {
    switch (type) {
      case PartyType.customer:
        return Colors.green;
      case PartyType.vendor:
        return Colors.blue;
      case PartyType.both:
        return Colors.purple;
    }
  }

  String _getPartyTypeLabel(PartyType type) {
    switch (type) {
      case PartyType.customer:
        return 'Customer';
      case PartyType.vendor:
        return 'Vendor';
      case PartyType.both:
        return 'Both';
    }
  }

  Color _getInvoiceTypeColor(InvoiceType type) {
    if (_isSalesDocument(type)) return Colors.green;
    if (_isPurchaseDocument(type)) return Colors.blue;
    return Colors.grey;
  }

  IconData _getInvoiceTypeIcon(InvoiceType type) {
    switch (type) {
      case InvoiceType.invoice:
        return Icons.receipt;
      case InvoiceType.bill:
        return Icons.shopping_bag;
      case InvoiceType.salesOrder:
        return Icons.shopping_cart;
      case InvoiceType.purchaseOrder:
        return Icons.shopping_basket;
      default:
        return Icons.description;
    }
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.unpaid:
        return Colors.red;
      case PaymentStatus.partial:
        return Colors.orange;
      case PaymentStatus.cancelled:
        return Colors.grey;
      case PaymentStatus.pending:
        return Colors.blue;
    }
  }
}

