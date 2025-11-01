import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/image_picker_widget.dart';
import '../providers/product_provider.dart';
import '../../domain/entities/product_entity.dart';
import '../../data/models/product_model.dart';

class EditProductPage extends StatefulWidget {
  final ProductEntity product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _hsnCodeController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _stockController;
  late TextEditingController _minStockController;

  String? _selectedCategory;
  late ProductUnit _selectedUnit;
  late double _selectedGstRate;
  late bool _trackStock;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(text: widget.product.description ?? '');
    _hsnCodeController = TextEditingController(text: widget.product.hsnCode);
    _sellingPriceController = TextEditingController(
      text: widget.product.sellingPrice.toString(),
    );
    _purchasePriceController = TextEditingController(
      text: widget.product.purchasePrice.toString(),
    );
    _stockController = TextEditingController(text: widget.product.stock.toString());
    _minStockController = TextEditingController(
      text: widget.product.minStock?.toString() ?? '',
    );
    _selectedCategory = widget.product.category;
    _selectedUnit = widget.product.unit;
    _selectedGstRate = widget.product.gstRate;
    _trackStock = widget.product.trackStock;
    _imageUrl = widget.product.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _hsnCodeController.dispose();
    _sellingPriceController.dispose();
    _purchasePriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    final updatedProduct = ProductModel(
      id: widget.product.id,
      userId: widget.product.userId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      category: _selectedCategory,
      hsnCode: _hsnCodeController.text.trim(),
      sellingPrice: double.parse(_sellingPriceController.text),
      purchasePrice: double.parse(_purchasePriceController.text),
      unit: _selectedUnit,
      gstRate: _selectedGstRate,
      stock: double.tryParse(_stockController.text) ?? 0,
      minStock: _minStockController.text.isEmpty
          ? null
          : double.tryParse(_minStockController.text),
      imageUrl: _imageUrl,
      trackStock: _trackStock,
      createdAt: widget.product.createdAt,
      updatedAt: DateTime.now(),
    );

    final success = await productProvider.updateProduct(updatedProduct);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(productProvider.errorMessage ?? 'Failed to update product'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Product Image
            ImagePickerWidget(
              label: 'Product Image',
              currentImageUrl: _imageUrl,
              onImageSelected: (url) {
                setState(() {
                  _imageUrl = url;
                });
              },
            ),
            const SizedBox(height: 16),

            // Basic Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Basic Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory_2),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Product name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: AppConstants.productCategories
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pricing & Tax
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pricing & Tax',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _hsnCodeController,
                      decoration: const InputDecoration(
                        labelText: 'HSN Code *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.qr_code),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'HSN code is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _sellingPriceController,
                            decoration: const InputDecoration(
                              labelText: 'Selling Price *',
                              border: OutlineInputBorder(),
                              prefixText: '₹ ',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _purchasePriceController,
                            decoration: const InputDecoration(
                              labelText: 'Purchase Price *',
                              border: OutlineInputBorder(),
                              prefixText: '₹ ',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ProductUnit>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      items: ProductUnit.values
                          .map((unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(AppConstants
                                        .productUnits[unit.name] ??
                                    unit.name),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUnit = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<double>(
                      value: _selectedGstRate,
                      decoration: const InputDecoration(
                        labelText: 'GST Rate',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.percent),
                      ),
                      items: AppConstants.gstRates
                          .map((rate) => DropdownMenuItem(
                                value: rate,
                                child: Text('$rate%'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGstRate = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Stock Management
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Stock Management',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Switch(
                          value: _trackStock,
                          onChanged: (value) {
                            setState(() {
                              _trackStock = value;
                            });
                          },
                        ),
                      ],
                    ),
                    if (_trackStock) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _stockController,
                              decoration: const InputDecoration(
                                labelText: 'Current Stock',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _minStockController,
                              decoration: const InputDecoration(
                                labelText: 'Min Stock Alert',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                return ElevatedButton(
                  onPressed: productProvider.isSaving ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: productProvider.isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Update Product',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

