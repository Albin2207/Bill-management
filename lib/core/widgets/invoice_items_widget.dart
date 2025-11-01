import 'package:flutter/material.dart';
import '../../features/product/domain/entities/product_entity.dart';
import '../constants/app_colors.dart';
import '../models/invoice_item.dart';
import '../constants/document_constants.dart';

class InvoiceItemsWidget extends StatefulWidget {
  final List<InvoiceItem> items;
  final List<ProductEntity> products;
  final Function(List<InvoiceItem>) onItemsChanged;
  final VoidCallback onAddNewProduct;

  const InvoiceItemsWidget({
    super.key,
    required this.items,
    required this.products,
    required this.onItemsChanged,
    required this.onAddNewProduct,
  });

  @override
  State<InvoiceItemsWidget> createState() => _InvoiceItemsWidgetState();
}

class _InvoiceItemsWidgetState extends State<InvoiceItemsWidget> {
  void _showAddItemDialog() {
    if (widget.products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add products first'),
          action: SnackBarAction(
            label: 'Add Product',
            onPressed: widget.onAddNewProduct,
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        products: widget.products,
        onAddProduct: widget.onAddNewProduct,
        onItemAdded: (item) {
          final updatedItems = List<InvoiceItem>.from(widget.items)..add(item);
          widget.onItemsChanged(updatedItems);
        },
      ),
    );
  }

