import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/invoice_provider.dart';
import '../../domain/entities/invoice_entity.dart';
import 'create_invoice_page.dart';
import 'invoice_detail_page.dart';

class InvoicesListPage extends StatefulWidget {
  const InvoicesListPage({super.key});

  @override
  State<InvoicesListPage> createState() => _InvoicesListPageState();
}

class _InvoicesListPageState extends State<InvoicesListPage> {
  PaymentStatus? _selectedFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInvoices();
    });
  }

  void _loadInvoices() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    
    final userId = authProvider.user?.uid;
    if (userId != null) {
      invoiceProvider.loadInvoices(userId);
    }
  }
  
  List<InvoiceEntity> _getFilteredInvoices(List<InvoiceEntity> invoices) {
    // Filter to show only invoices (not bills, quotations, etc.)
    var filtered = invoices.where((i) => i.invoiceType == InvoiceType.invoice).toList();
    
    // Apply payment status filter if selected
    if (_selectedFilter != null) {
      filtered = filtered.where((i) => i.paymentStatus == _selectedFilter).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final filteredInvoices = _getFilteredInvoices(invoiceProvider.invoices);
    
    // Get only invoices for counting
    final onlyInvoices = invoiceProvider.invoices.where((i) => i.invoiceType == InvoiceType.invoice).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Filter/Search
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey.shade100,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', null, onlyInvoices.length),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Paid',
                    PaymentStatus.paid,
                    onlyInvoices.where((i) => i.paymentStatus == PaymentStatus.paid).length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Pending',
                    PaymentStatus.pending,
                    onlyInvoices.where((i) => i.paymentStatus == PaymentStatus.pending).length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Unpaid',
                    PaymentStatus.unpaid,
                    onlyInvoices.where((i) => i.paymentStatus == PaymentStatus.unpaid).length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Cancelled',
                    PaymentStatus.cancelled,
                    onlyInvoices.where((i) => i.paymentStatus == PaymentStatus.cancelled).length,
                  ),
                ],
              ),
            ),
          ),
          
          // Invoice List
          Expanded(
            child: invoiceProvider.status == InvoiceListStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : invoiceProvider.status == InvoiceListStatus.error
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(invoiceProvider.errorMessage ?? 'Error loading invoices'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadInvoices,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredInvoices.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredInvoices.length,
                            itemBuilder: (context, index) {
                              final invoice = filteredInvoices[index];
                              return _buildInvoiceCard(invoice);
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'invoices_fab',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateInvoicePage()),
          );
          if (result == true) {
            _loadInvoices();
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Create Invoice'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 120,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No Invoices Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create your first invoice to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateInvoicePage()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Invoice'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(InvoiceEntity invoice) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InvoiceDetailPage(invoice: invoice),
            ),
          ).then((_) => _loadInvoices());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      invoice.invoiceNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(invoice.paymentStatus),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      invoice.paymentStatus.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                invoice.partyName,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              if (invoice.partyGstin != null)
                Text(
                  'GSTIN: ${invoice.partyGstin}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date: ${DateFormat('dd MMM yyyy').format(invoice.invoiceDate)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (invoice.dueDate != null)
                        Text(
                          'Due: ${DateFormat('dd MMM yyyy').format(invoice.dueDate!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    '₹${invoice.grandTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${invoice.items.length} item${invoice.items.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, PaymentStatus? status, int count) {
    final isSelected = _selectedFilter == status;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? status : null;
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
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

