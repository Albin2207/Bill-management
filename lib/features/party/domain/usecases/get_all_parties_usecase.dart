import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/party_entity.dart';
import '../repositories/party_repository.dart';

class GetAllPartiesUsecase implements Usecase<List<PartyEntity>, String> {
  final PartyRepository repository;

  GetAllPartiesUsecase(this.repository);

  @override
  Future<Either<Failure, List<PartyEntity>>> call(String userId) async {
    return await repository.getAllParties(userId);
  }
}

