import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/party_entity.dart';
import '../repositories/party_repository.dart';

class UpdatePartyUsecase implements Usecase<void, PartyEntity> {
  final PartyRepository repository;

  UpdatePartyUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(PartyEntity params) async {
    return await repository.updateParty(params);
  }
}

