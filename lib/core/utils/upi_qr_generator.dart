/// UPI QR Code Generator Utility
/// Generates UPI payment QR codes as per NPCI standards
class UpiQrGenerator {
  /// Generates UPI deep link for payment
  /// 
  /// Parameters:
  /// - [upiId]: UPI ID of the payee (e.g., "business@paytm")
  /// - [payeeName]: Name of the business/payee
  /// - [amount]: Payment amount (optional for static QR)
  /// - [transactionNote]: Reference note (e.g., invoice number)
  /// - [transactionRef]: Unique transaction reference
  /// 
  /// Returns: UPI deep link string
  static String generateUpiLink({
    required String upiId,
    required String payeeName,
    double? amount,
    String? transactionNote,
    String? transactionRef,
  }) {
    // Validate UPI ID format (basic validation)
    if (!_isValidUpiId(upiId)) {
      throw ArgumentError('Invalid UPI ID format. Expected format: name@bank');
    }

    final params = <String, String>{};
    
    // Required parameters
    params['pa'] = upiId; // Payee Address
    params['pn'] = _sanitizeString(payeeName); // Payee Name
    params['cu'] = 'INR'; // Currency
    
    // Optional parameters
    if (amount != null && amount > 0) {
      params['am'] = amount.toStringAsFixed(2); // Amount
    }
    
    if (transactionNote != null && transactionNote.isNotEmpty) {
      params['tn'] = _sanitizeString(transactionNote); // Transaction Note
    }
    
    if (transactionRef != null && transactionRef.isNotEmpty) {
      params['tr'] = _sanitizeString(transactionRef); // Transaction Reference
    }

    // Build UPI URI
    final queryParams = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    return 'upi://pay?$queryParams';
  }

  /// Generates UPI link for invoice payment
  static String generateInvoicePaymentLink({
    required String upiId,
    required String businessName,
    required double amount,
    required String invoiceNumber,
  }) {
    return generateUpiLink(
      upiId: upiId,
      payeeName: businessName,
      amount: amount,
      transactionNote: 'Invoice-$invoiceNumber',
      transactionRef: invoiceNumber.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ''),
    );
  }

  /// Generates static UPI link (for general payments without amount)
  static String generateStaticPaymentLink({
    required String upiId,
    required String businessName,
  }) {
    return generateUpiLink(
      upiId: upiId,
      payeeName: businessName,
    );
  }

  /// Validates UPI ID format
  static bool _isValidUpiId(String upiId) {
    // Basic UPI ID validation: should contain @ and have text before and after it
    final regex = RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9]+$');
    return regex.hasMatch(upiId);
  }

  /// Validates UPI ID format (public method)
  static bool isValidUpiId(String upiId) {
    return _isValidUpiId(upiId);
  }

  /// Sanitizes string for UPI parameters
  static String _sanitizeString(String input) {
    // Remove special characters that might break UPI URI
    return input
        .replaceAll(RegExp(r'[&=?#]'), ' ')
        .trim();
  }

  /// Gets UPI apps available for payment
  static List<String> getSupportedUpiApps() {
    return [
      'Google Pay',
      'PhonePe',
      'Paytm',
      'BHIM UPI',
      'Amazon Pay',
      'WhatsApp Pay',
      'Cred',
      'Mobikwik',
      'Freecharge',
      'Any UPI App',
    ];
  }
}

