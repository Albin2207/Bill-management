import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/home/presentation/pages/main_navigation_page.dart';
import '../../features/home/presentation/pages/dashboard_page.dart';
import '../../features/bill/presentation/pages/bills_page.dart';
import '../../features/invoice/presentation/pages/create_invoice_page.dart';
import '../../features/invoice/presentation/pages/invoices_list_page.dart';
import '../../features/bill/presentation/pages/create_bill_page.dart';
import '../../features/bill/presentation/pages/bills_list_page.dart';
import '../../features/party/presentation/pages/parties_list_page.dart';
import '../../features/party/presentation/pages/add_party_page.dart';
import '../../features/product/presentation/pages/products_list_page.dart';
import '../../features/product/presentation/pages/add_product_page.dart';
import '../../features/report/presentation/pages/reports_page.dart';
import '../../features/gst_return/presentation/pages/gst_returns_page.dart';
import '../../features/ledger/presentation/pages/ledger_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

class AppRouter {
  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String signUp = '/signup';
  
  // Main Routes
  static const String home = '/home';
  
  // Invoice Routes
  static const String invoices = '/invoices';
  static const String createInvoice = '/invoices/create';
  
  // Bill Routes
  static const String bills = '/bills';
  static const String createBill = '/bills/create';
  
  // Party Routes
  static const String parties = '/parties';
  
  // Product Routes
  static const String products = '/products';
  
  // Ledger Route
  static const String ledger = '/ledger';
  
  // Report Routes
  static const String reports = '/reports';
  
  // GST Returns Route
  static const String gstReturns = '/gst-returns';
  
  // Settings Route
  static const String settings = '/settings';
  
  // Additional Routes
  static const String billsList = '/bills-list';
  static const String businessProfile = '/business-profile';
  static const String addProduct = '/products/add';
  static const String addParty = '/parties/add';
  
  // Sales Documents
  static const String createSalesOrder = '/sales-order/create';
  static const String createCreditNote = '/credit-note/create';
  static const String createProForma = '/pro-forma/create';
  
  // Purchase Documents
  static const String createPurchase = '/purchase/create';
  static const String createPurchaseOrder = '/purchase-order/create';
  static const String createDebitNote = '/debit-note/create';
  
  // Quotation
  static const String createQuotation = '/quotation/create';
  
  // Other Documents
  static const String createDeliveryChallan = '/delivery-challan/create';
  static const String createExpense = '/expense/create';
  static const String createIndirectIncome = '/indirect-income/create';
  
  // Quick Access
  static const String eWayBill = '/eway-bill';
  static const String eInvoice = '/einvoice';
  static const String paymentsTimeline = '/payments-timeline';
  static const String insights = '/insights';
  static const String invoiceTemplates = '/invoice-templates';
  static const String documentSettings = '/document-settings';
  static const String backupRestore = '/backup-restore';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      // Auth Routes
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpPage());
      
      // Main Routes
      case home:
        return MaterialPageRoute(builder: (_) => const MainNavigationPage());
      
      // Invoice Routes
      case invoices:
        return MaterialPageRoute(builder: (_) => const InvoicesListPage());
      case createInvoice:
        return MaterialPageRoute(builder: (_) => const CreateInvoicePage());
      
      // Bill Routes
      case bills:
        return MaterialPageRoute(builder: (_) => const BillsListPage());
      case createBill:
        return MaterialPageRoute(builder: (_) => const CreateBillPage());
      
      // Party Routes
      case parties:
        return MaterialPageRoute(builder: (_) => const PartiesListPage());
      
      // Product Routes
      case products:
        return MaterialPageRoute(builder: (_) => const ProductsListPage());
      
      // Ledger Route
      case ledger:
        return MaterialPageRoute(builder: (_) => const LedgerPage());
      
      // Report Routes
      case reports:
        return MaterialPageRoute(builder: (_) => const ReportsPage());
      
      // GST Returns Route
      case gstReturns:
        return MaterialPageRoute(builder: (_) => const GstReturnsPage());
      
      // Settings Route
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      
      // Additional Routes
      case billsList:
        return MaterialPageRoute(builder: (_) => const BillsPage());
      case addProduct:
        return MaterialPageRoute(builder: (_) => const AddProductPage());
      case addParty:
        return MaterialPageRoute(builder: (_) => const AddPartyPage());
      
      // Sales Documents
      case createSalesOrder:
      case createCreditNote:
      case createProForma:
      
      // Purchase Documents
      case createPurchase:
      case createPurchaseOrder:
      case createDebitNote:
      
      // Quotation
      case createQuotation:
      
      // Other Documents
      case createDeliveryChallan:
      case createExpense:
      case createIndirectIncome:
      
      // Quick Access
      case businessProfile:
      case eWayBill:
      case eInvoice:
      case paymentsTimeline:
      case insights:
      case invoiceTemplates:
      case documentSettings:
      case backupRestore:
        return MaterialPageRoute(
          builder: (_) => PlaceholderPage(
            title: _getPageTitle(routeSettings.name ?? ''),
          ),
        );
      
      // Not Found
      default:
        return MaterialPageRoute(
          builder: (_) => PlaceholderPage(
            title: 'Page Not Found',
          ),
        );
    }
  }
  
  static String _getPageTitle(String route) {
    final titles = {
      createSalesOrder: 'Create Sales Order',
      createCreditNote: 'Create Credit Note',
      createProForma: 'Create Pro Forma Invoice',
      createPurchase: 'Create Purchase',
      createPurchaseOrder: 'Create Purchase Order',
      createDebitNote: 'Create Debit Note',
      createQuotation: 'Create Quotation',
      createDeliveryChallan: 'Create Delivery Challan',
      createExpense: 'Create Expense',
      createIndirectIncome: 'Create Indirect Income',
      businessProfile: 'Business Profile',
      eWayBill: 'E-Way Bill',
      eInvoice: 'E-Invoice',
      paymentsTimeline: 'Payments Timeline',
      insights: 'Business Insights',
      invoiceTemplates: 'Invoice Templates',
      documentSettings: 'Document Settings',
      backupRestore: 'Backup & Restore',
    };
    return titles[route] ?? route;
  }
}

// Placeholder page for routes under development
class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: AppColors.onBackground.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This feature is under development',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onBackground.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


