import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class UpdateProductUsecase implements Usecase<void, ProductEntity> {
  final ProductRepository repository;

  UpdateProductUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(ProductEntity params) async {
    return await repository.updateProduct(params);
  }
}

