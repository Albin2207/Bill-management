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
import '../../features/invoice/presentation/pages/sales_orders_list_page.dart';
import '../../features/invoice/presentation/pages/create_sales_order_page.dart';
import '../../features/invoice/presentation/pages/credit_notes_list_page.dart';
import '../../features/invoice/presentation/pages/create_credit_note_page.dart';
import '../../features/invoice/presentation/pages/pro_forma_list_page.dart';
import '../../features/invoice/presentation/pages/create_pro_forma_page.dart';
import '../../features/invoice/presentation/pages/purchases_list_page.dart';
import '../../features/invoice/presentation/pages/create_purchase_page.dart';
import '../../features/invoice/presentation/pages/purchase_orders_list_page.dart';
import '../../features/invoice/presentation/pages/create_purchase_order_page.dart';
import '../../features/invoice/presentation/pages/debit_notes_list_page.dart';
import '../../features/invoice/presentation/pages/create_debit_note_page.dart';
import '../../features/invoice/presentation/pages/quotations_list_page.dart';
import '../../features/invoice/presentation/pages/create_quotation_page.dart';
import '../../features/invoice/presentation/pages/delivery_challans_list_page.dart';
import '../../features/invoice/presentation/pages/create_delivery_challan_page.dart';
import '../../features/invoice/presentation/pages/expenses_list_page.dart';
import '../../features/invoice/presentation/pages/create_expense_page.dart';
import '../../features/invoice/presentation/pages/indirect_income_list_page.dart';
import '../../features/invoice/presentation/pages/create_indirect_income_page.dart';
import '../../features/bill/presentation/pages/create_bill_page.dart';
import '../../features/bill/presentation/pages/bills_list_page.dart';
import '../../features/party/presentation/pages/parties_list_page.dart';
import '../../features/party/presentation/pages/add_party_page.dart';
import '../../features/product/presentation/pages/products_list_page.dart';
import '../../features/product/presentation/pages/add_product_page.dart';
import '../../features/report/presentation/pages/reports_page.dart';
import '../../features/payment/presentation/pages/payments_page.dart';
import '../../features/home/presentation/pages/insights_page.dart';
import '../../features/gst_return/presentation/pages/gst_returns_page.dart';
import '../../features/ledger/presentation/pages/ledger_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/document_settings_page.dart';
import '../../features/accounting/presentation/pages/profit_loss_page.dart';
import '../../features/accounting/presentation/pages/ledger_page.dart' as accounting_ledger;
import '../../features/accounting/presentation/pages/gst_report_page.dart';
import '../../features/accounting/presentation/pages/stock_report_page.dart';
import '../../features/accounting/presentation/pages/trial_balance_page.dart';
import '../../features/business/presentation/pages/business_onboarding_page.dart';
import '../../features/business/presentation/pages/business_details_page.dart';
import '../../features/business/presentation/pages/business_logo_page.dart';
import '../../features/settings/presentation/pages/privacy_policy_page.dart';
import '../../features/settings/presentation/pages/feedback_page.dart';

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
  
  // Payment Route
  static const String payments = '/payments';
  
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
  
  // Accounting Routes
  static const String profitLoss = '/accounting/profit-loss';
  static const String gstReport = '/accounting/gst-report';
  static const String stockReport = '/accounting/stock-report';
  static const String trialBalance = '/accounting/trial-balance';
  
  // Business Routes
  static const String businessOnboarding = '/business-onboarding';
  static const String businessDetails = '/business-details';
  static const String businessLogo = '/business-logo';
  
  // Settings Routes
  static const String privacyPolicy = '/privacy-policy';
  static const String feedback = '/feedback';

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
      case createInvoice:
        return MaterialPageRoute(builder: (_) => const InvoicesListPage());
      
      // Bill Routes
      case bills:
        return MaterialPageRoute(builder: (_) => const BillsPage());
      case createBill:
        return MaterialPageRoute(builder: (_) => const CreateBillPage());
      
      // Party Routes
      case parties:
        return MaterialPageRoute(builder: (_) => const PartiesListPage());
      
      // Product Routes
      case products:
        return MaterialPageRoute(builder: (_) => const ProductsListPage());
      
      // Ledger Route (Accounting Ledger)
      case ledger:
        return MaterialPageRoute(builder: (_) => const accounting_ledger.LedgerPage());
      
      // Report Routes
      case reports:
        return MaterialPageRoute(builder: (_) => const ReportsPage());
      
      // Payment Route
      case payments:
        return MaterialPageRoute(builder: (_) => const PaymentsPage());
      
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
      
      // Sales Documents (List Pages)
      case createSalesOrder:
        return MaterialPageRoute(
          builder: (_) => const SalesOrdersListPage(),
        );
      case createCreditNote:
        return MaterialPageRoute(
          builder: (_) => const CreditNotesListPage(),
        );
      case createProForma:
        return MaterialPageRoute(
          builder: (_) => const ProFormaListPage(),
        );
      
      // Purchase Documents (List Pages)
      case createPurchase:
        return MaterialPageRoute(
          builder: (_) => const PurchasesListPage(),
        );
      case createPurchaseOrder:
        return MaterialPageRoute(
          builder: (_) => const PurchaseOrdersListPage(),
        );
      case createDebitNote:
        return MaterialPageRoute(
          builder: (_) => const DebitNotesListPage(),
        );
      
      // Quotation (List Page)
      case createQuotation:
        return MaterialPageRoute(
          builder: (_) => const QuotationsListPage(),
        );
      
      // Other Documents (List Pages)
      case createDeliveryChallan:
        return MaterialPageRoute(
          builder: (_) => const DeliveryChallansListPage(),
        );
      case createExpense:
        return MaterialPageRoute(
          builder: (_) => const ExpensesListPage(),
        );
      case createIndirectIncome:
        return MaterialPageRoute(
          builder: (_) => const IndirectIncomeListPage(),
        );
      
      // Quick Access
      case insights:
        return MaterialPageRoute(builder: (_) => const InsightsPage());
      case businessProfile:
      case eWayBill:
      case documentSettings:
        return MaterialPageRoute(builder: (_) => const DocumentSettingsPage());
      case eInvoice:
      case paymentsTimeline:
      case invoiceTemplates:
      case backupRestore:
        return MaterialPageRoute(
          builder: (_) => PlaceholderPage(
            title: _getPageTitle(routeSettings.name ?? ''),
          ),
        );
      
      // Accounting Routes
      case profitLoss:
        return MaterialPageRoute(builder: (_) => const ProfitLossPage());
      case gstReport:
        return MaterialPageRoute(builder: (_) => const GSTReportPage());
      case stockReport:
        return MaterialPageRoute(builder: (_) => const StockReportPage());
      case trialBalance:
        return MaterialPageRoute(builder: (_) => const TrialBalancePage());
      
      // Business Routes
      case businessOnboarding:
        return MaterialPageRoute(builder: (_) => const BusinessOnboardingPage());
      case businessDetails:
        return MaterialPageRoute(builder: (_) => const BusinessDetailsPage());
      case businessLogo:
        return MaterialPageRoute(builder: (_) => const BusinessLogoPage());
      
      // Settings Routes
      case privacyPolicy:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyPage());
      
      case feedback:
        return MaterialPageRoute(builder: (_) => const FeedbackPage());
      
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
  final bool showFAB;

  const PlaceholderPage({
    super.key,
    required this.title,
    this.showFAB = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Search
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              // TODO: Filter
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 120,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'No Documents Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first document to get started',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'This feature is under development',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: showFAB
          ? FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('This feature is coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add),
              label: Text('Create ${_extractDocType(title)}'),
            )
          : null,
    );
  }

  String _extractDocType(String title) {
    // Extract singular form from title
    if (title.endsWith('s')) {
      return title.substring(0, title.length - 1);
    }
    return title;
  }
}


