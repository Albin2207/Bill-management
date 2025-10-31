import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/presentation/providers/auth_provider.dart' as auth_provider;

final sl = GetIt.instance;

Future<void> init() async {
  // ========== External Dependencies ==========
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(
    () => GoogleSignIn(
      scopes: [
        'email',
        'profile',
      ],
    ),
  );

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
}

