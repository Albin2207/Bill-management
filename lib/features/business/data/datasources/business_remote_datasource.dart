import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/business_model.dart';

abstract class BusinessRemoteDataSource {
  Future<BusinessModel?> getBusinessByUserId(String userId);
  Future<void> saveBusiness(BusinessModel business);
  Future<void> updateBusiness(BusinessModel business);
}

class BusinessRemoteDataSourceImpl implements BusinessRemoteDataSource {
  final FirebaseFirestore firestore;

  BusinessRemoteDataSourceImpl({required this.firestore});

  @override
  Future<BusinessModel?> getBusinessByUserId(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('businesses')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return BusinessModel.fromJson(querySnapshot.docs.first.data());
    } catch (e) {
      throw Exception('Failed to get business: $e');
    }
  }

  @override
  Future<void> saveBusiness(BusinessModel business) async {
    try {
      await firestore
          .collection('businesses')
          .doc(business.id)
          .set(business.toJson());
    } catch (e) {
      throw Exception('Failed to save business: $e');
    }
  }

  @override
  Future<void> updateBusiness(BusinessModel business) async {
    try {
      await firestore
          .collection('businesses')
          .doc(business.id)
          .update(business.toJson());
    } catch (e) {
      throw Exception('Failed to update business: $e');
    }
  }
}

