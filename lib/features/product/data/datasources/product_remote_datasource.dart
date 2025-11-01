import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<String> addProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
  Future<ProductModel> getProduct(String id);
  Future<List<ProductModel>> getAllProducts(String userId);
  Stream<List<ProductModel>> watchAllProducts(String userId);
  Future<List<ProductModel>> searchProducts(String userId, String query);
  Future<void> updateStock(String id, double quantity);
  Future<List<ProductModel>> getLowStockProducts(String userId);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseFirestore firestore;

  ProductRemoteDataSourceImpl({required this.firestore});

  @override
  Future<String> addProduct(ProductModel product) async {
    try {
      await firestore
          .collection(AppConstants.productsCollection)
          .doc(product.id)
          .set(product.toJson());
      return product.id;
    } catch (e) {
      throw ServerException('Failed to add product: ${e.toString()}');
    }
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    try {
      await firestore
          .collection(AppConstants.productsCollection)
          .doc(product.id)
          .update(product.toJson());
    } catch (e) {
      throw ServerException('Failed to update product: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await firestore
          .collection(AppConstants.productsCollection)
          .doc(id)
          .delete();
    } catch (e) {
      throw ServerException('Failed to delete product: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> getProduct(String id) async {
    try {
      final doc = await firestore
          .collection(AppConstants.productsCollection)
          .doc(id)
          .get();
      
      if (!doc.exists) {
        throw const ServerException('Product not found');
      }
      
      return ProductModel.fromJson(doc.data()!);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get product: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductModel>> getAllProducts(String userId) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.productsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('name')
          .get();
      
      return snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get products: ${e.toString()}');
    }
  }

  @override
  Stream<List<ProductModel>> watchAllProducts(String userId) {
    try {
      return firestore
          .collection(AppConstants.productsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('name')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromJson(doc.data()))
              .toList());
    } catch (e) {
      throw ServerException('Failed to watch products: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String userId, String query) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.productsCollection)
          .where('userId', isEqualTo: userId)
          .get();
      
      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()))
          .toList();
      
      return products
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              (product.hsnCode.toLowerCase().contains(query.toLowerCase())))
          .toList();
    } catch (e) {
      throw ServerException('Failed to search products: ${e.toString()}');
    }
  }

  @override
  Future<void> updateStock(String id, double quantity) async {
    try {
      final doc = firestore.collection(AppConstants.productsCollection).doc(id);
      
      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(doc);
        if (!snapshot.exists) {
          throw const ServerException('Product not found');
        }
        
        final currentStock = (snapshot.data()?['stock'] as num?)?.toDouble() ?? 0;
        final newStock = currentStock + quantity;
        
        transaction.update(doc, {
          'stock': newStock,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to update stock: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductModel>> getLowStockProducts(String userId) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.productsCollection)
          .where('userId', isEqualTo: userId)
          .where('trackStock', isEqualTo: true)
          .get();
      
      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()))
          .toList();
      
      return products.where((product) => product.isLowStock).toList();
    } catch (e) {
      throw ServerException('Failed to get low stock products: ${e.toString()}');
    }
  }
}

