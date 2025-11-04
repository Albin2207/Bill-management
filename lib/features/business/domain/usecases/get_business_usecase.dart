import '../entities/business_entity.dart';
import '../repositories/business_repository.dart';

class GetBusinessUsecase {
  final BusinessRepository repository;

  GetBusinessUsecase(this.repository);

  Future<BusinessEntity?> call(String userId) async {
    return await repository.getBusinessByUserId(userId);
  }
}

