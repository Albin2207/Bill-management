import 'package:flutter/foundation.dart';
import '../../domain/entities/document_settings_entity.dart';
import '../../domain/usecases/get_document_settings_usecase.dart';
import '../../domain/usecases/save_document_settings_usecase.dart';
import '../../../../core/error/failures.dart';

enum DocumentSettingsStatus {
  initial,
  loading,
  loaded,
  saving,
  saved,
  error,
}

class DocumentSettingsProvider with ChangeNotifier {
  final GetDocumentSettingsUsecase getDocumentSettingsUsecase;
  final SaveDocumentSettingsUsecase saveDocumentSettingsUsecase;

  DocumentSettingsProvider({
    required this.getDocumentSettingsUsecase,
    required this.saveDocumentSettingsUsecase,
  });

  DocumentSettingsStatus _status = DocumentSettingsStatus.initial;
  DocumentSettingsEntity? _settings;
  Failure? _failure;
  String? _errorMessage;

  DocumentSettingsStatus get status => _status;
  DocumentSettingsEntity? get settings => _settings;
  Failure? get failure => _failure;
  String? get errorMessage => _errorMessage;

  Future<void> loadSettings(String userId) async {
    _status = DocumentSettingsStatus.loading;
    notifyListeners();

    final result = await getDocumentSettingsUsecase(userId);
    result.fold(
      (failure) {
        _failure = failure;
        _errorMessage = failure.message;
        _status = DocumentSettingsStatus.error;
        notifyListeners();
      },
      (settings) {
        _settings = settings;
        _status = DocumentSettingsStatus.loaded;
        notifyListeners();
      },
    );
  }

  Future<bool> saveSettings(DocumentSettingsEntity settings) async {
    _status = DocumentSettingsStatus.saving;
    notifyListeners();

    final result = await saveDocumentSettingsUsecase(settings);
    
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _status = DocumentSettingsStatus.error;
        notifyListeners();
        return false;
      },
      (_) {
        _settings = settings;
        _errorMessage = null;
        _status = DocumentSettingsStatus.saved;
        notifyListeners();
        return true;
      },
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helper method to get settings or create default
  DocumentSettingsEntity getOrCreateDefault(String userId) {
    if (_settings != null) {
      return _settings!;
    }
    return DocumentSettingsEntity(
      id: userId,
      userId: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

