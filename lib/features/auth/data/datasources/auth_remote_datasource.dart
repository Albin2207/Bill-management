import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/error/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<User> signInWithEmail({
    required String email,
    required String password,
  });
  
  Future<User> signUpWithEmail({
    required String displayName,
    required String email,
    required String password,
  });
  
  Future<User> signInWithGoogle();
  
  Future<void> signOut();
  
  User? getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) {
        throw const AuthException(
          'Authentication failed: No user returned',
          code: 'no_user',
        );
      }
      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        e.message ?? 'Authentication failed',
        code: e.code,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Failed to sign in: ${e.toString()}');
    }
  }

  @override
  Future<User> signUpWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) {
        throw const AuthException(
          'Registration failed: No user returned',
          code: 'no_user',
        );
      }
      
      // Update user profile with display name
      await userCredential.user!.updateDisplayName(displayName);
      await userCredential.user!.reload();
      
      // Return the updated user
      return firebaseAuth.currentUser!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        e.message ?? 'Registration failed',
        code: e.code,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Failed to sign up: ${e.toString()}');
    }
  }

  @override
  Future<User> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      // Check if user cancelled the sign-in
      if (googleUser == null) {
        throw const AuthException(
          'Google sign in was cancelled by the user',
          code: 'sign_in_cancelled',
        );
      }

      // Obtain the auth details - authentication is a Future in version 6.x
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Check if we have idToken (required for Firebase Auth)
      if (googleAuth.idToken == null) {
        throw const AuthException(
          'Failed to get authentication tokens from Google',
          code: 'missing_tokens',
        );
      }

      // Create a new credential - both idToken and accessToken are available in 6.3.0
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await firebaseAuth.signInWithCredential(credential);
      
      // Check if we got a user
      if (userCredential.user == null) {
        throw const AuthException(
          'Failed to sign in with Google: No user returned',
          code: 'no_user',
        );
      }

      return userCredential.user!;
    } on PlatformException catch (e) {
      throw AuthException(
        e.message ?? 'Platform error during Google sign in',
        code: e.code,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        e.message ?? 'Google sign in failed',
        code: e.code,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        'Failed to sign in with Google: ${e.toString()}',
        code: 'unknown_error',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        firebaseAuth.signOut(),
        googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException('Failed to sign out: ${e.toString()}');
    }
  }

  @override
  User? getCurrentUser() {
    return firebaseAuth.currentUser;
  }
}