  void _editItem(int index) {
    final item = widget.items[index];
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        products: widget.products,
        existingItem: item,
        onAddProduct: widget.onAddNewProduct,
        onItemAdded: (updatedItem) {
          final updatedItems = List<InvoiceItem>.from(widget.items);
          updatedItems[index] = updatedItem;
          widget.onItemsChanged(updatedItems);
        },
      ),
    );
  }

  void _deleteItem(int index) {
    final updatedItems = List<InvoiceItem>.from(widget.items)..removeAt(index);
    widget.onItemsChanged(updatedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: widget.onAddNewProduct,
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('New Product'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (widget.items.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.products.isEmpty 
                            ? 'No products available'
                            : 'No items added yet',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (widget.products.isEmpty)
                        ElevatedButton.icon(
                          onPressed: widget.onAddNewProduct,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Product First'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        )
                      else
                        TextButton.icon(
                          onPressed: _showAddItemDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Select Product to Add'),
                        ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.items.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return _buildItemRow(item, index);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(InvoiceItem item, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'HSN: ${item.product.hsnCode}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} × ₹${item.rate.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${item.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'GST ${item.taxRate}%',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _editItem(index),
            icon: const Icon(Icons.edit, size: 20),
            color: Colors.blue,
          ),
          IconButton(
            onPressed: () => _deleteItem(index),
            icon: const Icon(Icons.delete, size: 20),
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  final List<ProductEntity> products;
  final InvoiceItem? existingItem;
  final VoidCallback onAddProduct;
  final Function(InvoiceItem) onItemAdded;

  const _AddItemDialog({
    required this.products,
    this.existingItem,
    required this.onAddProduct,
    required this.onItemAdded,
  });

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  ProductEntity? _selectedProduct;
  late TextEditingController _quantityController;
  late TextEditingController _rateController;
  late TextEditingController _discountController;
  late String _discountType;
  late double _taxRate;

  @override
  void initState() {
    super.initState();
    _selectedProduct = widget.existingItem?.product;
    _quantityController = TextEditingController(
      text: widget.existingItem?.quantity.toString() ?? '1',
    );
    _rateController = TextEditingController(
      text: widget.existingItem?.rate.toString() ?? '',
    );
    _discountController = TextEditingController(
      text: widget.existingItem?.discount.toString() ?? '0',
    );
    _discountType = widget.existingItem?.discountType ?? DocumentConstants.discountTypes.first;
    _taxRate = widget.existingItem?.taxRate ?? 18.0;
    
    if (_selectedProduct != null && _rateController.text.isEmpty) {
      _rateController.text = _selectedProduct!.sellingPrice.toString();
      _taxRate = _selectedProduct!.gstRate;
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _rateController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _saveItem() {
    if (widget.products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add products first before adding items'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (_selectedProduct == null || _rateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select product and enter rate')),
      );
      return;
    }

    // Stock Validation
    final requestedQty = double.tryParse(_quantityController.text) ?? 0;
    if (_selectedProduct!.trackStock && requestedQty > _selectedProduct!.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient stock! Available: ${_selectedProduct!.stock} ${_selectedProduct!.unit.name}',
          ),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Continue Anyway',
            textColor: Colors.white,
            onPressed: () {
              _saveItemWithoutValidation();
            },
          ),
        ),
      );
      return;
    }

    _saveItemWithoutValidation();
  }

  void _saveItemWithoutValidation() {

    final requestedQty = double.tryParse(_quantityController.text) ?? 1;
    
    final item = InvoiceItem(
      id: widget.existingItem?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      product: _selectedProduct!,
      quantity: requestedQty,
      rate: double.tryParse(_rateController.text) ?? 0,
      discount: double.tryParse(_discountController.text) ?? 0,
      discountType: _discountType,
      taxRate: _taxRate,
    );

    widget.onItemAdded(item);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Debug: Log product count
    debugPrint('AddItemDialog - Products count: ${widget.products.length}');
    if (widget.products.isNotEmpty) {
      debugPrint('First product: ${widget.products.first.name}');
    }
    
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.existingItem != null ? 'Edit Item' : 'Add Item',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.products.isNotEmpty)
                        Text(
                          '${widget.products.length} products available',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Selection
                    Row(
                      children: [
                        Expanded(
                          child: widget.products.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.orange),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.orange.shade50,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Colors.orange.shade700),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'No products available. Add a product first.',
                                          style: TextStyle(
                                            color: Colors.orange.shade700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : DropdownButtonFormField<ProductEntity>(
                                  value: _selectedProduct,
                                  decoration: const InputDecoration(
                                    labelText: 'Select Product *',
                                    border: OutlineInputBorder(),
                                    hintText: 'Choose a product',
                                  ),
                                  isExpanded: true,
                                  items: widget.products.map((product) {
                                    return DropdownMenuItem(
                                      value: product,
                                      child: Text(
                                        product.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedProduct = value;
                                      if (value != null) {
                                        _rateController.text = value.sellingPrice.toString();
                                        _taxRate = value.gstRate;
                                      }
                                    });
                                  },
                                ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: widget.onAddProduct,
                          icon: const Icon(Icons.add_circle),
                          color: AppColors.primary,
                          tooltip: 'Add New Product',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Quantity & Rate
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: InputDecoration(
                              labelText: 'Quantity *',
                              border: const OutlineInputBorder(),
                              helperText: _selectedProduct != null && _selectedProduct!.trackStock
                                  ? 'Available: ${_selectedProduct!.stock}'
                                  : null,
                              helperStyle: TextStyle(
                                color: _selectedProduct != null && 
                                       _selectedProduct!.trackStock &&
                                       (double.tryParse(_quantityController.text) ?? 0) > _selectedProduct!.stock
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {}); // Rebuild to update helper text color
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _rateController,
                            decoration: const InputDecoration(
                              labelText: 'Rate *',
                              border: OutlineInputBorder(),
                              prefixText: '₹ ',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Discount
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _discountController,
                            decoration: const InputDecoration(
                              labelText: 'Discount',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            value: _discountType,
                            decoration: const InputDecoration(
                              labelText: 'Type',
                              border: OutlineInputBorder(),
                            ),
                            isExpanded: true,
                            items: DocumentConstants.discountTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _discountType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Tax Rate
                    DropdownButtonFormField<double>(
                      value: _taxRate,
                      decoration: const InputDecoration(
                        labelText: 'GST Rate',
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      items: [0.0, 5.0, 12.0, 18.0, 28.0].map((rate) {
                        return DropdownMenuItem(
                          value: rate,
                          child: Text('$rate%'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _taxRate = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(widget.existingItem != null ? 'Update' : 'Add'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

