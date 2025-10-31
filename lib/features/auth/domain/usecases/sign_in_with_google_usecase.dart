import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogleUsecase implements Usecase<UserEntity, NoParams> {
  final AuthRepository repository;

  SignInWithGoogleUsecase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    return await repository.signInWithGoogle();
  }
}

