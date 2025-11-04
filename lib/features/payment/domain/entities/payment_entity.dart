import 'package:equatable/equatable.dart';

enum PaymentMethod {
  cash,
  upi,
  card,
  bankTransfer,
  cheque,
  razorpayOnline,
  razorpayLink,
  other
}

enum TransactionStatus {
  success,
  pending,
  failed,
  refunded
}

enum PaymentDirection {
  inward,   // Money received (from customers)
  outward   // Money paid (to vendors)
}

class PaymentEntity extends Equatable {
  final String id;
  final String documentId;
  final String documentNumber;
  final String documentType;
  final String partyId;
  final String partyName;
  final double amount;
  final DateTime paymentDate;
  final PaymentMethod method;
  final String? referenceNumber;
  final String? notes;
  final String? razorpayPaymentId;
  final String? razorpayOrderId;
  final String? razorpaySignature;
  final TransactionStatus status;
  final PaymentDirection direction;
  final double? gatewayFees;
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PaymentEntity({
    required this.id,
    required this.documentId,
    required this.documentNumber,
    required this.documentType,
    required this.partyId,
    required this.partyName,
    required this.amount,
    required this.paymentDate,
    required this.method,
    this.referenceNumber,
    this.notes,
    this.razorpayPaymentId,
    this.razorpayOrderId,
    this.razorpaySignature,
    this.status = TransactionStatus.success,
    required this.direction,
    this.gatewayFees,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        documentId,
        documentNumber,
        documentType,
        partyId,
        partyName,
        amount,
        paymentDate,
        method,
        referenceNumber,
        notes,
        razorpayPaymentId,
        razorpayOrderId,
        razorpaySignature,
        status,
        direction,
        gatewayFees,
        userId,
        createdAt,
        updatedAt,
      ];

  String get paymentMethodName {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.cheque:
        return 'Cheque';
      case PaymentMethod.razorpayOnline:
        return 'Razorpay Online';
      case PaymentMethod.razorpayLink:
        return 'Razorpay Link';
      case PaymentMethod.other:
        return 'Other';
    }
  }
}

