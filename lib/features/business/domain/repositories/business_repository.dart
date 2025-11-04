import '../entities/business_entity.dart';

abstract class BusinessRepository {
  Future<BusinessEntity?> getBusinessByUserId(String userId);
  Future<void> saveBusiness(BusinessEntity business);
  Future<void> updateBusiness(BusinessEntity business);
  Future<void> updateLogo(String businessId, String logoUrl);
  Future<void> updateSignature(String businessId, String signatureUrl);
}

