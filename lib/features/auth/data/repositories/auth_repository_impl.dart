import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signInWithEmail(
        email: email,
        password: password,
      );
      final userEntity = UserModel.fromFirebaseUser(user);
      return Right(userEntity);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } catch (e) {
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signUpWithEmail(
        email: email,
        password: password,
      );
      final userEntity = UserModel.fromFirebaseUser(user);
      return Right(userEntity);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } catch (e) {
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final user = await remoteDataSource.signInWithGoogle();
      final userEntity = UserModel.fromFirebaseUser(user);
      return Right(userEntity);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } catch (e) {
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } catch (e) {
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = remoteDataSource.getCurrentUser();
      if (user == null) {
        return const Right(null);
      }
      final userEntity = UserModel.fromFirebaseUser(user);
      return Right(userEntity);
    } catch (e) {
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }
}

