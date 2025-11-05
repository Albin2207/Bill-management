import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/sign_in_with_email_usecase.dart';
import '../../domain/usecases/sign_up_with_email_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  final SignInWithEmailUsecase signInWithEmailUsecase;
  final SignUpWithEmailUsecase signUpWithEmailUsecase;
  final SignInWithGoogleUsecase signInWithGoogleUsecase;
  final GetCurrentUserUsecase getCurrentUserUsecase;
  final SignOutUsecase signOutUsecase;

  AuthProvider({
    required this.signInWithEmailUsecase,
    required this.signUpWithEmailUsecase,
    required this.signInWithGoogleUsecase,
    required this.getCurrentUserUsecase,
    required this.signOutUsecase,
  });

  AuthStatus _status = AuthStatus.initial;
  UserEntity? _user;
  Failure? _failure;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserEntity? get user => _user;
  Failure? get failure => _failure;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final result = await getCurrentUserUsecase(const NoParams());
    result.fold(
      (failure) {
        _status = AuthStatus.unauthenticated;
        _user = null;
        _failure = failure;
        _errorMessage = failure.message;
      },
      (user) {
        if (user != null) {
          _status = AuthStatus.authenticated;
          _user = user;
        } else {
          _status = AuthStatus.unauthenticated;
          _user = null;
        }
      },
    );
    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await signInWithEmailUsecase(
      SignInParams(email: email, password: password),
    );

    return result.fold(
      (failure) {
        _status = AuthStatus.error;
        _failure = failure;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (user) {
        _status = AuthStatus.authenticated;
        _user = user;
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> signUpWithEmail(String displayName, String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await signUpWithEmailUsecase(
      SignUpParams(displayName: displayName, email: email, password: password),
    );

    return result.fold(
      (failure) {
        _status = AuthStatus.error;
        _failure = failure;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (user) {
        _status = AuthStatus.authenticated;
        _user = user;
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> signInWithGoogle() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await signInWithGoogleUsecase(const NoParams());

    return result.fold(
      (failure) {
        // Don't show error if user cancelled - just reset to unauthenticated
        if (failure.code == 'sign_in_cancelled') {
          _status = AuthStatus.unauthenticated;
          _errorMessage = null;
        } else {
          _status = AuthStatus.error;
          _failure = failure;
          _errorMessage = failure.message;
        }
        notifyListeners();
        return false;
      },
      (user) {
        _status = AuthStatus.authenticated;
        _user = user;
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> signOut() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final result = await signOutUsecase(const NoParams());
    result.fold(
      (failure) {
        _status = AuthStatus.error;
        _failure = failure;
        _errorMessage = failure.message;
      },
      (_) {
        _status = AuthStatus.unauthenticated;
        _user = null;
        _errorMessage = null;
      },
    );
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _failure = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }
}

