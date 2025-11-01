import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/invoice_entity.dart';
import '../repositories/invoice_repository.dart';

class AddInvoiceUsecase implements Usecase<String, InvoiceEntity> {
  final InvoiceRepository repository;

  AddInvoiceUsecase(this.repository);

  @override
  Future<Either<Failure, String>> call(InvoiceEntity params) async {
    return await repository.createInvoice(params);
  }
}

