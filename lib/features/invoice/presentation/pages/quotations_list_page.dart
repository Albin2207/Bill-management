import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/invoice_provider.dart';
import '../../domain/entities/invoice_entity.dart';
import 'create_quotation_page.dart';
import 'invoice_detail_page.dart';

class QuotationsListPage extends StatefulWidget {
  const QuotationsListPage({super.key});

  @override
  State<QuotationsListPage> createState() => _QuotationsListPageState();
}

class _QuotationsListPageState extends State<QuotationsListPage> {
  PaymentStatus? _selectedFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuotations();
    });
  }

  void _loadQuotations() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    
    final userId = authProvider.user?.uid;
    if (userId != null) {
      invoiceProvider.loadInvoices(userId);
    }
  }
  
  List<InvoiceEntity> _getFilteredQuotations(List<InvoiceEntity> invoices) {
    final quotations = invoices.where((i) => i.invoiceType == InvoiceType.quotation).toList();
    
    if (_selectedFilter == null) return quotations;
    return quotations.where((i) => i.paymentStatus == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final filteredQuotations = _getFilteredQuotations(invoiceProvider.invoices);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotations'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {},
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
                  _buildFilterChip('All', null, invoiceProvider.invoices.where((i) => i.invoiceType == InvoiceType.quotation).length),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Accepted',
                    PaymentStatus.paid,
                    invoiceProvider.invoices.where((i) => i.invoiceType == InvoiceType.quotation && i.paymentStatus == PaymentStatus.paid).length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Pending',
                    PaymentStatus.pending,
                    invoiceProvider.invoices.where((i) => i.invoiceType == InvoiceType.quotation && i.paymentStatus == PaymentStatus.pending).length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Rejected',
                    PaymentStatus.unpaid,
                    invoiceProvider.invoices.where((i) => i.invoiceType == InvoiceType.quotation && i.paymentStatus == PaymentStatus.unpaid).length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Cancelled',
                    PaymentStatus.cancelled,
                    invoiceProvider.invoices.where((i) => i.invoiceType == InvoiceType.quotation && i.paymentStatus == PaymentStatus.cancelled).length,
                  ),
                ],
              ),
            ),
          ),
          
          // Quotations List
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
                            Text(invoiceProvider.errorMessage ?? 'Error loading quotations'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadQuotations,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredQuotations.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredQuotations.length,
                            itemBuilder: (context, index) {
                              final quotation = filteredQuotations[index];
                              return _buildQuotationCard(quotation);
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'quotations_fab',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateQuotationPage()),
          );
          if (result == true) {
            _loadQuotations();
          }
        },
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.add),
        label: const Text('Create Quotation'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.request_quote,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No Quotations Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create quotations for your customers.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateQuotationPage()),
              );
              if (result == true) {
                _loadQuotations();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Quotation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotationCard(InvoiceEntity quotation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InvoiceDetailPage(invoice: quotation),
            ),
          ).then((_) => _loadQuotations());
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
                      quotation.invoiceNumber,
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
                      color: _getStatusColor(quotation.paymentStatus),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusLabel(quotation.paymentStatus),
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
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    quotation.partyName,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd MMM yyyy').format(quotation.invoiceDate),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '₹${quotation.grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusLabel(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return 'ACCEPTED';
      case PaymentStatus.unpaid:
        return 'REJECTED';
      case PaymentStatus.pending:
        return 'PENDING';
      case PaymentStatus.cancelled:
        return 'CANCELLED';
      default:
        return status.name.toUpperCase();
    }
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
        return Colors.red;
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.cancelled:
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }
}


