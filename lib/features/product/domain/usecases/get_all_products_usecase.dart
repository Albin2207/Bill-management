import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetAllProductsUsecase implements Usecase<List<ProductEntity>, String> {
  final ProductRepository repository;

  GetAllProductsUsecase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(String userId) async {
    return await repository.getAllProducts(userId);
  }
}

