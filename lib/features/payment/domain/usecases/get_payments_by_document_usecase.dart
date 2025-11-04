import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class GetPaymentsByDocumentUsecase {
  final PaymentRepository repository;

  GetPaymentsByDocumentUsecase(this.repository);

  Future<List<PaymentEntity>> call(String documentId) async {
    return await repository.getPaymentsByDocument(documentId);
  }
}


