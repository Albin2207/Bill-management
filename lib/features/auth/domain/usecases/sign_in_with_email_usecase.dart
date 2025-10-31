import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailUsecase implements Usecase<UserEntity, SignInParams> {
  final AuthRepository repository;

  SignInWithEmailUsecase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInParams params) async {
    return await repository.signInWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInParams {
  final String email;
  final String password;

  SignInParams({
    required this.email,
    required this.password,
  });
}

