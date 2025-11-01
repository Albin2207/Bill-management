import 'package:equatable/equatable.dart';
import 'invoice_item_entity.dart';

enum InvoiceType {
  invoice,
  bill,
  quotation,
  deliveryChalan,
  creditNote,
  purchaseOrder,
  proFormaInvoice,
}

enum PaymentStatus {
  paid,
  unpaid,
  partial,
}

class InvoiceEntity extends Equatable {
  final String id;
  final String invoiceNumber;
  final InvoiceType invoiceType;
  final DateTime invoiceDate;
  final DateTime? dueDate;
  
  // Party Details
  final String partyId;
  final String partyName;
  final String? partyGstin;
  final String? partyAddress;
  final String? partyCity;
  final String? partyState;
  final String? partyPhone;
  
  // Items
  final List<InvoiceItemEntity> items;
  
  // Calculations
  final double subtotal; // Before tax
  final double totalDiscount;
  final double taxableAmount;
  final double cgst;
  final double sgst;
  final double igst;
  final double totalTax;
  final double grandTotal;
  
  // Payment
  final PaymentStatus paymentStatus;
  final double paidAmount;
  final double balanceAmount;
  
  // Additional
  final String? notes;
  final String? termsAndConditions;
  final bool isInterState; // For IGST vs CGST+SGST
  
  // Metadata
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InvoiceEntity({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceType,
    required this.invoiceDate,
    this.dueDate,
    required this.partyId,
    required this.partyName,
    this.partyGstin,
    this.partyAddress,
    this.partyCity,
    this.partyState,
    this.partyPhone,
    required this.items,
    required this.subtotal,
    required this.totalDiscount,
    required this.taxableAmount,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.totalTax,
    required this.grandTotal,
    required this.paymentStatus,
    this.paidAmount = 0,
    required this.balanceAmount,
    this.notes,
    this.termsAndConditions,
    required this.isInterState,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        invoiceType,
        invoiceDate,
        dueDate,
        partyId,
        partyName,
        partyGstin,
        partyAddress,
        partyCity,
        partyState,
        partyPhone,
        items,
        subtotal,
        totalDiscount,
        taxableAmount,
        cgst,
        sgst,
        igst,
        totalTax,
        grandTotal,
        paymentStatus,
        paidAmount,
        balanceAmount,
        notes,
        termsAndConditions,
        isInterState,
        userId,
        createdAt,
        updatedAt,
      ];
}

