import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class AddPaymentUsecase {
  final PaymentRepository repository;

  AddPaymentUsecase(this.repository);

  Future<void> call(PaymentEntity payment) async {
    await repository.addPayment(payment);
  }
}


