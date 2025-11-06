import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/cloudinary_service.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/presentation/providers/auth_provider.dart' as auth_provider;
import '../../features/party/data/datasources/party_remote_datasource.dart';
import '../../features/party/data/repositories/party_repository_impl.dart';
import '../../features/party/domain/repositories/party_repository.dart';
import '../../features/party/domain/usecases/add_party_usecase.dart';
import '../../features/party/domain/usecases/get_all_parties_usecase.dart';
import '../../features/party/domain/usecases/update_party_usecase.dart';
import '../../features/party/domain/usecases/delete_party_usecase.dart';
import '../../features/party/presentation/providers/party_provider.dart';
import '../../features/product/data/datasources/product_remote_datasource.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/domain/usecases/add_product_usecase.dart';
import '../../features/product/domain/usecases/get_all_products_usecase.dart';
import '../../features/product/domain/usecases/update_product_usecase.dart';
import '../../features/product/domain/usecases/delete_product_usecase.dart';
import '../../features/product/presentation/providers/product_provider.dart';
import '../../features/invoice/data/datasources/invoice_remote_datasource.dart';
import '../../features/invoice/data/repositories/invoice_repository_impl.dart';
import '../../features/invoice/domain/repositories/invoice_repository.dart';
import '../../features/invoice/domain/usecases/add_invoice_usecase.dart';
import '../../features/invoice/domain/usecases/get_all_invoices_usecase.dart';
import '../../features/invoice/domain/usecases/update_invoice_status_usecase.dart';
import '../../features/invoice/presentation/providers/invoice_provider.dart';
import '../../features/settings/data/datasources/document_settings_remote_datasource.dart';
import '../../features/settings/data/repositories/document_settings_repository_impl.dart';
import '../../features/settings/domain/repositories/document_settings_repository.dart';
import '../../features/settings/domain/usecases/get_document_settings_usecase.dart';
import '../../features/settings/domain/usecases/save_document_settings_usecase.dart';
import '../../features/settings/presentation/providers/document_settings_provider.dart';
import '../../features/payment/data/datasources/payment_remote_datasource.dart';
import '../../features/payment/data/repositories/payment_repository_impl.dart';
import '../../features/payment/domain/repositories/payment_repository.dart';
import '../../features/payment/domain/usecases/add_payment_usecase.dart';
import '../../features/payment/domain/usecases/get_all_payments_usecase.dart';
import '../../features/payment/domain/usecases/get_payments_by_document_usecase.dart';
import '../../features/payment/domain/usecases/get_payments_by_party_usecase.dart';
import '../../features/payment/domain/usecases/delete_payment_usecase.dart';
import '../../features/payment/presentation/providers/payment_provider.dart';
import '../../features/accounting/presentation/providers/accounting_provider.dart';
import '../../features/business/data/datasources/business_remote_datasource.dart';
import '../../features/business/data/repositories/business_repository_impl.dart';
import '../../features/business/domain/repositories/business_repository.dart';
import '../../features/business/domain/usecases/get_business_usecase.dart';
import '../../features/business/domain/usecases/save_business_usecase.dart';
import '../../features/business/domain/usecases/update_business_usecase.dart';
import '../../features/business/presentation/providers/business_provider.dart';
import '../../features/onboarding/data/datasources/onboarding_local_datasource.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../core/theme/theme_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ========== External Dependencies ==========
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(
    () => GoogleSignIn(
      scopes: [
        'email',
        'profile',
      ],
    ),
  );
  
  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  // ========== Services ==========
  sl.registerLazySingleton(() => CloudinaryService());

  // ========== Auth Feature ==========
  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      googleSignIn: sl(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => SignInWithEmailUsecase(sl()));
  sl.registerLazySingleton(() => SignUpWithEmailUsecase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUsecase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUsecase(sl()));
  sl.registerLazySingleton(() => SignOutUsecase(sl()));

  // Providers
  sl.registerFactory(
    () => auth_provider.AuthProvider(
      signInWithEmailUsecase: sl(),
      signUpWithEmailUsecase: sl(),
      signInWithGoogleUsecase: sl(),
      getCurrentUserUsecase: sl(),
      signOutUsecase: sl(),
    ),
  );

  // ========== Party Feature ==========
  // Data Sources
  sl.registerLazySingleton<PartyRemoteDataSource>(
    () => PartyRemoteDataSourceImpl(firestore: sl()),
  );

  // Repositories
  sl.registerLazySingleton<PartyRepository>(
    () => PartyRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => AddPartyUsecase(sl()));
  sl.registerLazySingleton(() => GetAllPartiesUsecase(sl()));
  sl.registerLazySingleton(() => UpdatePartyUsecase(sl()));
  sl.registerLazySingleton(() => DeletePartyUsecase(sl()));

  // Providers
  sl.registerFactory(
    () => PartyProvider(
      addPartyUsecase: sl(),
      getAllPartiesUsecase: sl(),
      updatePartyUsecase: sl(),
      deletePartyUsecase: sl(),
    ),
  );

  // ========== Product Feature ==========
  // Data Sources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(firestore: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => AddProductUsecase(sl()));
  sl.registerLazySingleton(() => GetAllProductsUsecase(sl()));
  sl.registerLazySingleton(() => UpdateProductUsecase(sl()));
  sl.registerLazySingleton(() => DeleteProductUsecase(sl()));

  // Providers
  sl.registerFactory(
    () => ProductProvider(
      addProductUsecase: sl(),
      getAllProductsUsecase: sl(),
      updateProductUsecase: sl(),
      deleteProductUsecase: sl(),
    ),
  );

  // ========== Invoice Feature ==========
  // Data Sources
  sl.registerLazySingleton<InvoiceRemoteDataSource>(
    () => InvoiceRemoteDataSourceImpl(firestore: sl()),
  );

  // Repositories
  sl.registerLazySingleton<InvoiceRepository>(
    () => InvoiceRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => AddInvoiceUsecase(sl()));
  sl.registerLazySingleton(() => GetAllInvoicesUsecase(sl()));
  sl.registerLazySingleton(() => UpdateInvoiceStatusUsecase(sl()));

  // Providers
  sl.registerFactory(
    () => InvoiceProvider(
      addInvoiceUsecase: sl(),
      getAllInvoicesUsecase: sl(),
      updateInvoiceStatusUsecase: sl(),
    ),
  );

  // ========== Document Settings Feature ==========
  // Data Sources
  sl.registerLazySingleton<DocumentSettingsRemoteDataSource>(
    () => DocumentSettingsRemoteDataSourceImpl(firestore: sl()),
  );

  // Repositories
  sl.registerLazySingleton<DocumentSettingsRepository>(
    () => DocumentSettingsRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetDocumentSettingsUsecase(sl()));
  sl.registerLazySingleton(() => SaveDocumentSettingsUsecase(sl()));

  // Providers
  sl.registerFactory(
    () => DocumentSettingsProvider(
      getDocumentSettingsUsecase: sl(),
      saveDocumentSettingsUsecase: sl(),
    ),
  );

  // ========== Payment Feature ==========
  // Data Sources
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(firestore: sl()),
  );

  // Repositories
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => AddPaymentUsecase(sl()));
  sl.registerLazySingleton(() => GetAllPaymentsUsecase(sl()));
  sl.registerLazySingleton(() => GetPaymentsByDocumentUsecase(sl()));
  sl.registerLazySingleton(() => GetPaymentsByPartyUsecase(sl()));
  sl.registerLazySingleton(() => DeletePaymentUsecase(sl()));

  // Providers
  sl.registerFactory(
    () => PaymentProvider(
      addPaymentUsecase: sl(),
      getAllPaymentsUsecase: sl(),
      getPaymentsByDocumentUsecase: sl(),
      getPaymentsByPartyUsecase: sl(),
      deletePaymentUsecase: sl(),
    ),
  );

  // ========== Accounting Feature ==========
  // No data layer needed - uses existing invoice/payment data
  // Provider only
  sl.registerFactory(() => AccountingProvider());

  // ========== Business Feature ==========
  // Data Sources
  sl.registerLazySingleton<BusinessRemoteDataSource>(
    () => BusinessRemoteDataSourceImpl(firestore: sl()),
  );

  // Repositories
  sl.registerLazySingleton<BusinessRepository>(
    () => BusinessRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetBusinessUsecase(sl()));
  sl.registerLazySingleton(() => SaveBusinessUsecase(sl()));
  sl.registerLazySingleton(() => UpdateBusinessUsecase(sl()));

  // Providers
  sl.registerFactory(
    () => BusinessProvider(
      getBusinessUsecase: sl(),
      saveBusinessUsecase: sl(),
      updateBusinessUsecase: sl(),
    ),
  );

  // ========== Onboarding Feature ==========
  // Data Sources
  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repositories
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(localDataSource: sl()),
  );

  // Providers
  sl.registerFactory(
    () => OnboardingProvider(repository: sl()),
  );

  // ========== Theme ==========
  sl.registerLazySingleton(
    () => ThemeProvider(sl()),
  );
}

