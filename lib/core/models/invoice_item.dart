import '../../features/product/domain/entities/product_entity.dart';

class InvoiceItem {
  final String id;
  final ProductEntity product;
  final double quantity;
  final double rate;
  final double discount;
  final String discountType; // 'Percentage (%)' or 'Fixed Amount (₹)'
  final double taxRate;
  
  InvoiceItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.rate,
    this.discount = 0,
    this.discountType = 'Percentage (%)',
    required this.taxRate,
  });

  double get subtotal => quantity * rate;
  
  double get discountAmount {
    if (discountType == 'Percentage (%)') {
      return subtotal * (discount / 100);
    }
    return discount;
  }
  
  double get amountAfterDiscount => subtotal - discountAmount;
  
  double get taxAmount => amountAfterDiscount * (taxRate / 100);
  
  double get total => amountAfterDiscount + taxAmount;

  InvoiceItem copyWith({
    String? id,
    ProductEntity? product,
    double? quantity,
    double? rate,
    double? discount,
    String? discountType,
    double? taxRate,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      discount: discount ?? this.discount,
      discountType: discountType ?? this.discountType,
      taxRate: taxRate ?? this.taxRate,
    );
  }
}

