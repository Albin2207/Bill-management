import 'package:equatable/equatable.dart';

class InvoiceItemEntity extends Equatable {
  final String productId;
  final String productName;
  final String hsnCode;
  final double quantity;
  final String unit;
  final double rate;
  final double discount; // Percentage
  final double gstRate;
  final double? cgst; // Will be calculated
  final double? sgst; // Will be calculated
  final double? igst; // Will be calculated
  final double taxableAmount;
  final double totalAmount;

  const InvoiceItemEntity({
    required this.productId,
    required this.productName,
    required this.hsnCode,
    required this.quantity,
    required this.unit,
    required this.rate,
    this.discount = 0,
    required this.gstRate,
    this.cgst,
    this.sgst,
    this.igst,
    required this.taxableAmount,
    required this.totalAmount,
  });

  // Calculate taxable amount (before GST)
  double get calculatedTaxableAmount {
    final gross = quantity * rate;
    final discountAmount = gross * (discount / 100);
    return gross - discountAmount;
  }

  // Calculate tax amount
  double get taxAmount {
    return calculatedTaxableAmount * (gstRate / 100);
  }

  @override
  List<Object?> get props => [
        productId,
        productName,
        hsnCode,
        quantity,
        unit,
        rate,
        discount,
        gstRate,
        cgst,
        sgst,
        igst,
        taxableAmount,
        totalAmount,
      ];
}

