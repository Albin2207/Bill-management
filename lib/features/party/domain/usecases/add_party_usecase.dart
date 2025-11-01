import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/party_entity.dart';
import '../repositories/party_repository.dart';

class AddPartyUsecase implements Usecase<String, PartyEntity> {
  final PartyRepository repository;

  AddPartyUsecase(this.repository);

  @override
  Future<Either<Failure, String>> call(PartyEntity params) async {
    return await repository.addParty(params);
  }
}

