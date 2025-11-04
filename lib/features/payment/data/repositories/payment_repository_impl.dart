import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';
import '../models/payment_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> addPayment(PaymentEntity payment) async {
    final paymentModel = PaymentModel.fromEntity(payment);
    await remoteDataSource.addPayment(paymentModel);
  }

  @override
  Future<List<PaymentEntity>> getPaymentsByDocument(String documentId) async {
    return await remoteDataSource.getPaymentsByDocument(documentId);
  }

  @override
  Future<List<PaymentEntity>> getAllPayments(String userId) async {
    return await remoteDataSource.getAllPayments(userId);
  }

  @override
  Future<List<PaymentEntity>> getPaymentsByParty(String partyId) async {
    return await remoteDataSource.getPaymentsByParty(partyId);
  }

  @override
  Future<void> deletePayment(String paymentId) async {
    await remoteDataSource.deletePayment(paymentId);
  }
}


