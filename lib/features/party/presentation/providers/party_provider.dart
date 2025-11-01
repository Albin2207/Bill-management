import 'package:flutter/foundation.dart';
import '../../domain/entities/party_entity.dart';
import '../../domain/usecases/add_party_usecase.dart';
import '../../domain/usecases/get_all_parties_usecase.dart';
import '../../domain/usecases/update_party_usecase.dart';
import '../../domain/usecases/delete_party_usecase.dart';
import '../../../../core/error/failures.dart';

enum PartyListStatus {
  initial,
  loading,
  loaded,
  error,
}

class PartyProvider with ChangeNotifier {
  final AddPartyUsecase addPartyUsecase;
  final GetAllPartiesUsecase getAllPartiesUsecase;
  final UpdatePartyUsecase updatePartyUsecase;
  final DeletePartyUsecase deletePartyUsecase;

  PartyProvider({
    required this.addPartyUsecase,
    required this.getAllPartiesUsecase,
    required this.updatePartyUsecase,
    required this.deletePartyUsecase,
  });

  PartyListStatus _status = PartyListStatus.initial;
  List<PartyEntity> _parties = [];
  Failure? _failure;
  String? _errorMessage;
  bool _isSaving = false;

  PartyListStatus get status => _status;
  List<PartyEntity> get parties => _parties;
  Failure? get failure => _failure;
  String? get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;
  bool get isLoading => _status == PartyListStatus.loading;

  Future<void> loadParties(String userId) async {
    _status = PartyListStatus.loading;
    notifyListeners();

    final result = await getAllPartiesUsecase(userId);
    result.fold(
      (failure) {
        _status = PartyListStatus.error;
        _failure = failure;
        _errorMessage = failure.message;
      },
      (parties) {
        _status = PartyListStatus.loaded;
        _parties = parties;
        _errorMessage = null;
      },
    );
    notifyListeners();
  }

  Future<bool> addParty(PartyEntity party) async {
    _isSaving = true;
    notifyListeners();

    final result = await addPartyUsecase(party);
    
    _isSaving = false;
    
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (id) {
        _parties.add(party);
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  List<PartyEntity> searchParties(String query) {
    if (query.isEmpty) return _parties;
    
    return _parties
        .where((party) =>
            party.name.toLowerCase().contains(query.toLowerCase()) ||
            (party.phoneNumber?.contains(query) ?? false))
        .toList();
  }

  Future<bool> updateParty(PartyEntity party) async {
    _isSaving = true;
    notifyListeners();

    final result = await updatePartyUsecase(party);
    
    _isSaving = false;
    
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        final index = _parties.indexWhere((p) => p.id == party.id);
        if (index != -1) {
          _parties[index] = party;
        }
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> deleteParty(String id) async {
    _isSaving = true;
    notifyListeners();

    final result = await deletePartyUsecase(id);
    
    _isSaving = false;
    
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _parties.removeWhere((party) => party.id == id);
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

