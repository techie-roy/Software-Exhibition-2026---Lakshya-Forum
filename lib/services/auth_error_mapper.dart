import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_auth_service.dart';

/// Maps FirebaseAuthException codes (and the not-configured case) to
/// user-friendly messages. Never includes credentials or tokens.
class AuthErrorMapper {
  static String messageFor(Object error) {
    if (error is FirebaseNotConfiguredException) {
      return 'Firebase is not configured yet. '
          'Ask the developer to finish Firebase setup, or continue with OTP login.';
    }
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'email-already-in-use':
          return 'This email is already registered. Try logging in or reset your password.';
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Invalid email or password. Please try again.';
        case 'user-disabled':
          return 'This account has been disabled. Contact support.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait a moment and try again.';
        case 'network-request-failed':
          return 'Network error. Check your connection and try again.';
        case 'operation-not-allowed':
          return 'Email/password sign-in is not enabled for this project.';
        default:
          return 'Authentication failed. Please try again.';
      }
    }
    return 'Something went wrong. Please try again.';
  }

  /// Phone-authentication-specific messages. Phone flows call this instead of
  /// [messageFor] so shared codes (`operation-not-allowed`) get phone wording.
  /// Never includes credentials, SMS codes, or verification ids.
  static String phoneAuthMessageFor(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'operation-not-allowed':
          return 'Phone sign-in is not enabled in the Firebase console. '
              'Enable Authentication → Sign-in method → Phone, then retry.';
        case 'app-not-authorized':
        case 'app-not-verified':
        case 'invalid-app-credential':
          return 'This app is not authorized for phone sign-in. Add the '
              'app SHA-1/SHA-256 fingerprint in the Firebase console.';
        case 'invalid-phone-number':
          return 'That phone number is not valid. Check the number and retry.';
        case 'invalid-verification-code':
          return 'That OTP code is not correct. Check the SMS and try again.';
        case 'session-expired':
        case 'code-expired':
          return 'The OTP expired. Request a new code.';
        case 'quota-exceeded':
          return 'SMS quota exceeded for today. Try again later, or contact '
              'the developer.';
        case 'phone-number-already-in-use':
          return 'This phone number is already linked to a different account.';
        case 'requires-recent-login':
          return 'For security, please sign out and sign in again before '
              'this change.';
        case 'invalid-credential':
          return 'That OTP code or verification session is no longer valid. '
              'Request a new code.';
        default:
          return 'Phone authentication error (${error.code}). '
              'Please try again or contact support.';
      }
    }
    return messageFor(error);
  }
}
