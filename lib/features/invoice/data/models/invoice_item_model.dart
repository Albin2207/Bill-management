import '../../domain/entities/invoice_item_entity.dart';

class InvoiceItemModel extends InvoiceItemEntity {
  const InvoiceItemModel({
    required super.productId,
    required super.productName,
    required super.hsnCode,
    required super.quantity,
    required super.unit,
    required super.rate,
    super.discount,
    required super.gstRate,
    super.cgst,
    super.sgst,
    super.igst,
    required super.taxableAmount,
    required super.totalAmount,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      hsnCode: json['hsnCode'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      rate: (json['rate'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      gstRate: (json['gstRate'] as num).toDouble(),
      cgst: (json['cgst'] as num?)?.toDouble(),
      sgst: (json['sgst'] as num?)?.toDouble(),
      igst: (json['igst'] as num?)?.toDouble(),
      taxableAmount: (json['taxableAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'hsnCode': hsnCode,
      'quantity': quantity,
      'unit': unit,
      'rate': rate,
      'discount': discount,
      'gstRate': gstRate,
      'cgst': cgst,
      'sgst': sgst,
      'igst': igst,
      'taxableAmount': taxableAmount,
      'totalAmount': totalAmount,
    };
  }
}

