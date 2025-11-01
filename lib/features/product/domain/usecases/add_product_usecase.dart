import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class AddProductUsecase implements Usecase<String, ProductEntity> {
  final ProductRepository repository;

  AddProductUsecase(this.repository);

  @override
  Future<Either<Failure, String>> call(ProductEntity params) async {
    return await repository.addProduct(params);
  }
}

