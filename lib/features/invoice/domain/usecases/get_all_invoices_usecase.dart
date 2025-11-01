import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/invoice_entity.dart';
import '../repositories/invoice_repository.dart';

class GetAllInvoicesUsecase implements Usecase<List<InvoiceEntity>, String> {
  final InvoiceRepository repository;

  GetAllInvoicesUsecase(this.repository);

  @override
  Future<Either<Failure, List<InvoiceEntity>>> call(String params) async {
    return await repository.getAllInvoices(params);
  }
}

