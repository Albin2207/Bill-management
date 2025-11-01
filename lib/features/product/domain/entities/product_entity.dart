import 'package:equatable/equatable.dart';

enum ProductUnit {
  piece,
  kg,
  gram,
  liter,
  ml,
  meter,
  box,
  dozen,
}

class ProductEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? category;
  final String hsnCode;
  final double sellingPrice;
  final double purchasePrice;
  final ProductUnit unit;
  final double gstRate; // 0, 5, 12, 18, 28
  final double stock;
  final double? minStock;
  final String? imageUrl;
  final bool trackStock;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.category,
    required this.hsnCode,
    required this.sellingPrice,
    required this.purchasePrice,
    this.unit = ProductUnit.piece,
    required this.gstRate,
    this.stock = 0,
    this.minStock,
    this.imageUrl,
    this.trackStock = true,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isLowStock {
    if (!trackStock || minStock == null) return false;
    return stock <= minStock!;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        category,
        hsnCode,
        sellingPrice,
        purchasePrice,
        unit,
        gstRate,
        stock,
        minStock,
        imageUrl,
        trackStock,
        createdAt,
        updatedAt,
      ];
}

