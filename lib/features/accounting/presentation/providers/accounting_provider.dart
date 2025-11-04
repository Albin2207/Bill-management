import 'package:flutter/foundation.dart';
import '../../../invoice/domain/entities/invoice_entity.dart';
import '../../../payment/domain/entities/payment_entity.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../../party/domain/entities/party_entity.dart';

class AccountingProvider extends ChangeNotifier {
  // Profit & Loss Calculation
  Map<String, double> calculateProfitLoss(
    List<InvoiceEntity> invoices,
    List<PaymentEntity> payments,
    DateTime startDate,
    DateTime endDate,
  ) {
    double revenue = 0;
    double expenses = 0;
    double cogs = 0; // Cost of Goods Sold
    // Note: COGS calculation would need product data, simplified here

    // Filter invoices by date range
    final filteredInvoices = invoices.where((inv) {
      return inv.invoiceDate.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
          inv.invoiceDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    for (var invoice in filteredInvoices) {
      if (invoice.paymentStatus == PaymentStatus.cancelled) continue;

      switch (invoice.invoiceType) {
        // Revenue items
        case InvoiceType.invoice:
        case InvoiceType.salesOrder:
          revenue += invoice.grandTotal;
          // COGS is simplified - ideally would use product purchase prices
          // For now, estimate as 60% of revenue
          cogs += invoice.grandTotal * 0.6;
          break;

        // Expense items
        case InvoiceType.bill:
        case InvoiceType.purchaseOrder:
          expenses += invoice.grandTotal;
          break;

        case InvoiceType.expense:
          expenses += invoice.grandTotal;
          break;

        case InvoiceType.indirectIncome:
          revenue += invoice.grandTotal;
          break;

        // Credit Note reduces revenue
        case InvoiceType.creditNote:
          revenue -= invoice.grandTotal;
          break;

        // Debit Note reduces expenses
        case InvoiceType.debitNote:
          expenses -= invoice.grandTotal;
          break;

        default:
          break;
      }
    }

    final grossProfit = revenue - cogs;
    final netProfit = grossProfit - expenses;

    return {
      'revenue': revenue,
      'cogs': cogs,
      'grossProfit': grossProfit,
      'expenses': expenses,
      'netProfit': netProfit,
    };
  }

  // GST Summary
  Map<String, dynamic> calculateGSTSummary(
    List<InvoiceEntity> invoices,
    DateTime startDate,
    DateTime endDate,
  ) {
    double gstCollected = 0; // Output GST (Sales)
    double gstPaid = 0;      // Input GST (Purchases)
    double cgst = 0;
    double sgst = 0;
    double igst = 0;

    final filteredInvoices = invoices.where((inv) {
      return inv.invoiceDate.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
          inv.invoiceDate.isBefore(endDate.add(const Duration(days: 1))) &&
          inv.paymentStatus != PaymentStatus.cancelled;
    }).toList();

    for (var invoice in filteredInvoices) {
      // Sales documents - GST Collected
      if (invoice.invoiceType == InvoiceType.invoice ||
          invoice.invoiceType == InvoiceType.salesOrder) {
        gstCollected += invoice.totalTax;
        cgst += invoice.cgst;
        sgst += invoice.sgst;
        igst += invoice.igst;
      }
      // Purchase documents - GST Paid
      else if (invoice.invoiceType == InvoiceType.bill ||
          invoice.invoiceType == InvoiceType.purchaseOrder) {
        gstPaid += invoice.totalTax;
      }
    }

    final gstPayable = gstCollected - gstPaid;

    return {
      'gstCollected': gstCollected,
      'gstPaid': gstPaid,
      'gstPayable': gstPayable,
      'cgst': cgst,
      'sgst': sgst,
      'igst': igst,
      'invoices': filteredInvoices,
    };
  }

  // Stock Valuation
  Map<String, dynamic> calculateStockReport(List<ProductEntity> products) {
    double totalStockValue = 0;
    int totalProducts = 0;
    int lowStockProducts = 0;
    int outOfStock = 0;

    for (var product in products) {
      if (product.trackStock) {
        totalProducts++;
        totalStockValue += (product.purchasePrice ?? 0) * product.stock;

        if (product.stock == 0) {
          outOfStock++;
        } else if (product.minStock != null && 
                   product.stock <= product.minStock!) {
          lowStockProducts++;
        }
      }
    }

    return {
      'totalStockValue': totalStockValue,
      'totalProducts': totalProducts,
      'lowStockProducts': lowStockProducts,
      'outOfStock': outOfStock,
      'products': products.where((p) => p.trackStock).toList(),
    };
  }

  // Party Ledger
  List<Map<String, dynamic>> getPartyLedger(
    String partyId,
    List<InvoiceEntity> invoices,
    List<PaymentEntity> payments,
    double openingBalance,
  ) {
    List<Map<String, dynamic>> entries = [];

    // Add opening balance
    if (openingBalance != 0) {
      entries.add({
        'date': DateTime(2000, 1, 1),
        'documentNumber': 'Opening',
        'type': 'opening',
        'debit': openingBalance > 0 ? openingBalance : 0.0,
        'credit': openingBalance < 0 ? openingBalance.abs() : 0.0,
        'balance': openingBalance,
        'description': 'Opening Balance',
      });
    }

    double runningBalance = openingBalance;

    // Add invoices
    final partyInvoices = invoices
        .where((inv) => inv.partyId == partyId && inv.paymentStatus != PaymentStatus.cancelled)
        .toList()
      ..sort((a, b) => a.invoiceDate.compareTo(b.invoiceDate));

    for (var invoice in partyInvoices) {
      double debit = 0.0;
      double credit = 0.0;

      // Sales documents - Debit (customer owes us)
      if (invoice.invoiceType == InvoiceType.invoice ||
          invoice.invoiceType == InvoiceType.salesOrder) {
        debit = invoice.grandTotal;
        runningBalance += debit;
      }
      // Purchase documents - Credit (we owe vendor)
      else if (invoice.invoiceType == InvoiceType.bill ||
          invoice.invoiceType == InvoiceType.purchaseOrder) {
        credit = invoice.grandTotal;
        runningBalance -= credit;
      }
      // Credit Note - Credit (reduces customer debt)
      else if (invoice.invoiceType == InvoiceType.creditNote) {
        credit = invoice.grandTotal;
        runningBalance -= credit;
      }
      // Debit Note - Debit (reduces our debt to vendor)
      else if (invoice.invoiceType == InvoiceType.debitNote) {
        debit = invoice.grandTotal;
        runningBalance += debit;
      }

      entries.add({
        'date': invoice.invoiceDate,
        'documentNumber': invoice.invoiceNumber,
        'type': invoice.invoiceType.toString().split('.').last,
        'debit': debit,
        'credit': credit,
        'balance': runningBalance,
        'description': '${invoice.invoiceType.toString().split('.').last} - ${invoice.invoiceNumber}',
      });
    }

    // Add payments
    final partyPayments = payments
        .where((p) => p.partyId == partyId)
        .toList()
      ..sort((a, b) => a.paymentDate.compareTo(b.paymentDate));

    for (var payment in partyPayments) {
      double debit = 0.0;
      double credit = 0.0;

      if (payment.direction == PaymentDirection.inward) {
        // Receipt - Credit (reduces customer debt)
        credit = payment.amount;
        runningBalance -= credit;
      } else {
        // Payment - Debit (reduces our debt to vendor)
        debit = payment.amount;
        runningBalance += debit;
      }

      entries.add({
        'date': payment.paymentDate,
        'documentNumber': payment.documentNumber,
        'type': payment.direction == PaymentDirection.inward ? 'receipt' : 'payment',
        'debit': debit,
        'credit': credit,
        'balance': runningBalance,
        'description': '${payment.direction == PaymentDirection.inward ? "Receipt" : "Payment"} - ${payment.paymentMethodName}',
      });
    }

    // Sort all entries by date
    entries.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    return entries;
  }

  // Trial Balance (Simplified)
  List<Map<String, dynamic>> getTrialBalance(
    List<PartyEntity> parties,
    List<InvoiceEntity> invoices,
    List<PaymentEntity> payments,
    List<ProductEntity> products,
  ) {
    List<Map<String, dynamic>> accounts = [];

    // Assets (Debit side)
    // 1. Cash/Bank (from payments)
    double cashReceived = payments
        .where((p) => p.direction == PaymentDirection.inward)
        .fold(0.0, (sum, p) => sum + p.amount);
    double cashPaid = payments
        .where((p) => p.direction == PaymentDirection.outward)
        .fold(0.0, (sum, p) => sum + p.amount);
    double cashBalance = cashReceived - cashPaid;

    accounts.add({
      'accountName': 'Cash/Bank',
      'type': 'Asset',
      'debit': cashBalance > 0 ? cashBalance : 0.0,
      'credit': cashBalance < 0 ? cashBalance.abs() : 0.0,
    });

    // 2. Accounts Receivable (Debtors)
    double totalReceivable = 0;
    for (var party in parties) {
      final partyInvoices = invoices.where((inv) =>
          inv.partyId == party.id &&
          (inv.invoiceType == InvoiceType.invoice || inv.invoiceType == InvoiceType.salesOrder) &&
          inv.paymentStatus != PaymentStatus.cancelled);
      final partyPayments = payments.where((p) =>
          p.partyId == party.id && p.direction == PaymentDirection.inward);
      
      final invoiceTotal = partyInvoices.fold(0.0, (sum, inv) => sum + inv.grandTotal);
      final paymentTotal = partyPayments.fold(0.0, (sum, p) => sum + p.amount);
      final balance = invoiceTotal - paymentTotal;
      
      if (balance > 0) totalReceivable += balance;
    }

    accounts.add({
      'accountName': 'Accounts Receivable (Debtors)',
      'type': 'Asset',
      'debit': totalReceivable,
      'credit': 0.0,
    });

    // 3. Stock/Inventory
    double stockValue = products
        .where((p) => p.trackStock)
        .fold(0.0, (sum, p) => sum + ((p.purchasePrice ?? 0) * p.stock));

    accounts.add({
      'accountName': 'Stock/Inventory',
      'type': 'Asset',
      'debit': stockValue,
      'credit': 0.0,
    });

    // Liabilities (Credit side)
    // 4. Accounts Payable (Creditors)
    double totalPayable = 0;
    for (var party in parties) {
      final partyInvoices = invoices.where((inv) =>
          inv.partyId == party.id &&
          (inv.invoiceType == InvoiceType.bill || inv.invoiceType == InvoiceType.purchaseOrder) &&
          inv.paymentStatus != PaymentStatus.cancelled);
      final partyPayments = payments.where((p) =>
          p.partyId == party.id && p.direction == PaymentDirection.outward);
      
      final invoiceTotal = partyInvoices.fold(0.0, (sum, inv) => sum + inv.grandTotal);
      final paymentTotal = partyPayments.fold(0.0, (sum, p) => sum + p.amount);
      final balance = invoiceTotal - paymentTotal;
      
      if (balance > 0) totalPayable += balance;
    }

    accounts.add({
      'accountName': 'Accounts Payable (Creditors)',
      'type': 'Liability',
      'debit': 0.0,
      'credit': totalPayable,
    });

    // Income (Credit side)
    double salesIncome = invoices
        .where((inv) =>
            (inv.invoiceType == InvoiceType.invoice || inv.invoiceType == InvoiceType.salesOrder) &&
            inv.paymentStatus != PaymentStatus.cancelled)
        .fold(0.0, (sum, inv) => sum + inv.grandTotal);

    accounts.add({
      'accountName': 'Sales Income',
      'type': 'Income',
      'debit': 0.0,
      'credit': salesIncome,
    });

    // Expenses (Debit side)
    double purchaseExpense = invoices
        .where((inv) =>
            (inv.invoiceType == InvoiceType.bill || inv.invoiceType == InvoiceType.purchaseOrder) &&
            inv.paymentStatus != PaymentStatus.cancelled)
        .fold(0.0, (sum, inv) => sum + inv.grandTotal);

    accounts.add({
      'accountName': 'Purchase Expense',
      'type': 'Expense',
      'debit': purchaseExpense,
      'credit': 0.0,
    });

    return accounts;
  }
}

