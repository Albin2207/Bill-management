import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/di/service_locator.dart' as di;
import 'core/navigation/app_router.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/party/presentation/providers/party_provider.dart';
import 'features/product/presentation/providers/product_provider.dart';
import 'features/invoice/presentation/providers/invoice_provider.dart';
import 'features/settings/presentation/providers/document_settings_provider.dart';
import 'features/payment/presentation/providers/payment_provider.dart';
import 'features/accounting/presentation/providers/accounting_provider.dart';
import 'features/business/presentation/providers/business_provider.dart';
import 'features/onboarding/presentation/providers/onboarding_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Dependency Injection
    await di.init();
    
    runApp(const MyApp());
  } catch (e, stackTrace) {
    // Handle initialization errors
    debugPrint('Error during app initialization: $e');
    debugPrint('Stack trace: $stackTrace');
    
    // Run app with error handler
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Initialization Error: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  main();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set up error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Flutter Error: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');
    };

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => di.sl<AuthProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<PartyProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<ProductProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<InvoiceProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<DocumentSettingsProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<PaymentProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<AccountingProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<BusinessProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<OnboardingProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<ThemeProvider>(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Billing Management',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: AppRouter.splash,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}

