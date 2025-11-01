import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/party_repository.dart';

class DeletePartyUsecase implements Usecase<void, String> {
  final PartyRepository repository;

  DeletePartyUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(String partyId) async {
    return await repository.deleteParty(partyId);
  }
}

