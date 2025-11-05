import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../../domain/entities/product_entity.dart';
import 'edit_product_page.dart';

class ProductsListPage extends StatefulWidget {
  const ProductsListPage({super.key});

  @override
  State<ProductsListPage> createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  void _loadProducts() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final userId = authProvider.user?.uid;
    
    if (userId != null) {
      productProvider.loadProducts(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'products_fab',
        onPressed: () async {
          final result = await Navigator.pushNamed(context, AppRouter.addProduct);
          if (result == true) {
            _loadProducts();
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(productProvider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProducts,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final products = productProvider.products;

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2,
                    size: 64,
                    color: AppColors.onBackground.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.onBackground.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first product to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.onBackground.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadProducts(),
            child: ListView.builder(
              itemCount: products.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final product = products[index];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 400 + (index * 50)),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(30 * (1 - value), 0),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shadowColor: AppColors.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  child: ListTile(
                    leading: product.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.imageUrl!,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.inventory_2,
                              color: AppColors.primary,
                              size: 32,
                            ),
                          ),
                    title: Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('HSN: ${product.hsnCode}'),
                        const SizedBox(height: 2),
                        Text('₹${product.sellingPrice.toStringAsFixed(2)} | GST: ${product.gstRate}%'),
                        if (product.trackStock) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Stock: ${product.stock.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: product.isLowStock ? Colors.red : Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: product.isLowStock
                        ? const Chip(
                            label: Text(
                              'Low Stock',
                              style: TextStyle(fontSize: 10),
                            ),
                            backgroundColor: Colors.red,
                            labelStyle: TextStyle(color: Colors.white),
                            padding: EdgeInsets.zero,
                          )
                        : null,
                      onTap: () {
                        _showProductOptions(context, product);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
        ),
      ),
    );
  }

  void _showProductOptions(BuildContext context, ProductEntity product) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Edit Product'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProductPage(product: product),
                  ),
                );
                if (result == true) {
                  _loadProducts();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Product'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, product);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProductEntity product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final productProvider = Provider.of<ProductProvider>(context, listen: false);
              final success = await productProvider.deleteProduct(product.id);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Product deleted successfully'
                        : productProvider.errorMessage ?? 'Failed to delete product'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}


