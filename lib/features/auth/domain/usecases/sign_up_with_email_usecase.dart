import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmailUsecase implements Usecase<UserEntity, SignUpParams> {
  final AuthRepository repository;

  SignUpWithEmailUsecase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    return await repository.signUpWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}

class SignUpParams {
  final String email;
  final String password;

  SignUpParams({
    required this.email,
    required this.password,
  });
}

