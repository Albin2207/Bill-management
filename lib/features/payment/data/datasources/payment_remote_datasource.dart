import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';

abstract class PaymentRemoteDataSource {
  Future<void> addPayment(PaymentModel payment);
  Future<List<PaymentModel>> getPaymentsByDocument(String documentId);
  Future<List<PaymentModel>> getAllPayments(String userId);
  Future<List<PaymentModel>> getPaymentsByParty(String partyId);
  Future<void> deletePayment(String paymentId);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final FirebaseFirestore firestore;

  PaymentRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> addPayment(PaymentModel payment) async {
    await firestore.collection('payments').doc(payment.id).set(payment.toJson());
  }

  @override
  Future<List<PaymentModel>> getPaymentsByDocument(String documentId) async {
    final snapshot = await firestore
        .collection('payments')
        .where('documentId', isEqualTo: documentId)
        .orderBy('paymentDate', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PaymentModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<List<PaymentModel>> getAllPayments(String userId) async {
    final snapshot = await firestore
        .collection('payments')
        .where('userId', isEqualTo: userId)
        .orderBy('paymentDate', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PaymentModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<List<PaymentModel>> getPaymentsByParty(String partyId) async {
    final snapshot = await firestore
        .collection('payments')
        .where('partyId', isEqualTo: partyId)
        .orderBy('paymentDate', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PaymentModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<void> deletePayment(String paymentId) async {
    await firestore.collection('payments').doc(paymentId).delete();
  }
}


