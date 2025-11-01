import 'package:flutter/foundation.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/add_product_usecase.dart';
import '../../domain/usecases/get_all_products_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../../../core/error/failures.dart';

enum ProductListStatus {
  initial,
  loading,
  loaded,
  error,
}

class ProductProvider with ChangeNotifier {
  final AddProductUsecase addProductUsecase;
  final GetAllProductsUsecase getAllProductsUsecase;
  final UpdateProductUsecase updateProductUsecase;
  final DeleteProductUsecase deleteProductUsecase;

  ProductProvider({
    required this.addProductUsecase,
    required this.getAllProductsUsecase,
    required this.updateProductUsecase,
    required this.deleteProductUsecase,
  });

  ProductListStatus _status = ProductListStatus.initial;
  List<ProductEntity> _products = [];
  Failure? _failure;
  String? _errorMessage;
  bool _isSaving = false;

  ProductListStatus get status => _status;
  List<ProductEntity> get products => _products;
  Failure? get failure => _failure;
  String? get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;
  bool get isLoading => _status == ProductListStatus.loading;

  Future<void> loadProducts(String userId) async {
    _status = ProductListStatus.loading;
    notifyListeners();

    final result = await getAllProductsUsecase(userId);
    result.fold(
      (failure) {
        _status = ProductListStatus.error;
        _failure = failure;
        _errorMessage = failure.message;
      },
      (products) {
        _status = ProductListStatus.loaded;
        _products = products;
        _errorMessage = null;
      },
    );
    notifyListeners();
  }

  Future<bool> addProduct(ProductEntity product) async {
    _isSaving = true;
    notifyListeners();

    final result = await addProductUsecase(product);
    
    _isSaving = false;
    
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (id) {
        _products.add(product);
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  List<ProductEntity> searchProducts(String query) {
    if (query.isEmpty) return _products;
    
    return _products
        .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.hsnCode.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<ProductEntity> getLowStockProducts() {
    return _products.where((product) => product.isLowStock).toList();
  }

  Future<bool> updateProduct(ProductEntity product) async {
    _isSaving = true;
    notifyListeners();

    final result = await updateProductUsecase(product);
    
    _isSaving = false;
    
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        final index = _products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          _products[index] = product;
        }
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> deleteProduct(String id) async {
    _isSaving = true;
    notifyListeners();

    final result = await deleteProductUsecase(id);
    
    _isSaving = false;
    
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _products.removeWhere((product) => product.id == id);
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

