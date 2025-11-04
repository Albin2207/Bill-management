import 'package:equatable/equatable.dart';

enum LedgerEntryType {
  invoice,
  bill,
  payment,
  receipt,
  creditNote,
  debitNote,
  opening,
}

class LedgerEntryEntity extends Equatable {
  final String id;
  final String partyId;
  final String partyName;
  final DateTime date;
  final String documentNumber;
  final LedgerEntryType type;
  final double debit;  // Money owed to us / Expense
  final double credit; // Money we owe / Income
  final double balance;
  final String? description;

  const LedgerEntryEntity({
    required this.id,
    required this.partyId,
    required this.partyName,
    required this.date,
    required this.documentNumber,
    required this.type,
    required this.debit,
    required this.credit,
    required this.balance,
    this.description,
  });

  @override
  List<Object?> get props => [
        id,
        partyId,
        partyName,
        date,
        documentNumber,
        type,
        debit,
        credit,
        balance,
        description,
      ];
}

