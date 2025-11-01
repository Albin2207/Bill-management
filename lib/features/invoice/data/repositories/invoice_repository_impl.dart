import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../datasources/invoice_remote_datasource.dart';
import '../models/invoice_model.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceRemoteDataSource remoteDataSource;

  InvoiceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> createInvoice(InvoiceEntity invoice) async {
    try {
      final invoiceModel = InvoiceModel.fromEntity(invoice);
      await remoteDataSource.addInvoice(invoiceModel);
      return Right(invoice.id);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to add invoice: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateInvoice(InvoiceEntity invoice) async {
    try {
      final invoiceModel = InvoiceModel.fromEntity(invoice);
      await remoteDataSource.updateInvoice(invoiceModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update invoice: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteInvoice(String id) async {
    try {
      await remoteDataSource.deleteInvoice(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to delete invoice: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<InvoiceEntity>>> getAllInvoices(String userId) async {
    try {
      final invoices = await remoteDataSource.getAllInvoices(userId);
      return Right(invoices);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch invoices: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, InvoiceEntity>> getInvoice(String id) async {
    try {
      final invoice = await remoteDataSource.getInvoiceById(id);
      if (invoice == null) {
        return Left(ServerFailure('Invoice not found'));
      }
      return Right(invoice);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch invoice: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<InvoiceEntity>>> getInvoicesByType(
    String userId,
    InvoiceType type,
  ) async {
    try {
      final allInvoices = await remoteDataSource.getAllInvoices(userId);
      final filtered = allInvoices.where((i) => i.invoiceType == type).toList();
      return Right(filtered);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch invoices: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<InvoiceEntity>>> watchInvoicesByType(
    String userId,
    InvoiceType type,
  ) async* {
    // TODO: Implement real-time streaming
    final result = await getAllInvoices(userId);
    yield result;
  }

  @override
  Future<Either<Failure, List<InvoiceEntity>>> getRecentInvoices(
    String userId, {
    int limit = 10,
  }) async {
    try {
      final invoices = await remoteDataSource.getAllInvoices(userId);
      final recent = invoices.take(limit).toList();
      return Right(recent);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch invoices: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePaymentStatus(
    String id,
    PaymentStatus status,
    double paidAmount,
  ) async {
    try {
      final invoice = await remoteDataSource.getInvoiceById(id);
      if (invoice == null) {
        return Left(ServerFailure('Invoice not found'));
      }
      
      final updatedInvoice = InvoiceModel(
        id: invoice.id,
        invoiceNumber: invoice.invoiceNumber,
        invoiceType: invoice.invoiceType,
        invoiceDate: invoice.invoiceDate,
        dueDate: invoice.dueDate,
        partyId: invoice.partyId,
        partyName: invoice.partyName,
        partyGstin: invoice.partyGstin,
        partyAddress: invoice.partyAddress,
        partyCity: invoice.partyCity,
        partyState: invoice.partyState,
        partyPhone: invoice.partyPhone,
        items: invoice.items,
        subtotal: invoice.subtotal,
        totalDiscount: invoice.totalDiscount,
        taxableAmount: invoice.taxableAmount,
        cgst: invoice.cgst,
        sgst: invoice.sgst,
        igst: invoice.igst,
        totalTax: invoice.totalTax,
        grandTotal: invoice.grandTotal,
        paymentStatus: status,
        paidAmount: paidAmount,
        balanceAmount: invoice.grandTotal - paidAmount,
        notes: invoice.notes,
        termsAndConditions: invoice.termsAndConditions,
        isInterState: invoice.isInterState,
        userId: invoice.userId,
        createdAt: invoice.createdAt,
        updatedAt: DateTime.now(),
      );
      
      await remoteDataSource.updateInvoice(updatedInvoice);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update payment status: ${e.toString()}'));
    }
  }
}

