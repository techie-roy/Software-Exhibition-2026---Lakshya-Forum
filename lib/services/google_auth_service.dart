import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_auth_service.dart';

/// Result of a Google sign-in attempt.
enum GoogleAuthStatus {
  /// The user chose an account and Firebase accepted the credential.
  success,

  /// The user dismissed the account chooser / sign-in UI.
  canceled,

  /// Google Sign-In could not run because it is not (yet) configured, or the
  /// platform does not support the interactive flow.
  unavailable,

  /// Any other failure (network, invalid token, unknown platform error).
  failed,
}

/// Outcome of [GoogleAuthService.signIn], carrying the signed-in identity on
/// success. Never contains tokens: the ID token is exchanged with Firebase
/// inside the service and is never exposed to the UI layer.
class GoogleAuthResult {
  const GoogleAuthResult._(
    this.status, {
    this.email,
    this.displayName,
    this.photoUrl,
  });

  const GoogleAuthResult.success({
    required String email,
    String? displayName,
    String? photoUrl,
  }) : this._(
         GoogleAuthStatus.success,
         email: email,
         displayName: displayName,
         photoUrl: photoUrl,
       );

  const GoogleAuthResult.canceled() : this._(GoogleAuthStatus.canceled);

  const GoogleAuthResult.unavailable() : this._(GoogleAuthStatus.unavailable);

  const GoogleAuthResult.failed() : this._(GoogleAuthStatus.failed);

  final GoogleAuthStatus status;
  final String? email;
  final String? displayName;

  /// The account's Google profile photo (plain https URL), when the user
  /// has one. Never an ID token — photos are safe to display.
  final String? photoUrl;

  bool get isSuccess => status == GoogleAuthStatus.success;
}

/// Abstraction over Google Sign-In + the Firebase credential exchange.
///
/// Kept small and fakeable so [AuthProvider] and the UI can be tested without
/// the real plugin, Google credentials, or a configured Firebase project.
abstract class GoogleAuthService {
  /// Whether Google Sign-In can be attempted at all (Firebase configured and
  /// the platform supports the interactive flow). The UI hides the button when
  /// this is false.
  bool get isAvailable;

  /// Runs the interactive Google sign-in flow and, on success, signs the user
  /// into Firebase with the resulting credential. Never throws.
  Future<GoogleAuthResult> signIn();

  /// Signs the current Google account out so the next [signIn] shows the
  /// account chooser again (used on logout / account switching).
  Future<void> signOut();
}

/// Default no-op service used when no Google integration is wired in (older
/// tests, unsupported platforms). Reports itself unavailable so the Google
/// button stays hidden and [GoogleAuthService.signIn] is a safe no-op.
class UnavailableGoogleAuthService implements GoogleAuthService {
  const UnavailableGoogleAuthService();

  @override
  bool get isAvailable => false;

  @override
  Future<GoogleAuthResult> signIn() async =>
      const GoogleAuthResult.unavailable();

  @override
  Future<void> signOut() async {}
}

/// Real implementation backed by the `google_sign_in` plugin (v7 API) and the
/// existing [FirebaseAuthService] for the credential exchange.
///
/// [isAvailable] mirrors Firebase availability: on Android this is true once
/// `google-services.json` is present. Note that a *web* OAuth client must still
/// exist in the Firebase project for the interactive flow to succeed; if it is
/// missing the plugin raises a configuration error which we surface as
/// [GoogleAuthStatus.unavailable] (never as a fake success).
class FirebaseGoogleAuthService implements GoogleAuthService {
  FirebaseGoogleAuthService(this._firebase);

  final FirebaseAuthService _firebase;

  Future<void>? _initFuture;
  bool _initialized = false;

  /// Optional explicit web client ID. Usually left empty so the plugin reads
  /// the Gradle-generated `default_web_client_id` from google-services.json.
  /// Can be supplied at build time:
  ///   flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=xxxx.apps.googleusercontent.com
  static const String _serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  @override
  bool get isAvailable => _firebase.isAvailable;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initFuture ??= _doInit();
    await _initFuture;
  }

  Future<void> _doInit() async {
    await GoogleSignIn.instance.initialize(
      serverClientId: _serverClientId.isEmpty ? null : _serverClientId,
    );
    _initialized = true;
  }

  @override
  Future<GoogleAuthResult> signIn() async {
    if (!_firebase.isAvailable) return const GoogleAuthResult.unavailable();
    try {
      if (kDebugMode) {
        debugPrint('[GoogleSignIn] service: firebase available, ensuring init');
      }
      await _ensureInitialized();
      if (kDebugMode) {
        debugPrint(
          '[GoogleSignIn] service: initialized, supports: ${GoogleSignIn.instance.supportsAuthenticate()}',
        );
      }
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        return const GoogleAuthResult.unavailable();
      }
      final account = await GoogleSignIn.instance.authenticate();
      if (kDebugMode) {
        // No account identifiers (email/name/id) are logged — only the stage.
        debugPrint('[GoogleSignIn] service: authenticate returned an account');
      }
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        if (kDebugMode) {
          debugPrint('[GoogleSignIn] service: idToken is null/empty');
        }
        return const GoogleAuthResult.failed();
      }
      if (kDebugMode) {
        debugPrint('[GoogleSignIn] service: exchanging token with Firebase');
      }
      await _firebase.signInWithGoogle(idToken: idToken);
      if (kDebugMode) {
        debugPrint('[GoogleSignIn] service: Firebase signInWithGoogle ok');
      }
      return GoogleAuthResult.success(
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
      );
    } on GoogleSignInException catch (e) {
      if (kDebugMode) {
        debugPrint('[GoogleSignIn] service: GoogleSignInException ${e.code}');
      }
      switch (e.code) {
        case GoogleSignInExceptionCode.canceled:
        case GoogleSignInExceptionCode.interrupted:
          return const GoogleAuthResult.canceled();
        case GoogleSignInExceptionCode.clientConfigurationError:
        case GoogleSignInExceptionCode.providerConfigurationError:
        case GoogleSignInExceptionCode.uiUnavailable:
          return const GoogleAuthResult.unavailable();
        default:
          return const GoogleAuthResult.failed();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GoogleSignIn] service: unexpected catch: $e');
      }
      return const GoogleAuthResult.failed();
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _ensureInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Best-effort: logging out locally must still succeed without Google.
    }
  }
}
