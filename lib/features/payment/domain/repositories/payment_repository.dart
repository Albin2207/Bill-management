import '../entities/payment_entity.dart';

abstract class PaymentRepository {
  Future<void> addPayment(PaymentEntity payment);
  Future<List<PaymentEntity>> getPaymentsByDocument(String documentId);
  Future<List<PaymentEntity>> getAllPayments(String userId);
  Future<List<PaymentEntity>> getPaymentsByParty(String partyId);
  Future<void> deletePayment(String paymentId);
}


