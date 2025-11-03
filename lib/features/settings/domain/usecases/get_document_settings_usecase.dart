import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/document_settings_entity.dart';
import '../repositories/document_settings_repository.dart';

class GetDocumentSettingsUsecase implements Usecase<DocumentSettingsEntity, String> {
  final DocumentSettingsRepository repository;

  GetDocumentSettingsUsecase(this.repository);

  @override
  Future<Either<Failure, DocumentSettingsEntity>> call(String userId) async {
    return await repository.getSettings(userId);
  }
}

