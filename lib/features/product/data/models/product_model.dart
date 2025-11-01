import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.userId,
    required super.name,
    super.description,
    super.category,
    required super.hsnCode,
    required super.sellingPrice,
    required super.purchasePrice,
    super.unit,
    required super.gstRate,
    super.stock,
    super.minStock,
    super.imageUrl,
    super.trackStock,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      hsnCode: json['hsnCode'] as String,
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      purchasePrice: (json['purchasePrice'] as num).toDouble(),
      unit: ProductUnit.values.firstWhere(
        (e) => e.name == json['unit'],
        orElse: () => ProductUnit.piece,
      ),
      gstRate: (json['gstRate'] as num).toDouble(),
      stock: (json['stock'] as num?)?.toDouble() ?? 0,
      minStock: (json['minStock'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String?,
      trackStock: json['trackStock'] as bool? ?? true,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'category': category,
      'hsnCode': hsnCode,
      'sellingPrice': sellingPrice,
      'purchasePrice': purchasePrice,
      'unit': unit.name,
      'gstRate': gstRate,
      'stock': stock,
      'minStock': minStock,
      'imageUrl': imageUrl,
      'trackStock': trackStock,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ProductModel copyWith({
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
    return ProductModel(
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
}

