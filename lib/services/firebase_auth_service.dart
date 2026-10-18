import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around [FirebaseAuth] so the app keeps working when
/// Firebase is not configured (e.g. missing google-services.json).
///
/// When [isAvailable] is false every method throws [FirebaseNotConfiguredException]
/// instead of touching the Firebase SDK. The UI maps that to a friendly
/// message telling the user/developer to finish Firebase Console setup.
/// No passwords or tokens are ever logged here.
class FirebaseAuthService {
  final FirebaseAuth? _auth;

  // ignore: prefer_initializing_formals, field is private with public label
  const FirebaseAuthService({FirebaseAuth? auth}) : _auth = auth;

  /// True only when Firebase was initialised successfully and [_auth] exists.
  bool get isAvailable => _auth != null;

  User? get currentUser => _auth?.currentUser;

  /// Server-stored profile photo on the Firebase account, if any.
  String? get currentUserPhotoUrl => _auth?.currentUser?.photoURL;

  /// Server-verified phone number on the Firebase account, if any.
  String? get currentUserPhone => _auth?.currentUser?.phoneNumber;

  /// Firebase Auth state changes. Firebase persists the session itself
  /// (ID token refresh handled by the SDK). Emits null when signed out.
  /// Falls back to a single-null stream when Firebase is unavailable so
  /// callers can always listen safely.
  Stream<User?> authStateChanges() {
    final auth = _auth;
    if (auth == null) return Stream<User?>.value(null);
    return auth.authStateChanges();
  }

  Future<UserCredential> createUserWithEmail({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) throw FirebaseNotConfiguredException();
    return auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) throw FirebaseNotConfiguredException();
    return auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Exchanges a Google ID token for a Firebase Auth session. The ID token is
  /// not logged or persisted. Throws [FirebaseNotConfiguredException] when
  /// Firebase is unavailable.
  Future<UserCredential> signInWithGoogle({required String idToken}) async {
    final auth = _auth;
    if (auth == null) throw FirebaseNotConfiguredException();
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return auth.signInWithCredential(credential);
  }

  Future<void> sendPasswordReset({required String email}) async {
    final auth = _auth;
    if (auth == null) throw FirebaseNotConfiguredException();
    await auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Formats Indian mobile input (bare `9876543210`, `91...`, `+91 ...`) to
  /// the E.164 form Firebase Phone Authentication requires.
  static String toE164(String phone) {
    final trimmed = phone.trim();
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) return '+91$digits';
    if (digits.length == 12 && digits.startsWith('91')) return '+$digits';
    if (trimmed.startsWith('+')) return trimmed;
    return digits.isEmpty ? trimmed : '+$digits';
  }

  /// Starts **real** Firebase Phone Authentication (an SMS OTP) for
  /// [phoneNumber]. Results arrive via the callbacks:
  ///
  /// * [onVerificationCompleted] — Android auto-verified credential (instant
  ///   verification / SMS auto-retrieval). The caller should treat it as the
  ///   verified credential instead of asking for a typed code.
  /// * [onCodeSent] — the user must now type the SMS code.
  /// * [onVerificationFailed] — configuration/quota/validation errors; never
  ///   logs credentials or the code.
  /// * [onCodeAutoRetrievalTimeout] — SMS auto-retrieval gave up; the code
  ///   must be typed manually (the id from [onCodeSent] still applies).
  ///
  /// Throws [FirebaseNotConfiguredException] when Firebase is unavailable.
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(PhoneAuthCredential credential)
    onVerificationCompleted,
    required void Function(FirebaseAuthException error) onVerificationFailed,
    void Function(String verificationId)? onCodeAutoRetrievalTimeout,
    int? forceResendingToken,
  }) async {
    final auth = _auth;
    if (auth == null) throw FirebaseNotConfiguredException();
    await auth.verifyPhoneNumber(
      phoneNumber: toE164(phoneNumber),
      forceResendingToken: forceResendingToken,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: (verificationId) =>
          onCodeAutoRetrievalTimeout?.call(verificationId),
      timeout: const Duration(seconds: 60),
    );
  }

  /// Builds the credential for a typed SMS code. Pure client-side value.
  static PhoneAuthCredential phoneCredential({
    required String verificationId,
    required String smsCode,
  }) {
    return PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }

  /// Signs in with an already-verified phone credential.
  Future<UserCredential> signInWithPhoneCredential(
    PhoneAuthCredential credential,
  ) async {
    final auth = _auth;
    if (auth == null) throw FirebaseNotConfiguredException();
    return auth.signInWithCredential(credential);
  }

  /// Links a verified phone credential to the *current* Firebase account so
  /// Google + phone live on one account instead of two. Throws the raw
  /// [FirebaseAuthException] (e.g. `credential-already-in-use`,
  /// `provider-already-linked`) for the caller to resolve.
  Future<UserCredential> linkPhoneCredential(
    PhoneAuthCredential credential,
  ) async {
    final user = _auth?.currentUser;
    if (user == null) {
      throw FirebaseNotConfiguredException(
        'No signed-in account is available to link the phone number to.',
      );
    }
    return user.linkWithCredential(credential);
  }

  /// Persists minimum profile data (confirmed display name and/or photo)
  /// **on the Firebase account** — the real configured backend — so it
  /// survives device changes. No secrets are stored here.
  Future<void> updateCurrentUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final user = _auth?.currentUser;
    if (user == null) {
      throw FirebaseNotConfiguredException(
        'No signed-in account to update the profile on.',
      );
    }
    if (displayName != null && displayName.trim().isNotEmpty) {
      await user.updateDisplayName(displayName.trim());
    }
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }
  }

  Future<void> signOut() async {
    final auth = _auth;
    if (auth == null) return;
    await auth.signOut();
  }
}

/// Thrown when Firebase-dependent auth is requested but Firebase was not
/// initialised (missing configuration files / console setup).
class FirebaseNotConfiguredException implements Exception {
  final String message;
  FirebaseNotConfiguredException([
    this.message =
        'Firebase is not configured. Finish Firebase Console setup first.',
  ]);

  @override
  String toString() => 'FirebaseNotConfiguredException: $message';
}
