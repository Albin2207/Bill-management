import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class GetAllPaymentsUsecase {
  final PaymentRepository repository;

  GetAllPaymentsUsecase(this.repository);

  Future<List<PaymentEntity>> call(String userId) async {
    return await repository.getAllPayments(userId);
  }
}


