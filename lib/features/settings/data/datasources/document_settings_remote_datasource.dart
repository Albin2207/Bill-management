import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/document_settings_model.dart';

abstract class DocumentSettingsRemoteDataSource {
  Future<DocumentSettingsModel?> getSettings(String userId);
  Future<void> saveSettings(DocumentSettingsModel settings);
  Future<void> updateSettings(DocumentSettingsModel settings);
}

class DocumentSettingsRemoteDataSourceImpl implements DocumentSettingsRemoteDataSource {
  final FirebaseFirestore firestore;

  DocumentSettingsRemoteDataSourceImpl({required this.firestore});

  @override
  Future<DocumentSettingsModel?> getSettings(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('documentSettings')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return DocumentSettingsModel.fromJson(querySnapshot.docs.first.data());
    } catch (e) {
      throw ServerException('Failed to get document settings: ${e.toString()}');
    }
  }

  @override
  Future<void> saveSettings(DocumentSettingsModel settings) async {
    try {
      await firestore
          .collection('documentSettings')
          .doc(settings.id)
          .set(settings.toJson());
    } catch (e) {
      throw ServerException('Failed to save document settings: ${e.toString()}');
    }
  }

  @override
  Future<void> updateSettings(DocumentSettingsModel settings) async {
    try {
      await firestore
          .collection('documentSettings')
          .doc(settings.id)
          .update(settings.toJson());
    } catch (e) {
      throw ServerException('Failed to update document settings: ${e.toString()}');
    }
  }
}

