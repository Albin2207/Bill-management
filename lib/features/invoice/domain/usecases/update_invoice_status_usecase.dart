import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/invoice_entity.dart';
import '../repositories/invoice_repository.dart';

class UpdateInvoiceStatusParams {
  final String invoiceId;
  final PaymentStatus status;
  final double paidAmount;

  UpdateInvoiceStatusParams({
    required this.invoiceId,
    required this.status,
    required this.paidAmount,
  });
}

class UpdateInvoiceStatusUsecase implements Usecase<void, UpdateInvoiceStatusParams> {
  final InvoiceRepository repository;

  UpdateInvoiceStatusUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateInvoiceStatusParams params) async {
    return await repository.updatePaymentStatus(
      params.invoiceId,
      params.status,
      params.paidAmount,
    );
  }
}

