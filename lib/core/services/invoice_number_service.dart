import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../../features/invoice/domain/entities/invoice_entity.dart';

class InvoiceNumberService {
  static Future<String> generateInvoiceNumber({
    required String userId,
    required InvoiceType invoiceType,
  }) async {
    final firestore = FirebaseFirestore.instance;
    
    // Get prefix based on invoice type
    final prefix = _getPrefix(invoiceType);
    
    // Get current year and month
    final now = DateTime.now();
    final year = now.year.toString().substring(2); // Last 2 digits
    final month = now.month.toString().padLeft(2, '0');
    
    // Generate counter document ID
    final counterId = '${userId}_${invoiceType.name}_$year$month';
    
    try {
      // Use transaction to ensure unique number
      return await firestore.runTransaction<String>((transaction) async {
        final counterRef = firestore
            .collection('counters')
            .doc(counterId);
        
        final counterDoc = await transaction.get(counterRef);
        
        int nextNumber;
        if (counterDoc.exists) {
          nextNumber = (counterDoc.data()?['count'] ?? 0) + 1;
        } else {
          nextNumber = 1;
        }
        
        transaction.set(counterRef, {
          'count': nextNumber,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        // Format: PREFIX/YY/MM/0001
        final numberStr = nextNumber.toString().padLeft(4, '0');
        return '$prefix/$year/$month/$numberStr';
      });
    } catch (e) {
      // Fallback if transaction fails
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return '$prefix/$year/$month/$timestamp';
    }
  }

  static String _getPrefix(InvoiceType type) {
    switch (type) {
      case InvoiceType.invoice:
        return AppConstants.invoicePrefix;
      case InvoiceType.bill:
        return AppConstants.billPrefix;
      case InvoiceType.quotation:
        return AppConstants.quotationPrefix;
      case InvoiceType.deliveryChalan:
        return AppConstants.deliveryChalanPrefix;
      case InvoiceType.creditNote:
        return AppConstants.creditNotePrefix;
      case InvoiceType.purchaseOrder:
        return AppConstants.purchaseOrderPrefix;
      case InvoiceType.proFormaInvoice:
        return AppConstants.proFormaPrefix;
    }
  }
}

