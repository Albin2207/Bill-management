import '../entities/business_entity.dart';
import '../repositories/business_repository.dart';

class SaveBusinessUsecase {
  final BusinessRepository repository;

  SaveBusinessUsecase(this.repository);

  Future<void> call(BusinessEntity business) async {
    return await repository.saveBusiness(business);
  }
}

