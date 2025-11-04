import '../repositories/payment_repository.dart';

class DeletePaymentUsecase {
  final PaymentRepository repository;

  DeletePaymentUsecase(this.repository);

  Future<void> call(String paymentId) async {
    await repository.deletePayment(paymentId);
  }
}


