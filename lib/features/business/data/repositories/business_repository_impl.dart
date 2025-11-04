import '../../domain/entities/business_entity.dart';
import '../../domain/repositories/business_repository.dart';
import '../datasources/business_remote_datasource.dart';
import '../models/business_model.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  final BusinessRemoteDataSource remoteDataSource;

  BusinessRepositoryImpl({required this.remoteDataSource});

  @override
  Future<BusinessEntity?> getBusinessByUserId(String userId) async {
    try {
      return await remoteDataSource.getBusinessByUserId(userId);
    } catch (e) {
      throw Exception('Failed to get business: $e');
    }
  }

  @override
  Future<void> saveBusiness(BusinessEntity business) async {
    try {
      final model = BusinessModel.fromEntity(business);
      await remoteDataSource.saveBusiness(model);
    } catch (e) {
      throw Exception('Failed to save business: $e');
    }
  }

  @override
  Future<void> updateBusiness(BusinessEntity business) async {
    try {
      final model = BusinessModel.fromEntity(business);
      await remoteDataSource.updateBusiness(model);
    } catch (e) {
      throw Exception('Failed to update business: $e');
    }
  }

  @override
  Future<void> updateLogo(String businessId, String logoUrl) async {
    // This will be handled in the update method
    throw UnimplementedError();
  }

  @override
  Future<void> updateSignature(String businessId, String signatureUrl) async {
    // This will be handled in the update method
    throw UnimplementedError();
  }
}

