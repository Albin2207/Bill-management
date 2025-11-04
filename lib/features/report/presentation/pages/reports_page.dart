import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../invoice/presentation/providers/invoice_provider.dart';
import '../../../payment/presentation/providers/payment_provider.dart';
import '../../../party/presentation/providers/party_provider.dart';
import '../../../invoice/domain/entities/invoice_entity.dart';
import '../../../payment/domain/entities/payment_entity.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'This Month';
  final List<String> _periods = [
    'This Week',
    'This Month',
    'Last Month',
    'This Year',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    final partyProvider = Provider.of<PartyProvider>(context, listen: false);
    
    final userId = authProvider.user?.uid;
    if (userId != null) {
      invoiceProvider.loadInvoices(userId);
      paymentProvider.loadAllPayments(userId);
      partyProvider.loadParties(userId);
    }
  }

  List<InvoiceEntity> _getFilteredInvoices(List<InvoiceEntity> invoices) {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Last Month':
        startDate = DateTime(now.year, now.month - 1, 1);
        break;
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, 1);
    }

    return invoices.where((invoice) {
      return invoice.invoiceDate.isAfter(startDate.subtract(const Duration(seconds: 1)));
    }).toList();
  }

  List<PaymentEntity> _getFilteredPayments(List<PaymentEntity> payments) {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Last Month':
        startDate = DateTime(now.year, now.month - 1, 1);
        break;
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, 1);
    }

    return payments.where((payment) {
      return payment.paymentDate.isAfter(startDate.subtract(const Duration(seconds: 1)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final filteredInvoices = _getFilteredInvoices(invoiceProvider.invoices);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.onPrimary,
          labelColor: AppColors.onPrimary,
          unselectedLabelColor: AppColors.onPrimary.withOpacity(0.7),
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Sales'),
            Tab(text: 'Purchases'),
            Tab(text: 'GST'),
            Tab(text: 'Payments'),
            Tab(text: 'Parties'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Period Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Report Period',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
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
                      value: _selectedPeriod,
                      isDense: true,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      items: _periods.map((period) {
                        return DropdownMenuItem(
                          value: period,
                          child: Text(period),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPeriod = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tab Views
          Expanded(
            child: Consumer<PaymentProvider>(
              builder: (context, paymentProvider, child) {
                final filteredPayments = _getFilteredPayments(paymentProvider.allPayments);
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewReport(filteredInvoices, filteredPayments),
                    _buildSalesReport(filteredInvoices),
                    _buildPurchasesReport(filteredInvoices),
                    _buildGSTReport(filteredInvoices),
                    _buildPaymentsReport(filteredPayments),
                    _buildPartiesReport(filteredInvoices),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewReport(List<InvoiceEntity> invoices, List<PaymentEntity> payments) {
    // Sales Documents
    final salesDocs = invoices.where((i) => 
      i.invoiceType == InvoiceType.invoice || 
      i.invoiceType == InvoiceType.salesOrder ||
      i.invoiceType == InvoiceType.proFormaInvoice
    ).toList();
    
    // Purchase Documents
    final purchaseDocs = invoices.where((i) => 
      i.invoiceType == InvoiceType.bill ||
      i.invoiceType == InvoiceType.purchaseOrder
    ).toList();
    
    // Other Documents
    final quotations = invoices.where((i) => i.invoiceType == InvoiceType.quotation).toList();
    final deliveryChallans = invoices.where((i) => i.invoiceType == InvoiceType.deliveryChalan).toList();
    final creditNotes = invoices.where((i) => i.invoiceType == InvoiceType.creditNote).toList();
    final debitNotes = invoices.where((i) => i.invoiceType == InvoiceType.debitNote).toList();
    final expenses = invoices.where((i) => i.invoiceType == InvoiceType.expense).toList();
    final indirectIncome = invoices.where((i) => i.invoiceType == InvoiceType.indirectIncome).toList();
    
    final totalSales = salesDocs.fold(0.0, (sum, i) => sum + i.grandTotal);
    final totalPurchases = purchaseDocs.fold(0.0, (sum, i) => sum + i.grandTotal);
    final totalExpenses = expenses.fold(0.0, (sum, i) => sum + i.grandTotal);
    final totalIncome = indirectIncome.fold(0.0, (sum, i) => sum + i.grandTotal);
    final profit = totalSales + totalIncome - totalPurchases - totalExpenses;
    
    final paidInvoices = invoices.where((i) => i.paymentStatus == PaymentStatus.paid).length;
    final pendingInvoices = invoices.where((i) => i.paymentStatus == PaymentStatus.pending).length;
    final unpaidInvoices = invoices.where((i) => i.paymentStatus == PaymentStatus.unpaid).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _buildReportCard(
                'Total Sales',
                '₹${totalSales.toStringAsFixed(2)}',
                Colors.green,
                Icons.trending_up,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildReportCard(
                'Total Purchases',
                '₹${totalPurchases.toStringAsFixed(2)}',
                Colors.orange,
                Icons.shopping_cart,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildReportCard(
          'Profit/Loss',
          '₹${profit.toStringAsFixed(2)}',
          profit >= 0 ? Colors.blue : Colors.red,
          profit >= 0 ? Icons.trending_up : Icons.trending_down,
        ),
        const SizedBox(height: 24),
        const Text(
          'Document Summary',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sales Documents',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildDocCountRow('Invoices', salesDocs.length, Icons.receipt_long, Colors.blue),
                const SizedBox(height: 8),
                const Divider(height: 16),
                const Text(
                  'Purchase Documents',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildDocCountRow('Purchases', purchaseDocs.length, Icons.shopping_cart, Colors.orange),
                const SizedBox(height: 8),
                const Divider(height: 16),
                const Text(
                  'Other Documents',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildDocCountRow('Quotations', quotations.length, Icons.description, Colors.purple),
                const SizedBox(height: 4),
                _buildDocCountRow('Delivery Challans', deliveryChallans.length, Icons.local_shipping, Colors.teal),
                const SizedBox(height: 4),
                _buildDocCountRow('Credit Notes', creditNotes.length, Icons.credit_card, Colors.green),
                const SizedBox(height: 4),
                _buildDocCountRow('Debit Notes', debitNotes.length, Icons.card_giftcard, Colors.pink),
                const SizedBox(height: 4),
                _buildDocCountRow('Expenses', expenses.length, Icons.account_balance_wallet, Colors.red),
                const SizedBox(height: 4),
                _buildDocCountRow('Indirect Income', indirectIncome.length, Icons.attach_money, Colors.lightGreen),
                const Divider(height: 16),
                _buildDocCountRow('Total Documents', invoices.length, Icons.folder, AppColors.primary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Payment Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatusCard('Paid', paidInvoices, Colors.green),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusCard('Pending', pendingInvoices, Colors.orange),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusCard('Unpaid', unpaidInvoices, Colors.red),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSalesReport(List<InvoiceEntity> invoices) {
    final salesInvoices = invoices.where((i) => 
      i.invoiceType == InvoiceType.invoice || 
      i.invoiceType == InvoiceType.salesOrder ||
      i.invoiceType == InvoiceType.proFormaInvoice
    ).toList();
    final totalSales = salesInvoices.fold(0.0, (sum, i) => sum + i.grandTotal);
    final paidSales = salesInvoices.where((i) => i.paymentStatus == PaymentStatus.paid)
        .fold(0.0, (sum, i) => sum + i.grandTotal);
    final unpaidSales = totalSales - paidSales;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReportCard(
          'Total Sales',
          '₹${totalSales.toStringAsFixed(2)}',
          Colors.blue,
          Icons.trending_up,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildReportCard(
                'Paid',
                '₹${paidSales.toStringAsFixed(2)}',
                Colors.green,
                Icons.check_circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildReportCard(
                'Unpaid',
                '₹${unpaidSales.toStringAsFixed(2)}',
                Colors.red,
                Icons.pending,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Recent Sales',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (salesInvoices.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No sales invoices in this period'),
              ),
            ),
          )
        else
          ...salesInvoices.take(10).map((invoice) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(invoice.invoiceNumber),
              subtitle: Text(invoice.partyName),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(invoice.paymentStatus),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      invoice.paymentStatus.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
      ],
    );
  }

  Widget _buildGSTReport(List<InvoiceEntity> invoices) {
    final salesInvoices = invoices.where((i) => i.invoiceType == InvoiceType.invoice).toList();
    final totalGST = salesInvoices.fold(0.0, (sum, i) => sum + i.totalTax);
    final cgstTotal = salesInvoices.fold(0.0, (sum, i) => sum + i.cgst);
    final sgstTotal = salesInvoices.fold(0.0, (sum, i) => sum + i.sgst);
    final igstTotal = salesInvoices.fold(0.0, (sum, i) => sum + i.igst);
    final gstCollected = salesInvoices.where((i) => i.paymentStatus == PaymentStatus.paid)
        .fold(0.0, (sum, i) => sum + i.totalTax);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReportCard(
          'Total GST',
          '₹${totalGST.toStringAsFixed(2)}',
          AppColors.primary,
          Icons.account_balance,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildReportCard(
                'GST Collected',
                '₹${gstCollected.toStringAsFixed(2)}',
                Colors.green,
                Icons.check_circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildReportCard(
                'GST Pending',
                '₹${(totalGST - gstCollected).toStringAsFixed(2)}',
                Colors.orange,
                Icons.pending,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GST Breakdown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildGSTBreakdownRow('CGST', cgstTotal),
                const SizedBox(height: 8),
                _buildGSTBreakdownRow('SGST', sgstTotal),
                const SizedBox(height: 8),
                _buildGSTBreakdownRow('IGST', igstTotal),
                const Divider(height: 24),
                _buildGSTBreakdownRow('Total', totalGST, isBold: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPurchasesReport(List<InvoiceEntity> invoices) {
    final purchaseInvoices = invoices.where((i) => i.invoiceType == InvoiceType.bill).toList();
    final totalPurchases = purchaseInvoices.fold(0.0, (sum, i) => sum + i.grandTotal);
    final paidPurchases = purchaseInvoices.where((i) => i.paymentStatus == PaymentStatus.paid)
        .fold(0.0, (sum, i) => sum + i.grandTotal);
    final unpaidPurchases = totalPurchases - paidPurchases;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReportCard(
          'Total Purchases',
          '₹${totalPurchases.toStringAsFixed(2)}',
          Colors.orange,
          Icons.shopping_cart,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildReportCard(
                'Paid',
                '₹${paidPurchases.toStringAsFixed(2)}',
                Colors.green,
                Icons.check_circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildReportCard(
                'Unpaid',
                '₹${unpaidPurchases.toStringAsFixed(2)}',
                Colors.red,
                Icons.pending,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Recent Purchases',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (purchaseInvoices.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No purchase invoices in this period'),
              ),
            ),
          )
        else
          ...purchaseInvoices.take(10).map((invoice) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(invoice.invoiceNumber),
              subtitle: Text(invoice.partyName),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(invoice.paymentStatus),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      invoice.paymentStatus.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
      ],
    );
  }

  Widget _buildPartiesReport(List<InvoiceEntity> invoices) {
    // Group by customer
    final Map<String, List<InvoiceEntity>> customerInvoices = {};
    for (final invoice in invoices) {
      if (!customerInvoices.containsKey(invoice.partyId)) {
        customerInvoices[invoice.partyId] = [];
      }
      customerInvoices[invoice.partyId]!.add(invoice);
    }

    // Sort by total amount
    final sortedCustomers = customerInvoices.entries.toList()
      ..sort((a, b) {
        final aTotal = a.value.fold(0.0, (sum, i) => sum + i.grandTotal);
        final bTotal = b.value.fold(0.0, (sum, i) => sum + i.grandTotal);
        return bTotal.compareTo(aTotal);
      });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReportCard(
          'Total Customers',
          '${customerInvoices.length}',
          AppColors.primary,
          Icons.people,
        ),
        const SizedBox(height: 24),
        const Text(
          'Top Customers',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (sortedCustomers.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No customer data in this period'),
              ),
            ),
          )
        else
          ...sortedCustomers.take(10).map((entry) {
            final customerInvs = entry.value;
            final total = customerInvs.fold(0.0, (sum, i) => sum + i.grandTotal);
            final pending = customerInvs
                .where((i) => i.paymentStatus != PaymentStatus.paid && 
                             i.paymentStatus != PaymentStatus.cancelled)
                .fold(0.0, (sum, i) => sum + i.balanceAmount);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customerInvs.first.partyName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (customerInvs.first.partyGstin != null)
                                Text(
                                  'GSTIN: ${customerInvs.first.partyGstin}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.primary,
                              ),
                            ),
                            if (pending > 0)
                              Text(
                                'Pending: ₹${pending.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${customerInvs.length} invoice${customerInvs.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildDocCountRow(String label, int count, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(String label, int count, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(String label, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
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

  Widget _buildGSTBreakdownRow(String label, double amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? AppColors.primary : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentsReport(List<PaymentEntity> payments) {
    final totalReceived = payments
        .where((p) => p.direction == PaymentDirection.inward)
        .fold(0.0, (sum, p) => sum + p.amount);
    
    final totalPaid = payments
        .where((p) => p.direction == PaymentDirection.outward)
        .fold(0.0, (sum, p) => sum + p.amount);
    
    final netCashFlow = totalReceived - totalPaid;

    // Payment method breakdown
    final paymentByMethod = <PaymentMethod, double>{};
    for (var payment in payments) {
      paymentByMethod[payment.method] = (paymentByMethod[payment.method] ?? 0) + payment.amount;
    }

    // Party-wise payments
    final paymentsByParty = <String, Map<String, dynamic>>{};
    for (var payment in payments) {
      if (!paymentsByParty.containsKey(payment.partyId)) {
        paymentsByParty[payment.partyId] = {
          'partyName': payment.partyName,
          'received': 0.0,
          'paid': 0.0,
          'count': 0,
        };
      }
      if (payment.direction == PaymentDirection.inward) {
        paymentsByParty[payment.partyId]!['received'] += payment.amount;
      } else {
        paymentsByParty[payment.partyId]!['paid'] += payment.amount;
      }
      paymentsByParty[payment.partyId]!['count'] += 1;
    }

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cash Flow Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cash Flow Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCashFlowMetric(
                            'Total Received',
                            totalReceived,
                            Icons.arrow_downward,
                            Colors.green,
                          ),
                        ),
                        Container(width: 1, height: 60, color: Colors.grey[300]),
                        Expanded(
                          child: _buildCashFlowMetric(
                            'Total Paid',
                            totalPaid,
                            Icons.arrow_upward,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: netCashFlow >= 0
                              ? [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)]
                              : [Colors.red.withOpacity(0.1), Colors.red.withOpacity(0.05)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                netCashFlow >= 0 ? Icons.trending_up : Icons.trending_down,
                                color: netCashFlow >= 0 ? Colors.green : Colors.red,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Net Cash Flow',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '₹${netCashFlow.abs().toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: netCashFlow >= 0 ? Colors.green : Colors.red,
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

            // Payment Method Breakdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Methods',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...paymentByMethod.entries.map((entry) {
                      final percentage = paymentByMethod.values.fold(0.0, (a, b) => a + b) > 0
                          ? (entry.value / paymentByMethod.values.fold(0.0, (a, b) => a + b) * 100)
                          : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _getPaymentMethodName(entry.key),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  '₹${entry.value.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey[200],
                              color: _getPaymentMethodColor(entry.key),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Party-wise Payments
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Party-wise Payments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (paymentsByParty.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('No party payments found'),
                        ),
                      ),
                    ...paymentsByParty.entries.map((entry) {
                      final data = entry.value;
                      final received = data['received'] as double;
                      final paid = data['paid'] as double;
                      final net = received - paid;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            data['partyName'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('${data['count']} transaction(s)'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (received > 0)
                                Text(
                                  '↓ ₹${received.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                  ),
                                ),
                              if (paid > 0)
                                Text(
                                  '↑ ₹${paid.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Transactions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Transactions (${payments.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...payments.take(10).map((payment) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: payment.direction == PaymentDirection.inward
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          child: Icon(
                            payment.direction == PaymentDirection.inward
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: payment.direction == PaymentDirection.inward
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        title: Text(payment.partyName),
                        subtitle: Text(
                          '${DateFormat('dd MMM yyyy').format(payment.paymentDate)} • ${payment.paymentMethodName}',
                        ),
                        trailing: Text(
                          '₹${payment.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: payment.direction == PaymentDirection.inward
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashFlowMetric(String label, double amount, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.cheque:
        return 'Cheque';
      case PaymentMethod.razorpayOnline:
        return 'Razorpay Online';
      case PaymentMethod.razorpayLink:
        return 'Razorpay Link';
      case PaymentMethod.other:
        return 'Other';
    }
  }

  Color _getPaymentMethodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Colors.green;
      case PaymentMethod.upi:
        return Colors.purple;
      case PaymentMethod.card:
        return Colors.blue;
      case PaymentMethod.bankTransfer:
        return Colors.orange;
      case PaymentMethod.cheque:
        return Colors.brown;
      case PaymentMethod.razorpayOnline:
      case PaymentMethod.razorpayLink:
        return Colors.indigo;
      case PaymentMethod.other:
        return Colors.grey;
    }
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.unpaid:
      case PaymentStatus.pending:
        return Colors.red;
      case PaymentStatus.partial:
        return Colors.orange;
      case PaymentStatus.cancelled:
        return Colors.grey;
    }
  }
}
