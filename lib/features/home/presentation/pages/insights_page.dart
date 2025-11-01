import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../invoice/presentation/providers/invoice_provider.dart';
import '../../../invoice/domain/entities/invoice_entity.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    
    final userId = authProvider.user?.uid;
    if (userId != null) {
      invoiceProvider.loadInvoices(userId);
    }
  }

  Map<int, double> _getLast6MonthsSales(List<InvoiceEntity> invoices) {
    final now = DateTime.now();
    final Map<int, double> monthlySales = {};
    
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      monthlySales[month.month] = 0.0;
    }

    for (final invoice in invoices) {
      if (invoice.invoiceType == InvoiceType.invoice && 
          invoice.paymentStatus != PaymentStatus.cancelled) {
        final month = invoice.invoiceDate.month;
        if (monthlySales.containsKey(month)) {
          monthlySales[month] = monthlySales[month]! + invoice.grandTotal;
        }
      }
    }

    return monthlySales;
  }

  Map<int, double> _getLast6MonthsPurchases(List<InvoiceEntity> invoices) {
    final now = DateTime.now();
    final Map<int, double> monthlyPurchases = {};
    
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      monthlyPurchases[month.month] = 0.0;
    }

    for (final invoice in invoices) {
      if (invoice.invoiceType == InvoiceType.bill && 
          invoice.paymentStatus != PaymentStatus.cancelled) {
        final month = invoice.invoiceDate.month;
        if (monthlyPurchases.containsKey(month)) {
          monthlyPurchases[month] = monthlyPurchases[month]! + invoice.grandTotal;
        }
      }
    }

    return monthlyPurchases;
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final monthlySales = _getLast6MonthsSales(invoiceProvider.invoices);
    final monthlyPurchases = _getLast6MonthsPurchases(invoiceProvider.invoices);
    
    final totalSales = invoiceProvider.invoices
        .where((i) => i.invoiceType == InvoiceType.invoice && 
                     i.paymentStatus != PaymentStatus.cancelled)
        .fold(0.0, (sum, i) => sum + i.grandTotal);
    
    final totalPurchases = invoiceProvider.invoices
        .where((i) => i.invoiceType == InvoiceType.bill && 
                     i.paymentStatus != PaymentStatus.cancelled)
        .fold(0.0, (sum, i) => sum + i.grandTotal);
    
    final profit = totalSales - totalPurchases;
    
    final paidCount = invoiceProvider.invoices
        .where((i) => i.paymentStatus == PaymentStatus.paid).length;
    final pendingCount = invoiceProvider.invoices
        .where((i) => i.paymentStatus == PaymentStatus.pending).length;
    final unpaidCount = invoiceProvider.invoices
        .where((i) => i.paymentStatus == PaymentStatus.unpaid).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Insights'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildInsightCard(
                  'Total Sales',
                  '₹${totalSales.toStringAsFixed(2)}',
                  Colors.green,
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInsightCard(
                  'Total Purchases',
                  '₹${totalPurchases.toStringAsFixed(2)}',
                  Colors.orange,
                  Icons.shopping_cart,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            'Profit',
            '₹${profit.toStringAsFixed(2)}',
            profit >= 0 ? Colors.blue : Colors.red,
            profit >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
          ),
          const SizedBox(height: 24),
          
          // Sales vs Purchases Trend Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sales vs Purchases (Last 6 Months)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildChartLegend('Sales', Colors.green),
                          const SizedBox(width: 12),
                          _buildChartLegend('Purchases', Colors.orange),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 250,
                    child: monthlySales.isEmpty
                        ? const Center(child: Text('No data available'))
                        : BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: monthlySales.values.reduce((a, b) => a > b ? a : b) * 1.2,
                              barTouchData: BarTouchData(enabled: true),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                                                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                                      final index = value.toInt();
                                      if (index >= 0 && index < 12) {
                                        return Text(
                                          months[index],
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        '₹${(value / 1000).toStringAsFixed(0)}k',
                                        style: const TextStyle(fontSize: 10),
                                      );
                                    },
                                  ),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: monthlySales.entries.map((entry) {
                                final month = entry.key;
                                final salesAmount = entry.value;
                                final purchasesAmount = monthlyPurchases[month] ?? 0;
                                
                                return BarChartGroupData(
                                  x: month - 1,
                                  barsSpace: 4,
                                  barRods: [
                                    BarChartRodData(
                                      toY: salesAmount,
                                      color: Colors.green,
                                      width: 12,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                    ),
                                    BarChartRodData(
                                      toY: purchasesAmount,
                                      color: Colors.orange,
                                      width: 12,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Payment Status Pie Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Status Distribution',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: Row(
                      children: [
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sections: [
                                if (paidCount > 0)
                                  PieChartSectionData(
                                    value: paidCount.toDouble(),
                                    title: '$paidCount',
                                    color: Colors.green,
                                    radius: 60,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                if (pendingCount > 0)
                                  PieChartSectionData(
                                    value: pendingCount.toDouble(),
                                    title: '$pendingCount',
                                    color: Colors.orange,
                                    radius: 60,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                if (unpaidCount > 0)
                                  PieChartSectionData(
                                    value: unpaidCount.toDouble(),
                                    title: '$unpaidCount',
                                    color: Colors.red,
                                    radius: 60,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLegendItem('Paid', Colors.green, paidCount),
                            const SizedBox(height: 8),
                            _buildLegendItem('Pending', Colors.orange, pendingCount),
                            const SizedBox(height: 8),
                            _buildLegendItem('Unpaid', Colors.red, unpaidCount),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String label, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label ($count)',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}


