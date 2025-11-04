import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../product/presentation/providers/product_provider.dart';
import '../providers/accounting_provider.dart';
import '../../../product/domain/entities/product_entity.dart';

class StockReportPage extends StatefulWidget {
  const StockReportPage({super.key});

  @override
  State<StockReportPage> createState() => _StockReportPageState();
}

class _StockReportPageState extends State<StockReportPage> {
  String _sortBy = 'name';
  String _filterBy = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    final userId = authProvider.user?.uid;
    if (userId != null) {
      productProvider.loadProducts(userId);
    }
  }

  List<ProductEntity> _getFilteredProducts(List<ProductEntity> products) {
    var filtered = products.where((p) => p.trackStock).toList();

    // Apply filter
    switch (_filterBy) {
      case 'lowStock':
        filtered = filtered.where((p) =>
            p.minStock != null && p.stock <= p.minStock!).toList();
        break;
      case 'outOfStock':
        filtered = filtered.where((p) => p.stock == 0).toList();
        break;
      case 'inStock':
        filtered = filtered.where((p) => p.stock > 0).toList();
        break;
    }

    // Apply sorting
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'stock':
        filtered.sort((a, b) => b.stock.compareTo(a.stock));
        break;
      case 'value':
        filtered.sort((a, b) {
          final valueA = (a.purchasePrice ?? 0) * a.stock;
          final valueB = (b.purchasePrice ?? 0) * b.stock;
          return valueB.compareTo(valueA);
        });
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final accountingProvider = Provider.of<AccountingProvider>(context);

    final stockReport = accountingProvider.calculateStockReport(productProvider.products);
    final products = _getFilteredProducts(productProvider.products);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Report'),
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
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Value',
                      '₹${stockReport['totalStockValue'].toStringAsFixed(0)}',
                      Icons.currency_rupee,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Products',
                      '${stockReport['totalProducts']}',
                      Icons.inventory,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Low Stock',
                      '${stockReport['lowStockProducts']}',
                      Icons.warning,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Out of Stock',
                      '${stockReport['outOfStock']}',
                      Icons.error,
                      Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Filters
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _filterBy,
                      decoration: InputDecoration(
                        labelText: 'Filter',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Products')),
                        DropdownMenuItem(value: 'inStock', child: Text('In Stock')),
                        DropdownMenuItem(value: 'lowStock', child: Text('Low Stock')),
                        DropdownMenuItem(value: 'outOfStock', child: Text('Out of Stock')),
                      ],
                      onChanged: (value) => setState(() => _filterBy = value!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _sortBy,
                      decoration: InputDecoration(
                        labelText: 'Sort By',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'name', child: Text('Name')),
                        DropdownMenuItem(value: 'stock', child: Text('Stock Qty')),
                        DropdownMenuItem(value: 'value', child: Text('Value')),
                      ],
                      onChanged: (value) => setState(() => _sortBy = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Product List
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Products (${products.length})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(height: 1),
                    if (products.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: Text('No products found')),
                      ),
                    ...products.map((product) {
                      final stockValue = (product.purchasePrice ?? 0) * product.stock;
                      final isLowStock = product.minStock != null &&
                          product.stock <= product.minStock!;
                      final isOutOfStock = product.stock == 0;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isOutOfStock
                              ? Colors.red.withOpacity(0.1)
                              : isLowStock
                                  ? Colors.orange.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                          child: Icon(
                            Icons.inventory_2,
                            color: isOutOfStock
                                ? Colors.red
                                : isLowStock
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                        title: Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('HSN: ${product.hsnCode ?? "-"}'),
                            Text('Purchase: ₹${product.purchasePrice?.toStringAsFixed(2) ?? "0"}'),
                            if (isLowStock && !isOutOfStock)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'LOW STOCK',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (isOutOfStock)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'OUT OF STOCK',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${product.stock.toStringAsFixed(0)} ${product.unit}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '₹${stockValue.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
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
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

