import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../invoice/presentation/providers/invoice_provider.dart';
import '../../../payment/presentation/providers/payment_provider.dart';
import '../providers/accounting_provider.dart';
import '../../../invoice/domain/entities/invoice_entity.dart';

class GSTReportPage extends StatefulWidget {
  const GSTReportPage({super.key});

  @override
  State<GSTReportPage> createState() => _GSTReportPageState();
}

class _GSTReportPageState extends State<GSTReportPage> {
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

    final userId = authProvider.user?.uid;
    if (userId != null) {
      invoiceProvider.loadInvoices(userId);
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
    final accountingProvider = Provider.of<AccountingProvider>(context);

    final dateRange = _getDateRange();
    final gstData = accountingProvider.calculateGSTSummary(
      invoiceProvider.invoices,
      dateRange.$1,
      dateRange.$2,
    );

    final invoices = gstData['invoices'] as List<InvoiceEntity>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GST Report'),
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

              // GST Payable Card
              Card(
                elevation: 3,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gstData['gstPayable'] >= 0
                          ? [Colors.orange.shade50, Colors.orange.shade100]
                          : [Colors.green.shade50, Colors.green.shade100],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        gstData['gstPayable'] >= 0 ? 'GST Payable' : 'GST Refundable',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${gstData['gstPayable'].abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: gstData['gstPayable'] >= 0 ? Colors.orange[700] : Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // GST Summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GST Summary',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 24),
                      _buildGSTRow('Output GST (Collected)', gstData['gstCollected'], Colors.green),
                      const SizedBox(height: 12),
                      _buildGSTRow('Input GST (Paid)', gstData['gstPaid'], Colors.red),
                      const Divider(height: 16),
                      _buildGSTRow(
                        'GST Payable',
                        gstData['gstPayable'],
                        gstData['gstPayable'] >= 0 ? Colors.orange : Colors.green,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // GST Breakdown
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GST Component Breakdown',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 24),
                      _buildGSTRow('CGST', gstData['cgst'], Colors.blue),
                      const SizedBox(height: 12),
                      _buildGSTRow('SGST', gstData['sgst'], Colors.purple),
                      const SizedBox(height: 12),
                      _buildGSTRow('IGST', gstData['igst'], Colors.indigo),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Invoice List
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoices with GST (${invoices.length})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      if (invoices.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('No GST invoices found'),
                          ),
                        ),
                      ...invoices.map((invoice) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: invoice.invoiceType == InvoiceType.invoice ||
                                    invoice.invoiceType == InvoiceType.salesOrder
                                ? Colors.green.withOpacity(0.1)
                                : Colors.blue.withOpacity(0.1),
                            child: Icon(
                              Icons.receipt,
                              color: invoice.invoiceType == InvoiceType.invoice ||
                                      invoice.invoiceType == InvoiceType.salesOrder
                                  ? Colors.green
                                  : Colors.blue,
                            ),
                          ),
                          title: Text(invoice.invoiceNumber),
                          subtitle: Text(
                            '${invoice.partyName} • ${DateFormat('dd MMM yyyy').format(invoice.invoiceDate)}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${invoice.totalTax.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                invoice.invoiceType.toString().split('.').last.toUpperCase(),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildGSTRow(String label, double amount, Color color, {bool isBold = false}) {
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
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

