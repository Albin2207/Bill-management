import 'package:flutter/foundation.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/usecases/add_invoice_usecase.dart';
import '../../domain/usecases/get_all_invoices_usecase.dart';
import '../../domain/usecases/update_invoice_status_usecase.dart';
import '../../../../core/error/failures.dart';

enum InvoiceListStatus {
  initial,
  loading,
  loaded,
  error,
}

class InvoiceProvider with ChangeNotifier {
  final AddInvoiceUsecase addInvoiceUsecase;
  final GetAllInvoicesUsecase getAllInvoicesUsecase;
  final UpdateInvoiceStatusUsecase updateInvoiceStatusUsecase;

  InvoiceProvider({
    required this.addInvoiceUsecase,
    required this.getAllInvoicesUsecase,
    required this.updateInvoiceStatusUsecase,
  });

  InvoiceListStatus _status = InvoiceListStatus.initial;
  List<InvoiceEntity> _invoices = [];
  Failure? _failure;
  String? _errorMessage;
  bool _isSaving = false;

  InvoiceListStatus get status => _status;
  List<InvoiceEntity> get invoices => _invoices;
  Failure? get failure => _failure;
  String? get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;

  Future<void> loadInvoices(String userId) async {
    _status = InvoiceListStatus.loading;
    notifyListeners();

    final result = await getAllInvoicesUsecase(userId);

    result.fold(
      (failure) {
        _status = InvoiceListStatus.error;
        _failure = failure;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (invoices) {
        _status = InvoiceListStatus.loaded;
        _invoices = invoices;
        _failure = null;
        _errorMessage = null;
        notifyListeners();
      },
    );
  }

  Future<bool> addInvoice(InvoiceEntity invoice) async {
    _isSaving = true;
    notifyListeners();

    final result = await addInvoiceUsecase(invoice);
    
    _isSaving = false;
    
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (invoiceId) {
        // Convert to model and add to list
        _invoices = [invoice, ..._invoices];
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> updateInvoiceStatus(String invoiceId, PaymentStatus status, double paidAmount) async {
    _isSaving = true;
    notifyListeners();

    final params = UpdateInvoiceStatusParams(
      invoiceId: invoiceId,
      status: status,
      paidAmount: paidAmount,
    );

    final result = await updateInvoiceStatusUsecase(params);
    
    _isSaving = false;
    
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        // Update the invoice in the list
        final index = _invoices.indexWhere((inv) => inv.id == invoiceId);
        if (index != -1) {
          // Create a new list with the updated invoice
          final updatedInvoices = List<InvoiceEntity>.from(_invoices);
          updatedInvoices[index] = InvoiceEntity(
            id: _invoices[index].id,
            invoiceNumber: _invoices[index].invoiceNumber,
            invoiceType: _invoices[index].invoiceType,
            invoiceDate: _invoices[index].invoiceDate,
            dueDate: _invoices[index].dueDate,
            partyId: _invoices[index].partyId,
            partyName: _invoices[index].partyName,
            partyGstin: _invoices[index].partyGstin,
            partyAddress: _invoices[index].partyAddress,
            partyCity: _invoices[index].partyCity,
            partyState: _invoices[index].partyState,
            partyPhone: _invoices[index].partyPhone,
            items: _invoices[index].items,
            subtotal: _invoices[index].subtotal,
            totalDiscount: _invoices[index].totalDiscount,
            taxableAmount: _invoices[index].taxableAmount,
            cgst: _invoices[index].cgst,
            sgst: _invoices[index].sgst,
            igst: _invoices[index].igst,
            totalTax: _invoices[index].totalTax,
            grandTotal: _invoices[index].grandTotal,
            paymentStatus: status,
            paidAmount: paidAmount,
            balanceAmount: _invoices[index].grandTotal - paidAmount,
            notes: _invoices[index].notes,
            termsAndConditions: _invoices[index].termsAndConditions,
            isInterState: _invoices[index].isInterState,
            userId: _invoices[index].userId,
            createdAt: _invoices[index].createdAt,
            updatedAt: DateTime.now(),
          );
          _invoices = updatedInvoices;
        }
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

