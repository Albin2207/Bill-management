import '../entities/business_entity.dart';
import '../repositories/business_repository.dart';

class UpdateBusinessUsecase {
  final BusinessRepository repository;

  UpdateBusinessUsecase(this.repository);

  Future<void> call(BusinessEntity business) async {
    return await repository.updateBusiness(business);
  }
}

