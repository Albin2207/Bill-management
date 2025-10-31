import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/home/presentation/pages/dashboard_page.dart';
import '../../features/invoice/presentation/pages/create_invoice_page.dart';
import '../../features/invoice/presentation/pages/invoices_list_page.dart';
import '../../features/bill/presentation/pages/create_bill_page.dart';
import '../../features/bill/presentation/pages/bills_list_page.dart';
import '../../features/party/presentation/pages/parties_list_page.dart';
import '../../features/product/presentation/pages/products_list_page.dart';
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
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      
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
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
            ),
          ),
        );
    }
  }
}

