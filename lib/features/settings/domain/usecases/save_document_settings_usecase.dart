import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/document_settings_entity.dart';
import '../repositories/document_settings_repository.dart';

class SaveDocumentSettingsUsecase implements Usecase<void, DocumentSettingsEntity> {
  final DocumentSettingsRepository repository;

  SaveDocumentSettingsUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(DocumentSettingsEntity settings) async {
    return await repository.saveSettings(settings);
  }
}

