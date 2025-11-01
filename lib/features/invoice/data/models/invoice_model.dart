import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/invoice_item_entity.dart';
import 'invoice_item_model.dart';

class InvoiceModel extends InvoiceEntity {
  const InvoiceModel({
    required super.id,
    required super.invoiceNumber,
    required super.invoiceType,
    required super.invoiceDate,
    super.dueDate,
    required super.partyId,
    required super.partyName,
    super.partyGstin,
    super.partyAddress,
    super.partyCity,
    super.partyState,
    super.partyPhone,
    required super.items,
    required super.subtotal,
    required super.totalDiscount,
    required super.taxableAmount,
    required super.cgst,
    required super.sgst,
    required super.igst,
    required super.totalTax,
    required super.grandTotal,
    required super.paymentStatus,
    super.paidAmount,
    required super.balanceAmount,
    super.notes,
    super.termsAndConditions,
    required super.isInterState,
    required super.userId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>)
        .map((item) => InvoiceItemModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return InvoiceModel(
      id: json['id'] as String,
      invoiceNumber: json['invoiceNumber'] as String,
      invoiceType: InvoiceType.values.firstWhere(
        (e) => e.name == json['invoiceType'],
      ),
      invoiceDate: (json['invoiceDate'] as Timestamp).toDate(),
      dueDate: json['dueDate'] != null
          ? (json['dueDate'] as Timestamp).toDate()
          : null,
      partyId: json['partyId'] as String,
      partyName: json['partyName'] as String,
      partyGstin: json['partyGstin'] as String?,
      partyAddress: json['partyAddress'] as String?,
      partyCity: json['partyCity'] as String?,
      partyState: json['partyState'] as String?,
      partyPhone: json['partyPhone'] as String?,
      items: itemsList,
      subtotal: (json['subtotal'] as num).toDouble(),
      totalDiscount: (json['totalDiscount'] as num).toDouble(),
      taxableAmount: (json['taxableAmount'] as num).toDouble(),
      cgst: (json['cgst'] as num).toDouble(),
      sgst: (json['sgst'] as num).toDouble(),
      igst: (json['igst'] as num).toDouble(),
      totalTax: (json['totalTax'] as num).toDouble(),
      grandTotal: (json['grandTotal'] as num).toDouble(),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
        orElse: () => PaymentStatus.unpaid,
      ),
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
      balanceAmount: (json['balanceAmount'] as num).toDouble(),
      notes: json['notes'] as String?,
      termsAndConditions: json['termsAndConditions'] as String?,
      isInterState: json['isInterState'] as bool,
      userId: json['userId'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'invoiceType': invoiceType.name,
      'invoiceDate': Timestamp.fromDate(invoiceDate),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'partyId': partyId,
      'partyName': partyName,
      'partyGstin': partyGstin,
      'partyAddress': partyAddress,
      'partyCity': partyCity,
      'partyState': partyState,
      'partyPhone': partyPhone,
      'items': items.map((item) => (item as InvoiceItemModel).toJson()).toList(),
      'subtotal': subtotal,
      'totalDiscount': totalDiscount,
      'taxableAmount': taxableAmount,
      'cgst': cgst,
      'sgst': sgst,
      'igst': igst,
      'totalTax': totalTax,
      'grandTotal': grandTotal,
      'paymentStatus': paymentStatus.name,
      'paidAmount': paidAmount,
      'balanceAmount': balanceAmount,
      'notes': notes,
      'termsAndConditions': termsAndConditions,
      'isInterState': isInterState,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

