import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.documentId,
    required super.documentNumber,
    required super.documentType,
    required super.partyId,
    required super.partyName,
    required super.amount,
    required super.paymentDate,
    required super.method,
    super.referenceNumber,
    super.notes,
    super.razorpayPaymentId,
    super.razorpayOrderId,
    super.razorpaySignature,
    super.status,
    required super.direction,
    super.gatewayFees,
    required super.userId,
    required super.createdAt,
    super.updatedAt,
  });

  factory PaymentModel.fromEntity(PaymentEntity entity) {
    return PaymentModel(
      id: entity.id,
      documentId: entity.documentId,
      documentNumber: entity.documentNumber,
      documentType: entity.documentType,
      partyId: entity.partyId,
      partyName: entity.partyName,
      amount: entity.amount,
      paymentDate: entity.paymentDate,
      method: entity.method,
      referenceNumber: entity.referenceNumber,
      notes: entity.notes,
      razorpayPaymentId: entity.razorpayPaymentId,
      razorpayOrderId: entity.razorpayOrderId,
      razorpaySignature: entity.razorpaySignature,
      status: entity.status,
      direction: entity.direction,
      gatewayFees: entity.gatewayFees,
      userId: entity.userId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      documentId: json['documentId'] as String,
      documentNumber: json['documentNumber'] as String,
      documentType: json['documentType'] as String,
      partyId: json['partyId'] as String,
      partyName: json['partyName'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentDate: (json['paymentDate'] as Timestamp).toDate(),
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${json['method']}',
        orElse: () => PaymentMethod.cash,
      ),
      referenceNumber: json['referenceNumber'] as String?,
      notes: json['notes'] as String?,
      razorpayPaymentId: json['razorpayPaymentId'] as String?,
      razorpayOrderId: json['razorpayOrderId'] as String?,
      razorpaySignature: json['razorpaySignature'] as String?,
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == 'TransactionStatus.${json['status']}',
        orElse: () => TransactionStatus.success,
      ),
      direction: PaymentDirection.values.firstWhere(
        (e) => e.toString() == 'PaymentDirection.${json['direction']}',
        orElse: () => PaymentDirection.inward,
      ),
      gatewayFees: json['gatewayFees'] != null
          ? (json['gatewayFees'] as num).toDouble()
          : null,
      userId: json['userId'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'documentNumber': documentNumber,
      'documentType': documentType,
      'partyId': partyId,
      'partyName': partyName,
      'amount': amount,
      'paymentDate': Timestamp.fromDate(paymentDate),
      'method': method.toString().split('.').last,
      'referenceNumber': referenceNumber,
      'notes': notes,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpayOrderId': razorpayOrderId,
      'razorpaySignature': razorpaySignature,
      'status': status.toString().split('.').last,
      'direction': direction.toString().split('.').last,
      'gatewayFees': gatewayFees,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  PaymentModel copyWith({
    String? id,
    String? documentId,
    String? documentNumber,
    String? documentType,
    String? partyId,
    String? partyName,
    double? amount,
    DateTime? paymentDate,
    PaymentMethod? method,
    String? referenceNumber,
    String? notes,
    String? razorpayPaymentId,
    String? razorpayOrderId,
    String? razorpaySignature,
    TransactionStatus? status,
    PaymentDirection? direction,
    double? gatewayFees,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      documentNumber: documentNumber ?? this.documentNumber,
      documentType: documentType ?? this.documentType,
      partyId: partyId ?? this.partyId,
      partyName: partyName ?? this.partyName,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      method: method ?? this.method,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      razorpayPaymentId: razorpayPaymentId ?? this.razorpayPaymentId,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      razorpaySignature: razorpaySignature ?? this.razorpaySignature,
      status: status ?? this.status,
      direction: direction ?? this.direction,
      gatewayFees: gatewayFees ?? this.gatewayFees,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

