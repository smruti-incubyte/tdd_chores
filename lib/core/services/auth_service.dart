import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum AuthError {
  networkError,
  userCancelled,
  accountExistsWithDifferentCredential,
  invalidCredential,
  operationNotAllowed,
  userDisabled,
  unknown,
}

class AuthException implements Exception {
  final AuthError error;
  final String message;

  AuthException(this.error, this.message);

  @override
  String toString() => message;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(
        AuthError.unknown,
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      throw AuthException(
        AuthError.unknown,
        'Failed to sign out: ${e.toString()}',
      );
    }
  }

  AuthException _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return AuthException(
          AuthError.accountExistsWithDifferentCredential,
          'An account already exists with the same email but different sign-in credentials.',
        );
      case 'invalid-credential':
        return AuthException(
          AuthError.invalidCredential,
          'The credential is malformed or has expired.',
        );
      case 'operation-not-allowed':
        return AuthException(
          AuthError.operationNotAllowed,
          'Google sign-in is not enabled. Please contact support.',
        );
      case 'user-disabled':
        return AuthException(
          AuthError.userDisabled,
          'This account has been disabled.',
        );
      case 'network-request-failed':
        return AuthException(
          AuthError.networkError,
          'Network error. Please check your internet connection.',
        );
      default:
        return AuthException(
          AuthError.unknown,
          e.message ?? 'An unknown error occurred during sign-in.',
        );
    }
  }
}
