import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/party_model.dart';

abstract class PartyRemoteDataSource {
  Future<String> addParty(PartyModel party);
  Future<void> updateParty(PartyModel party);
  Future<void> deleteParty(String id);
  Future<PartyModel> getParty(String id);
  Future<List<PartyModel>> getAllParties(String userId);
  Stream<List<PartyModel>> watchAllParties(String userId);
  Future<List<PartyModel>> searchParties(String userId, String query);
}

class PartyRemoteDataSourceImpl implements PartyRemoteDataSource {
  final FirebaseFirestore firestore;

  PartyRemoteDataSourceImpl({required this.firestore});

  @override
  Future<String> addParty(PartyModel party) async {
    try {
      await firestore
          .collection(AppConstants.partiesCollection)
          .doc(party.id)
          .set(party.toJson());
      return party.id;
    } catch (e) {
      throw ServerException('Failed to add party: ${e.toString()}');
    }
  }

  @override
  Future<void> updateParty(PartyModel party) async {
    try {
      await firestore
          .collection(AppConstants.partiesCollection)
          .doc(party.id)
          .update(party.toJson());
    } catch (e) {
      throw ServerException('Failed to update party: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteParty(String id) async {
    try {
      await firestore
          .collection(AppConstants.partiesCollection)
          .doc(id)
          .delete();
    } catch (e) {
      throw ServerException('Failed to delete party: ${e.toString()}');
    }
  }

  @override
  Future<PartyModel> getParty(String id) async {
    try {
      final doc = await firestore
          .collection(AppConstants.partiesCollection)
          .doc(id)
          .get();
      
      if (!doc.exists) {
        throw const ServerException('Party not found');
      }
      
      return PartyModel.fromJson(doc.data()!);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get party: ${e.toString()}');
    }
  }

  @override
  Future<List<PartyModel>> getAllParties(String userId) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.partiesCollection)
          .where('userId', isEqualTo: userId)
          .get();
      
      // Sort in memory instead of using orderBy to avoid composite index
      final parties = snapshot.docs
          .map((doc) => PartyModel.fromJson(doc.data()))
          .toList();
      
      parties.sort((a, b) => a.name.compareTo(b.name));
      
      return parties;
    } catch (e) {
      throw ServerException('Failed to get parties: ${e.toString()}');
    }
  }

  @override
  Stream<List<PartyModel>> watchAllParties(String userId) {
    try {
      return firestore
          .collection(AppConstants.partiesCollection)
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
            final parties = snapshot.docs
                .map((doc) => PartyModel.fromJson(doc.data()))
                .toList();
            
            // Sort in memory
            parties.sort((a, b) => a.name.compareTo(b.name));
            
            return parties;
          });
    } catch (e) {
      throw ServerException('Failed to watch parties: ${e.toString()}');
    }
  }

  @override
  Future<List<PartyModel>> searchParties(String userId, String query) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.partiesCollection)
          .where('userId', isEqualTo: userId)
          .get();
      
      final parties = snapshot.docs
          .map((doc) => PartyModel.fromJson(doc.data()))
          .toList();
      
      // Filter by name (Firestore doesn't support case-insensitive search well)
      return parties
          .where((party) =>
              party.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw ServerException('Failed to search parties: ${e.toString()}');
    }
  }
}
