import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/invoice_provider.dart';
import '../../domain/entities/invoice_entity.dart';
import 'create_purchase_order_page.dart';
import 'invoice_detail_page.dart';

class PurchaseOrdersListPage extends StatefulWidget {
  const PurchaseOrdersListPage({super.key});

  @override
  State<PurchaseOrdersListPage> createState() => _PurchaseOrdersListPageState();
}

class _PurchaseOrdersListPageState extends State<PurchaseOrdersListPage> {
  PaymentStatus? _selectedFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPurchaseOrders();
    });
  }

  void _loadPurchaseOrders() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    
    final userId = authProvider.user?.uid;
    if (userId != null) {
      invoiceProvider.loadInvoices(userId);
    }
  }
  
  List<InvoiceEntity> _getFilteredPurchaseOrders(List<InvoiceEntity> invoices) {
    final purchaseOrders = invoices.where((i) => i.invoiceType == InvoiceType.purchaseOrder).toList();
    
    if (_selectedFilter == null) return purchaseOrders;
    return purchaseOrders.where((i) => i.paymentStatus == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final filteredPurchaseOrders = _getFilteredPurchaseOrders(invoiceProvider.invoices);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Orders'),
        backgroundColor: Colors.deepOrange,
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
                  _buildFilterChip('All', null, invoiceProvider.invoices.where((i) => i.invoiceType == InvoiceType.purchaseOrder).length),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Paid',
                    PaymentStatus.paid,
                    invoiceProvider.invoices.where((i) => i.invoiceType == InvoiceType.purchaseOrder && i.paymentStatus == PaymentStatus.paid).length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Pending',
                    PaymentStatus.pending,
                    invoiceProvider.invoices.where((i) => i.invoiceType == InvoiceType.purchaseOrder && i.paymentStatus == PaymentStatus.pending).length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Unpaid',
                    PaymentStatus.unpaid,
                    invoiceProvider.invoices.where((i) => i.invoiceType == InvoiceType.purchaseOrder && i.paymentStatus == PaymentStatus.unpaid).length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Cancelled',
                    PaymentStatus.cancelled,
                    invoiceProvider.invoices.where((i) => i.invoiceType == InvoiceType.purchaseOrder && i.paymentStatus == PaymentStatus.cancelled).length,
                  ),
                ],
              ),
            ),
          ),
          
          // Purchase Orders List
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
                            Text(invoiceProvider.errorMessage ?? 'Error loading purchase orders'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadPurchaseOrders,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredPurchaseOrders.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredPurchaseOrders.length,
                            itemBuilder: (context, index) {
                              final purchaseOrder = filteredPurchaseOrders[index];
                              return _buildPurchaseOrderCard(purchaseOrder);
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePurchaseOrderPage()),
          );
          if (result == true) {
            _loadPurchaseOrders();
          }
        },
        backgroundColor: Colors.deepOrange,
        icon: const Icon(Icons.add),
        label: const Text('Create PO'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No Purchase Orders Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create purchase orders for your suppliers.',
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
                MaterialPageRoute(builder: (_) => const CreatePurchaseOrderPage()),
              );
              if (result == true) {
                _loadPurchaseOrders();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Purchase Order'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
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

  Widget _buildPurchaseOrderCard(InvoiceEntity purchaseOrder) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InvoiceDetailPage(invoice: purchaseOrder),
            ),
          ).then((_) => _loadPurchaseOrders());
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
                      purchaseOrder.invoiceNumber,
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
                      color: _getStatusColor(purchaseOrder.paymentStatus),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      purchaseOrder.paymentStatus.name.toUpperCase(),
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
                  const Icon(Icons.store, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    purchaseOrder.partyName,
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
                    DateFormat('dd MMM yyyy').format(purchaseOrder.invoiceDate),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '₹${purchaseOrder.grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
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


