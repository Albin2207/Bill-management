import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, String>> addProduct(ProductEntity product);
  Future<Either<Failure, void>> updateProduct(ProductEntity product);
  Future<Either<Failure, void>> deleteProduct(String id);
  Future<Either<Failure, ProductEntity>> getProduct(String id);
  Future<Either<Failure, List<ProductEntity>>> getAllProducts(String userId);
  Stream<Either<Failure, List<ProductEntity>>> watchAllProducts(String userId);
  Future<Either<Failure, List<ProductEntity>>> searchProducts(String userId, String query);
  Future<Either<Failure, void>> updateStock(String id, double quantity);
  Future<Either<Failure, List<ProductEntity>>> getLowStockProducts(String userId);
}

