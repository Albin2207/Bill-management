import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> addProduct(ProductEntity product) async {
    try {
      final productModel = ProductModel(
        id: product.id,
        userId: product.userId,
        name: product.name,
        description: product.description,
        category: product.category,
        hsnCode: product.hsnCode,
        sellingPrice: product.sellingPrice,
        purchasePrice: product.purchasePrice,
        unit: product.unit,
        gstRate: product.gstRate,
        stock: product.stock,
        minStock: product.minStock,
        imageUrl: product.imageUrl,
        trackStock: product.trackStock,
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
      );
      
      final id = await remoteDataSource.addProduct(productModel);
      return Right(id);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct(ProductEntity product) async {
    try {
      // Convert ProductEntity to ProductModel
      final productModel = ProductModel(
        id: product.id,
        userId: product.userId,
        name: product.name,
        description: product.description,
        category: product.category,
        hsnCode: product.hsnCode,
        sellingPrice: product.sellingPrice,
        purchasePrice: product.purchasePrice,
        unit: product.unit,
        gstRate: product.gstRate,
        stock: product.stock,
        minStock: product.minStock,
        imageUrl: product.imageUrl,
        trackStock: product.trackStock,
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
      );
      await remoteDataSource.updateProduct(productModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await remoteDataSource.deleteProduct(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProduct(String id) async {
    try {
      final product = await remoteDataSource.getProduct(id);
      return Right(product);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getAllProducts(String userId) async {
    try {
      final products = await remoteDataSource.getAllProducts(userId);
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<ProductEntity>>> watchAllProducts(String userId) {
    try {
      return remoteDataSource.watchAllProducts(userId).map((products) => Right(products));
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to watch products: ${e.toString()}')));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts(
    String userId,
    String query,
  ) async {
    try {
      final products = await remoteDataSource.searchProducts(userId, query);
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateStock(String id, double quantity) async {
    try {
      await remoteDataSource.updateStock(id, quantity);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getLowStockProducts(String userId) async {
    try {
      final products = await remoteDataSource.getLowStockProducts(userId);
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}

