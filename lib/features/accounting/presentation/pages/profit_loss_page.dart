import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../invoice/presentation/providers/invoice_provider.dart';
import '../../../payment/presentation/providers/payment_provider.dart';
import '../providers/accounting_provider.dart';

class ProfitLossPage extends StatefulWidget {
  const ProfitLossPage({super.key});

  @override
  State<ProfitLossPage> createState() => _ProfitLossPageState();
}

class _ProfitLossPageState extends State<ProfitLossPage> {
  String _selectedPeriod = 'This Month';
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  final List<String> _periods = [
    'This Month',
    'Last Month',
    'This Quarter',
    'This Year',
    'Custom',
  ];

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
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    final userId = authProvider.user?.uid;
    if (userId != null) {
      invoiceProvider.loadInvoices(userId);
      paymentProvider.loadAllPayments(userId);
    }
  }

  (DateTime, DateTime) _getDateRange() {
    final now = DateTime.now();

    if (_selectedPeriod == 'Custom' && _customStartDate != null && _customEndDate != null) {
      return (_customStartDate!, _customEndDate!);
    }

    switch (_selectedPeriod) {
      case 'This Month':
        return (
          DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
      case 'Last Month':
        return (
          DateTime(now.year, now.month - 1, 1),
          DateTime(now.year, now.month, 0, 23, 59, 59),
        );
      case 'This Quarter':
        final quarter = ((now.month - 1) ~/ 3) + 1;
        final startMonth = (quarter - 1) * 3 + 1;
        return (
          DateTime(now.year, startMonth, 1),
          DateTime(now.year, startMonth + 3, 0, 23, 59, 59),
        );
      case 'This Year':
        return (
          DateTime(now.year, 1, 1),
          DateTime(now.year, 12, 31, 23, 59, 59),
        );
      default:
        return (
          DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
    }
  }

  Future<void> _selectCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _customStartDate != null && _customEndDate != null
          ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _customStartDate = picked.start;
        _customEndDate = picked.end;
        _selectedPeriod = 'Custom';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final accountingProvider = Provider.of<AccountingProvider>(context);

    final dateRange = _getDateRange();
    final plData = accountingProvider.calculateProfitLoss(
      invoiceProvider.invoices,
      paymentProvider.allPayments,
      dateRange.$1,
      dateRange.$2,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit & Loss Statement'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period Selector
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedPeriod,
                      decoration: InputDecoration(
                        labelText: 'Period',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _periods.map((period) {
                        return DropdownMenuItem(value: period, child: Text(period));
                      }).toList(),
                      onChanged: (value) {
                        if (value == 'Custom') {
                          _selectCustomDateRange();
                        } else {
                          setState(() => _selectedPeriod = value!);
                        }
                      },
                    ),
                  ),
                  if (_selectedPeriod == 'Custom') ...[
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _selectCustomDateRange,
                      icon: const Icon(Icons.calendar_today),
                      tooltip: 'Select Date Range',
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${DateFormat('dd MMM yyyy').format(dateRange.$1)} - ${DateFormat('dd MMM yyyy').format(dateRange.$2)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // Net Profit/Loss Card
              Card(
                elevation: 3,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: plData['netProfit']! >= 0
                          ? [Colors.green.shade50, Colors.green.shade100]
                          : [Colors.red.shade50, Colors.red.shade100],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        plData['netProfit']! >= 0 ? 'Net Profit' : 'Net Loss',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${plData['netProfit']!.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: plData['netProfit']! >= 0 ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Revenue Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.trending_up, color: Colors.green[600]),
                          const SizedBox(width: 8),
                          const Text(
                            'Revenue',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildAmountRow('Total Revenue', plData['revenue']!, isTotal: true, color: Colors.green[700]!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cost of Goods Sold
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.inventory, color: Colors.orange[600]),
                          const SizedBox(width: 8),
                          const Text(
                            'Cost of Goods Sold',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildAmountRow('COGS', plData['cogs']!, color: Colors.orange[700]!),
                      const Divider(height: 16),
                      _buildAmountRow('Gross Profit', plData['grossProfit']!, isTotal: true, color: Colors.blue[700]!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Expenses Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.money_off, color: Colors.red[600]),
                          const SizedBox(width: 8),
                          const Text(
                            'Expenses',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildAmountRow('Total Expenses', plData['expenses']!, isTotal: true, color: Colors.red[700]!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Summary
              Card(
                color: Colors.grey[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Summary',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 24),
                      _buildAmountRow('Revenue', plData['revenue']!),
                      const SizedBox(height: 8),
                      _buildAmountRow('(-) COGS', plData['cogs']!, color: Colors.red),
                      const Divider(height: 16),
                      _buildAmountRow('Gross Profit', plData['grossProfit']!, isBold: true),
                      const SizedBox(height: 8),
                      _buildAmountRow('(-) Expenses', plData['expenses']!, color: Colors.red),
                      const Divider(height: 16),
                      _buildAmountRow(
                        'Net ${plData['netProfit']! >= 0 ? "Profit" : "Loss"}',
                        plData['netProfit']!.abs(),
                        isTotal: true,
                        color: plData['netProfit']! >= 0 ? Colors.green[700]! : Colors.red[700]!,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountRow(
    String label,
    double amount, {
    bool isTotal = false,
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal || isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal || isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}

