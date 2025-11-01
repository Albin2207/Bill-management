class AppConstants {
  // Indian States for GST
  static const List<String> indianStates = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Andaman and Nicobar Islands',
    'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi',
    'Jammu and Kashmir',
    'Ladakh',
    'Lakshadweep',
    'Puducherry',
  ];

  // Product Categories
  static const List<String> productCategories = [
    'Electronics',
    'Clothing',
    'Food & Beverages',
    'Groceries',
    'Furniture',
    'Stationery',
    'Hardware',
    'Services',
    'Other',
  ];

  // Product Units
  static const Map<String, String> productUnits = {
    'piece': 'Piece',
    'kg': 'Kilogram',
    'gram': 'Gram',
    'liter': 'Liter',
    'ml': 'Milliliter',
    'meter': 'Meter',
    'box': 'Box',
    'dozen': 'Dozen',
  };

  // GST Rates
  static const List<double> gstRates = [0, 0.25, 3, 5, 12, 18, 28];

  // Payment Terms
  static const List<String> paymentTerms = [
    'Cash',
    'UPI',
    'Bank Transfer',
    'Cheque',
    'Credit Card',
    'Net Banking',
  ];

  // Invoice Prefixes
  static const String invoicePrefix = 'INV';
  static const String billPrefix = 'BILL';
  static const String quotationPrefix = 'QUO';
  static const String deliveryChalanPrefix = 'DC';
  static const String creditNotePrefix = 'CN';
  static const String purchaseOrderPrefix = 'PO';
  static const String proFormaPrefix = 'PI';

  // Firestore Collections
  static const String partiesCollection = 'parties';
  static const String productsCollection = 'products';
  static const String invoicesCollection = 'invoices';
  static const String billsCollection = 'bills';
  static const String quotationsCollection = 'quotations';
  static const String settingsCollection = 'settings';
  static const String businessProfileCollection = 'business_profiles';
}

