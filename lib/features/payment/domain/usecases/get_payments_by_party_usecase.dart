import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class GetPaymentsByPartyUsecase {
  final PaymentRepository repository;

  GetPaymentsByPartyUsecase(this.repository);

  Future<List<PaymentEntity>> call(String partyId) async {
    return await repository.getPaymentsByParty(partyId);
  }
}


