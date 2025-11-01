import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/party_entity.dart';
import '../../domain/repositories/party_repository.dart';
import '../datasources/party_remote_datasource.dart';
import '../models/party_model.dart';

class PartyRepositoryImpl implements PartyRepository {
  final PartyRemoteDataSource remoteDataSource;

  PartyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> addParty(PartyEntity party) async {
    try {
      final partyModel = PartyModel(
        id: party.id,
        userId: party.userId,
        name: party.name,
        phoneNumber: party.phoneNumber,
        email: party.email,
        gstin: party.gstin,
        address: party.address,
        city: party.city,
        state: party.state,
        pincode: party.pincode,
        country: party.country,
        partyType: party.partyType,
        openingBalance: party.openingBalance,
        imageUrl: party.imageUrl,
        createdAt: party.createdAt,
        updatedAt: party.updatedAt,
      );
      
      final id = await remoteDataSource.addParty(partyModel);
      return Right(id);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateParty(PartyEntity party) async {
    try {
      final partyModel = party as PartyModel;
      await remoteDataSource.updateParty(partyModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteParty(String id) async {
    try {
      await remoteDataSource.deleteParty(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PartyEntity>> getParty(String id) async {
    try {
      final party = await remoteDataSource.getParty(id);
      return Right(party);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<PartyEntity>>> getAllParties(String userId) async {
    try {
      final parties = await remoteDataSource.getAllParties(userId);
      return Right(parties);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<PartyEntity>>> watchAllParties(String userId) {
    try {
      return remoteDataSource.watchAllParties(userId).map((parties) => Right(parties));
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to watch parties: ${e.toString()}')));
    }
  }

  @override
  Future<Either<Failure, List<PartyEntity>>> searchParties(
    String userId,
    String query,
  ) async {
    try {
      final parties = await remoteDataSource.searchParties(userId, query);
      return Right(parties);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}

