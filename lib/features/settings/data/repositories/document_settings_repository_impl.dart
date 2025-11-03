import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/document_settings_entity.dart';
import '../../domain/repositories/document_settings_repository.dart';
import '../datasources/document_settings_remote_datasource.dart';
import '../models/document_settings_model.dart';

class DocumentSettingsRepositoryImpl implements DocumentSettingsRepository {
  final DocumentSettingsRemoteDataSource remoteDataSource;

  DocumentSettingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DocumentSettingsEntity>> getSettings(String userId) async {
    try {
      final settings = await remoteDataSource.getSettings(userId);
      
      if (settings == null) {
        // Return default settings if none exist
        final defaultSettings = DocumentSettingsEntity(
          id: userId,
          userId: userId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        return Right(defaultSettings);
      }
      
      return Right(settings);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSettings(DocumentSettingsEntity settings) async {
    try {
      final model = DocumentSettingsModel.fromEntity(settings);
      await remoteDataSource.saveSettings(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to save settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateSettings(DocumentSettingsEntity settings) async {
    try {
      final model = DocumentSettingsModel.fromEntity(settings);
      await remoteDataSource.updateSettings(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update settings: ${e.toString()}'));
    }
  }
}

