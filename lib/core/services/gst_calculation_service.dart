import '../../features/invoice/domain/entities/invoice_item_entity.dart';

class GstCalculationService {
  // Calculate GST breakdown for an item
  static Map<String, double> calculateItemGst({
    required double taxableAmount,
    required double gstRate,
    required bool isInterState,
  }) {
    final totalTax = taxableAmount * (gstRate / 100);
    
    if (isInterState) {
      // Inter-state: IGST only
      return {
        'cgst': 0,
        'sgst': 0,
        'igst': totalTax,
        'totalTax': totalTax,
      };
    } else {
      // Intra-state: CGST + SGST (split equally)
      final cgst = totalTax / 2;
      final sgst = totalTax / 2;
      return {
        'cgst': cgst,
        'sgst': sgst,
        'igst': 0,
        'totalTax': totalTax,
      };
    }
  }

  // Calculate totals for invoice
  static Map<String, double> calculateInvoiceTotals({
    required List<InvoiceItemEntity> items,
    required bool isInterState,
  }) {
    double subtotal = 0;
    double totalDiscount = 0;
    double taxableAmount = 0;
    double cgst = 0;
    double sgst = 0;
    double igst = 0;
    double totalTax = 0;

    for (var item in items) {
      final gross = item.quantity * item.rate;
      final discountAmount = gross * (item.discount / 100);
      final itemTaxable = gross - discountAmount;
      
      subtotal += gross;
      totalDiscount += discountAmount;
      taxableAmount += itemTaxable;
      
      final gstBreakdown = calculateItemGst(
        taxableAmount: itemTaxable,
        gstRate: item.gstRate,
        isInterState: isInterState,
      );
      
      cgst += gstBreakdown['cgst']!;
      sgst += gstBreakdown['sgst']!;
      igst += gstBreakdown['igst']!;
      totalTax += gstBreakdown['totalTax']!;
    }

    final grandTotal = taxableAmount + totalTax;

    return {
      'subtotal': _roundToTwoDecimals(subtotal),
      'totalDiscount': _roundToTwoDecimals(totalDiscount),
      'taxableAmount': _roundToTwoDecimals(taxableAmount),
      'cgst': _roundToTwoDecimals(cgst),
      'sgst': _roundToTwoDecimals(sgst),
      'igst': _roundToTwoDecimals(igst),
      'totalTax': _roundToTwoDecimals(totalTax),
      'grandTotal': _roundToTwoDecimals(grandTotal),
    };
  }

  // Check if transaction is inter-state
  static bool isInterState({
    required String businessState,
    required String partyState,
  }) {
    return businessState.toLowerCase().trim() != partyState.toLowerCase().trim();
  }

  // Round to 2 decimal places
  static double _roundToTwoDecimals(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  // Get GST rate display
  static String getGstRateDisplay(double rate) {
    return '${rate.toStringAsFixed(0)}%';
  }

  // Common GST rates
  static const List<double> gstRates = [0, 0.25, 3, 5, 12, 18, 28];
}

