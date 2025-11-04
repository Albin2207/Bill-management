import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/payment_entity.dart';
import '../providers/payment_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/app_colors.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPayments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      await paymentProvider.loadAllPayments(authProvider.user!.uid);
    }
  }

  List<PaymentEntity> _getFilteredPayments(List<PaymentEntity> payments) {
    var filtered = payments;

    // Filter by direction based on selected tab
    if (_tabController.index == 1) {
      // Received tab
      filtered = filtered.where((p) => p.direction == PaymentDirection.inward).toList();
    } else if (_tabController.index == 2) {
      // Paid tab
      filtered = filtered.where((p) => p.direction == PaymentDirection.outward).toList();
    }
    // Tab 0 (All) shows everything

    // Filter by payment method
    if (_selectedFilter != 'All') {
      filtered = filtered.where((p) => p.paymentMethodName == _selectedFilter).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) =>
        p.documentNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.partyName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.referenceNumber?.toLowerCase().contains(_searchQuery.toLowerCase()) == true
      ).toList();
    }

    // Filter by date range
    if (_startDate != null && _endDate != null) {
      filtered = filtered.where((p) =>
        p.paymentDate.isAfter(_startDate!) && p.paymentDate.isBefore(_endDate!.add(const Duration(days: 1)))
      ).toList();
    }

    return filtered;
  }

  double _getTotalAmount(List<PaymentEntity> payments) {
    return payments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  double _getTotalReceived(List<PaymentEntity> payments) {
    return payments
        .where((p) => p.direction == PaymentDirection.inward)
        .fold(0.0, (sum, payment) => sum + payment.amount);
  }

  double _getTotalPaid(List<PaymentEntity> payments) {
    return payments
        .where((p) => p.direction == PaymentDirection.outward)
        .fold(0.0, (sum, payment) => sum + payment.amount);
  }

  double _getNetCashFlow(List<PaymentEntity> payments) {
    return _getTotalReceived(payments) - _getTotalPaid(payments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            onPressed: _showFilterOptions,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
          ),
          IconButton(
            onPressed: _showDateRangeFilter,
            icon: const Icon(Icons.date_range),
            tooltip: 'Date Range',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Received', icon: Icon(Icons.arrow_downward, size: 16)),
            Tab(text: 'Paid', icon: Icon(Icons.arrow_upward, size: 16)),
          ],
        ),
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          if (paymentProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (paymentProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${paymentProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadPayments,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredPayments = _getFilteredPayments(paymentProvider.allPayments);

          if (filteredPayments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isNotEmpty || _selectedFilter != 'All'
                        ? 'No payments found'
                        : 'No payments yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  if (_searchQuery.isNotEmpty || _selectedFilter != 'All') ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _selectedFilter = 'All';
                          _startDate = null;
                          _endDate = null;
                        });
                      },
                      child: const Text('Clear Filters'),
                    ),
                  ],
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search by document, party, or reference...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // Cash Flow Summary Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryColumn(
                          'Received',
                          _getTotalReceived(paymentProvider.allPayments),
                          Colors.green,
                          Icons.arrow_downward,
                        ),
                        Container(width: 1, height: 40, color: Colors.grey[300]),
                        _buildSummaryColumn(
                          'Paid',
                          _getTotalPaid(paymentProvider.allPayments),
                          Colors.red,
                          Icons.arrow_upward,
                        ),
                        Container(width: 1, height: 40, color: Colors.grey[300]),
                        _buildSummaryColumn(
                          'Net Flow',
                          _getNetCashFlow(paymentProvider.allPayments),
                          _getNetCashFlow(paymentProvider.allPayments) >= 0 ? Colors.green : Colors.red,
                          _getNetCashFlow(paymentProvider.allPayments) >= 0 ? Icons.trending_up : Icons.trending_down,
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Transactions',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${filteredPayments.length}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Active Filters Chips
              if (_selectedFilter != 'All' || _startDate != null || _endDate != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      if (_selectedFilter != 'All')
                        Chip(
                          label: Text(_selectedFilter),
                          onDeleted: () => setState(() => _selectedFilter = 'All'),
                          deleteIcon: const Icon(Icons.close, size: 18),
                        ),
                      if (_startDate != null && _endDate != null)
                        Chip(
                          label: Text('${DateFormat('dd/MM').format(_startDate!)} - ${DateFormat('dd/MM').format(_endDate!)}'),
                          onDeleted: () => setState(() {
                            _startDate = null;
                            _endDate = null;
                          }),
                          deleteIcon: const Icon(Icons.close, size: 18),
                        ),
                    ],
                  ),
                ),

              const Divider(height: 1),

              // Payments List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadPayments,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredPayments.length,
                    itemBuilder: (context, index) {
                      final payment = filteredPayments[index];
                      return _buildPaymentCard(payment);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaymentCard(PaymentEntity payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showPaymentDetails(payment),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹${payment.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: payment.direction == PaymentDirection.inward ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        payment.direction == PaymentDirection.inward ? Icons.arrow_downward : Icons.arrow_upward,
                        size: 14,
                        color: payment.direction == PaymentDirection.inward ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        payment.partyName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          payment.paymentMethodName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy').format(payment.paymentDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.receipt, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    payment.documentNumber,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (payment.referenceNumber != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.tag, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        payment.referenceNumber!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              if (payment.notes != null) ...[
                const SizedBox(height: 8),
                Text(
                  payment.notes!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentDetails(PaymentEntity payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.payment, color: Colors.green, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Payment Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Amount', '₹${payment.amount.toStringAsFixed(2)}', isBold: true),
              const Divider(height: 24),
              _buildDetailRow('Party', payment.partyName),
              const Divider(height: 24),
              _buildDetailRow('Document', payment.documentNumber),
              const Divider(height: 24),
              _buildDetailRow('Date', DateFormat('dd MMMM yyyy').format(payment.paymentDate)),
              const Divider(height: 24),
              _buildDetailRow('Payment Method', payment.paymentMethodName),
              if (payment.referenceNumber != null) ...[
                const Divider(height: 24),
                _buildDetailRow('Reference Number', payment.referenceNumber!),
              ],
              if (payment.notes != null) ...[
                const Divider(height: 24),
                _buildDetailRow('Notes', payment.notes!),
              ],
              const Divider(height: 24),
              _buildDetailRow('Status', payment.status.toString().split('.').last.toUpperCase(),
                  color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryColumn(String label, double amount, Color color, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Filter by Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...['All', 'Cash', 'UPI', 'Card', 'Bank Transfer', 'Cheque', 'Other'].map((method) {
              return ListTile(
                leading: Radio<String>(
                  value: method,
                  groupValue: _selectedFilter,
                  onChanged: (value) {
                    setState(() => _selectedFilter = value!);
                    Navigator.pop(context);
                  },
                ),
                title: Text(method),
                onTap: () {
                  setState(() => _selectedFilter = method);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateRangeFilter() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }
}

