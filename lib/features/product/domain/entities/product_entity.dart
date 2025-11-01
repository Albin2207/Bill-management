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

  ProductEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? category,
    String? hsnCode,
    double? sellingPrice,
    double? purchasePrice,
    ProductUnit? unit,
    double? gstRate,
    double? stock,
    double? minStock,
    String? imageUrl,
    bool? trackStock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      hsnCode: hsnCode ?? this.hsnCode,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      unit: unit ?? this.unit,
      gstRate: gstRate ?? this.gstRate,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      imageUrl: imageUrl ?? this.imageUrl,
      trackStock: trackStock ?? this.trackStock,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
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

