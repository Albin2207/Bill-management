import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/invoice_provider.dart';
import '../../domain/entities/invoice_entity.dart';
import 'create_sales_order_page.dart';
import 'invoice_detail_page.dart';

class SalesOrdersListPage extends StatefulWidget {
  const SalesOrdersListPage({super.key});

  @override
  State<SalesOrdersListPage> createState() => _SalesOrdersListPageState();
}

class _SalesOrdersListPageState extends State<SalesOrdersListPage> {
  PaymentStatus? _selectedFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSalesOrders();
    });
  }

  void _loadSalesOrders() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    
    final userId = authProvider.user?.uid;
    if (userId != null) {
      invoiceProvider.loadInvoices(userId);
    }
  }
  
  List<InvoiceEntity> _getFilteredSalesOrders(List<InvoiceEntity> invoices) {
    // Filter by sales order type first
    final salesOrders = invoices.where((i) => i.invoiceType == InvoiceType.salesOrder).toList();
    
    // Then filter by payment status if selected
    if (_selectedFilter == null) return salesOrders;
    return salesOrders.where((i) => i.paymentStatus == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final filteredSalesOrders = _getFilteredSalesOrders(invoiceProvider.invoices);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Orders'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Search
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
                  _buildFilterChip('All', null, invoiceProvider.invoices.where((i) => i.invoiceType == InvoiceType.salesOrder).length),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Paid',
                    PaymentStatus.paid,
                    invoiceProvider.invoices.where((i) => i.invoiceType == InvoiceType.salesOrder && i.paymentStatus == PaymentStatus.paid).length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Pending',
                    PaymentStatus.pending,
                    invoiceProvider.invoices.where((i) => i.invoiceType == InvoiceType.salesOrder && i.paymentStatus == PaymentStatus.pending).length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Unpaid',
                    PaymentStatus.unpaid,
                    invoiceProvider.invoices.where((i) => i.invoiceType == InvoiceType.salesOrder && i.paymentStatus == PaymentStatus.unpaid).length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Cancelled',
                    PaymentStatus.cancelled,
                    invoiceProvider.invoices.where((i) => i.invoiceType == InvoiceType.salesOrder && i.paymentStatus == PaymentStatus.cancelled).length,
                  ),
                ],
              ),
            ),
          ),
          
          // Sales Orders List
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
                            Text(invoiceProvider.errorMessage ?? 'Error loading sales orders'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadSalesOrders,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredSalesOrders.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredSalesOrders.length,
                            itemBuilder: (context, index) {
                              final salesOrder = filteredSalesOrders[index];
                              return _buildSalesOrderCard(salesOrder);
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateSalesOrderPage()),
          );
          if (result == true) {
            _loadSalesOrders();
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Create Sales Order'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.point_of_sale,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No Sales Orders Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create your first sales order to see it here.',
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
                MaterialPageRoute(builder: (_) => const CreateSalesOrderPage()),
              );
              if (result == true) {
                _loadSalesOrders();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Sales Order'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
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

  Widget _buildSalesOrderCard(InvoiceEntity salesOrder) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InvoiceDetailPage(invoice: salesOrder),
            ),
          ).then((_) => _loadSalesOrders());
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
                      salesOrder.invoiceNumber,
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
                      color: _getStatusColor(salesOrder.paymentStatus),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      salesOrder.paymentStatus.name.toUpperCase(),
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
                salesOrder.partyName,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              if (salesOrder.partyGstin != null)
                Text(
                  'GSTIN: ${salesOrder.partyGstin}',
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
                        'Date: ${DateFormat('dd MMM yyyy').format(salesOrder.invoiceDate)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (salesOrder.dueDate != null)
                        Text(
                          'Due: ${DateFormat('dd MMM yyyy').format(salesOrder.dueDate!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    '₹${salesOrder.grandTotal.toStringAsFixed(2)}',
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
                '${salesOrder.items.length} item${salesOrder.items.length > 1 ? 's' : ''}',
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

