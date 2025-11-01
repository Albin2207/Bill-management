import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/party_entity.dart';

abstract class PartyRepository {
  Future<Either<Failure, String>> addParty(PartyEntity party);
  Future<Either<Failure, void>> updateParty(PartyEntity party);
  Future<Either<Failure, void>> deleteParty(String id);
  Future<Either<Failure, PartyEntity>> getParty(String id);
  Future<Either<Failure, List<PartyEntity>>> getAllParties(String userId);
  Stream<Either<Failure, List<PartyEntity>>> watchAllParties(String userId);
  Future<Either<Failure, List<PartyEntity>>> searchParties(String userId, String query);
}

