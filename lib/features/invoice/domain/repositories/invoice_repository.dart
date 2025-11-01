import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/invoice_entity.dart';

abstract class InvoiceRepository {
  Future<Either<Failure, String>> createInvoice(InvoiceEntity invoice);
  Future<Either<Failure, void>> updateInvoice(InvoiceEntity invoice);
  Future<Either<Failure, void>> deleteInvoice(String id);
  Future<Either<Failure, InvoiceEntity>> getInvoice(String id);
  Future<Either<Failure, List<InvoiceEntity>>> getAllInvoices(String userId);
  Future<Either<Failure, List<InvoiceEntity>>> getInvoicesByType(
    String userId,
    InvoiceType type,
  );
  Stream<Either<Failure, List<InvoiceEntity>>> watchInvoicesByType(
    String userId,
    InvoiceType type,
  );
  Future<Either<Failure, List<InvoiceEntity>>> getRecentInvoices(
    String userId, {
    int limit = 10,
  });
  Future<Either<Failure, void>> updatePaymentStatus(
    String id,
    PaymentStatus status,
    double paidAmount,
  );
}

