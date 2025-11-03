import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/document_settings_entity.dart';

abstract class DocumentSettingsRepository {
  Future<Either<Failure, DocumentSettingsEntity>> getSettings(String userId);
  Future<Either<Failure, void>> saveSettings(DocumentSettingsEntity settings);
  Future<Either<Failure, void>> updateSettings(DocumentSettingsEntity settings);
}

