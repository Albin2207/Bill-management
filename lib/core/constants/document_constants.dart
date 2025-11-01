class DocumentConstants {
  // Export Types
  static const List<String> exportTypes = [
    'Under Bond/LUT',
    'Export with IGST',
    'SEZ with IGST Payment',
    'Deemed Export',
  ];

  // Payment Methods
  static const List<String> paymentMethods = [
    'Cash',
    'Bank Transfer',
    'UPI',
    'Cheque',
    'Card',
    'Net Banking',
  ];

  // Document Prefixes
  static const List<String> invoicePrefixes = [
    'INV',
    'BILL',
    'SI',
    'TAX-INV',
  ];

  static const List<String> purchasePrefixes = [
    'PUR',
    'PO',
    'BILL',
  ];

  static const List<String> quotationPrefixes = [
    'QT',
    'QUOT',
    'EST',
  ];

  // Currencies (Major ones)
  static const Map<String, String> currencies = {
    'INR': '₹ Indian Rupee',
    'USD': '\$ US Dollar',
    'EUR': '€ Euro',
    'GBP': '£ British Pound',
    'AED': 'AED Dirham',
    'AUD': 'A\$ Australian Dollar',
    'CAD': 'C\$ Canadian Dollar',
    'SGD': 'S\$ Singapore Dollar',
    'JPY': '¥ Japanese Yen',
    'CNY': '¥ Chinese Yuan',
  };

  // Countries (Major trading partners)
  static const List<String> countries = [
    'India',
    'United States',
    'United Kingdom',
    'United Arab Emirates',
    'Saudi Arabia',
    'China',
    'Singapore',
    'Germany',
    'France',
    'Australia',
    'Canada',
    'Japan',
    'South Korea',
    'Malaysia',
    'Thailand',
    'Indonesia',
    'Bangladesh',
    'Sri Lanka',
    'Nepal',
  ];

  // Discount Types
  static const List<String> discountTypes = [
    'Percentage (%)',
    'Fixed Amount (₹)',
  ];

  // Price Display Options
  static const List<String> priceDisplayOptions = [
    'Unit Price',
    'Price with Tax',
    'Net Amount',
    'Total Amount',
  ];
}

