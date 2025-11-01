import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/invoice_model.dart';

abstract class InvoiceRemoteDataSource {
  Future<void> addInvoice(InvoiceModel invoice);
  Future<void> updateInvoice(InvoiceModel invoice);
  Future<void> deleteInvoice(String id);
  Future<List<InvoiceModel>> getAllInvoices(String userId);
  Future<InvoiceModel?> getInvoiceById(String id);
}

class InvoiceRemoteDataSourceImpl implements InvoiceRemoteDataSource {
  final FirebaseFirestore firestore;

  InvoiceRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> addInvoice(InvoiceModel invoice) async {
    try {
      await firestore.collection('invoices').doc(invoice.id).set(invoice.toJson());
    } catch (e) {
      throw ServerException('Failed to add invoice: ${e.toString()}');
    }
  }

  @override
  Future<void> updateInvoice(InvoiceModel invoice) async {
    try {
      await firestore.collection('invoices').doc(invoice.id).update(invoice.toJson());
    } catch (e) {
      throw ServerException('Failed to update invoice: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteInvoice(String id) async {
    try {
      await firestore.collection('invoices').doc(id).delete();
    } catch (e) {
      throw ServerException('Failed to delete invoice: ${e.toString()}');
    }
  }

  @override
  Future<List<InvoiceModel>> getAllInvoices(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('invoices')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => InvoiceModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch invoices: ${e.toString()}');
    }
  }

  @override
  Future<InvoiceModel?> getInvoiceById(String id) async {
    try {
      final doc = await firestore.collection('invoices').doc(id).get();
      if (doc.exists) {
        return InvoiceModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw ServerException('Failed to fetch invoice: ${e.toString()}');
    }
  }
}

