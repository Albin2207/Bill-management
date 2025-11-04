import 'package:flutter/foundation.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/usecases/add_payment_usecase.dart';
import '../../domain/usecases/get_all_payments_usecase.dart';
import '../../domain/usecases/get_payments_by_document_usecase.dart';
import '../../domain/usecases/get_payments_by_party_usecase.dart';
import '../../domain/usecases/delete_payment_usecase.dart';

class PaymentProvider extends ChangeNotifier {
  final AddPaymentUsecase addPaymentUsecase;
  final GetAllPaymentsUsecase getAllPaymentsUsecase;
  final GetPaymentsByDocumentUsecase getPaymentsByDocumentUsecase;
  final GetPaymentsByPartyUsecase getPaymentsByPartyUsecase;
  final DeletePaymentUsecase deletePaymentUsecase;

  PaymentProvider({
    required this.addPaymentUsecase,
    required this.getAllPaymentsUsecase,
    required this.getPaymentsByDocumentUsecase,
    required this.getPaymentsByPartyUsecase,
    required this.deletePaymentUsecase,
  });

  List<PaymentEntity> _allPayments = [];
  List<PaymentEntity> get allPayments => _allPayments;

  List<PaymentEntity> _partyPayments = [];
  List<PaymentEntity> get partyPayments => _partyPayments;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Add a payment
  Future<bool> addPayment(PaymentEntity payment) async {
    try {
      _error = null;
      await addPaymentUsecase(payment);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get all payments for current user
  Future<void> loadAllPayments(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _allPayments = await getAllPaymentsUsecase(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get payments for a specific document
  Future<List<PaymentEntity>> getPaymentsByDocument(String documentId) async {
    try {
      return await getPaymentsByDocumentUsecase(documentId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Get payments for a specific party
  Future<List<PaymentEntity>> getPaymentsByParty(String partyId) async {
    try {
      return await getPaymentsByPartyUsecase(partyId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Load payments for a specific party (stores in state)
  Future<void> loadPaymentsByParty(String userId, String partyId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _partyPayments = await getPaymentsByPartyUsecase(partyId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a payment
  Future<bool> deletePayment(String paymentId) async {
    try {
      _error = null;
      await deletePaymentUsecase(paymentId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Calculate total paid for a document
  double getTotalPaidForDocument(List<PaymentEntity> payments) {
    return payments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  // Calculate outstanding for a document
  double getOutstandingAmount(double totalAmount, List<PaymentEntity> payments) {
    final totalPaid = getTotalPaidForDocument(payments);
    return totalAmount - totalPaid;
  }
}


