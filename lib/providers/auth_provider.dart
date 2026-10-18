import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/farmer.dart';
import '../services/auth_error_mapper.dart';
import '../services/firebase_auth_service.dart';
import '../services/google_auth_service.dart';
import '../services/local_storage_service.dart';
import '../services/mock_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final MockAuthService _authService;
  final LocalStorageService _storageService;
  final FirebaseAuthService _firebase;
  final GoogleAuthService _googleAuth;

  Farmer? _currentFarmer;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<User?>? _firebaseSub;
  late final Future<void> _initFuture;

  // Real Firebase Phone Auth state for the in-flight OTP session.
  String? _verificationId;
  int? _resendToken;
  String? _verificationPhone;
  PhoneAuthCredential? _pendingPhoneCredential;

  AuthProvider(
    this._authService,
    this._storageService, {
    FirebaseAuthService? firebaseAuthService,
    GoogleAuthService? googleAuthService,
  }) : _firebase = firebaseAuthService ?? FirebaseAuthService(),
       _googleAuth = googleAuthService ?? const UnavailableGoogleAuthService() {
    _initFuture = _init();
    // React to Firebase session changes (persisted by the SDK itself).
    _firebaseSub = _firebase.authStateChanges().listen((user) {
      // Adopt a neutral display profile for an externally authenticated
      // account when no mock/demo farmer has been set. Never overrides an
      // explicit mock login or resurrects a signed-out farmer.
      if (user != null) {
        _currentFarmer ??= _farmerFromFirebase(user);
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _firebaseSub?.cancel();
    super.dispose();
  }

  /// Completes once the persisted session has been restored. Callers (and
  /// tests) can await this instead of guessing at internal timing.
  Future<void> get ready => _initFuture;

  Farmer? get currentFarmer => _currentFarmer;

  /// The identity to display. Prefers the farmer established at login,
  /// otherwise derives a neutral profile from the Firebase account, and only
  /// falls back to the shared demo farmer when nothing is authenticated.
  Farmer get displayFarmer {
    final current = _currentFarmer;
    if (current != null) return current;
    final user = _firebase.currentUser;
    if (user != null) return _farmerFromFirebase(user);
    return MockAuthService.demoFarmer;
  }

  /// Signed in via legacy mock profile OR via Firebase session.
  bool get isLoggedIn =>
      _currentFarmer != null || _firebase.currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// True when Firebase is not configured, i.e. there is no real online backend
  /// at all. NOTE: this is NOT the same as "simulated auth is in use" — the
  /// mobile-number + password and OTP paths always use MockAuthService even
  /// when Firebase is configured. The simulated-auth disclosure UI
  /// (DemoModeBanner) is therefore intentionally independent of this flag.
  bool get isDemoMode => !_firebase.isAvailable;

  // ---- Firebase passthrough (state source of truth when configured) ----
  bool get isFirebaseAvailable => _firebase.isAvailable;
  User? get firebaseUser => _firebase.currentUser;
  String? get firebaseEmail => _firebase.currentUser?.email;
  Stream<User?> authStateChanges() => _firebase.authStateChanges();

  /// Whether the Google Sign-In button should be offered. False on platforms
  /// without Firebase configuration and in tests that inject no Google service.
  bool get googleSignInAvailable => _googleAuth.isAvailable;

  /// True when OTP flows run **real Firebase Phone Authentication** (an SMS
  /// from Google). False only when Firebase itself is not configured — then
  /// the app is in the disclosed demo path: no SMS is sent and any 6-digit
  /// code is accepted (always labelled by DemoModeBanner). Provider-not-enabled
  /// console states surface as explicit errors through [sendOtp], never as a
  /// silent fallback to the demo path.
  bool get isPhoneAuthAvailable => _firebase.isAvailable;

  Future<void> _init() async {
    // 1. Restore persisted registered farmer accounts so mobile + password login
    //    works even after app process restart when logged out.
    try {
      final persistedFarmers = await _storageService
          .getPersistedRegisteredFarmers();
      final persistedVerifiers = await _storageService
          .getPersistedAuthVerifiers();
      if (persistedFarmers.isNotEmpty) {
        _authService.loadPersistedData(
          farmers: persistedFarmers,
          verifiers: persistedVerifiers,
        );
      }
    } catch (_) {}

    final loggedIn = await _storageService.isLoggedIn();
    if (!loggedIn) return;

    // Restore the exact farmer that was signed in, never a hardcoded default.
    _currentFarmer = await _storageService.getSavedFarmerProfile();
    _currentFarmer ??= _authService.getFarmer(
      await _storageService.getSavedFarmerPhone() ?? '',
    );
    _currentFarmer ??= _firebaseUserIfAny();
    notifyListeners();
  }

  Farmer? _firebaseUserIfAny() {
    final user = _firebase.currentUser;
    return user == null ? null : _farmerFromFirebase(user);
  }

  Farmer _farmerFromFirebase(User user) => Farmer.forExternalAccount(
    email: user.email ?? '',
    displayName: user.displayName,
    mobile: user.phoneNumber ?? '',
    photoUrl: user.photoURL,
  );

  /// Persists both the session flag and the full profile so restart restores
  /// the same identity. Only non-secret profile data is written.
  Future<void> _persistSession(Farmer farmer) async {
    await _storageService.setLoggedIn(
      true,
      phone: farmer.mobile,
      name: farmer.name,
    );
    await _storageService.saveFarmerProfile(farmer);
  }

  bool isMobileRegistered(String phone) {
    return _authService.isMobileRegistered(phone);
  }

  Future<bool> loginWithPassword(String phone, String password) async {
    if (_isLoading) return false;
    _setLoading(true);
    _clearError();

    // Fast mock delay for realistic feel
    await Future.delayed(const Duration(milliseconds: 300));

    final farmer = _authService.loginWithPassword(phone, password);
    if (farmer != null) {
      _currentFarmer = farmer;
      await _persistSession(farmer);
      if (_firebase.isAvailable &&
          farmer.email != null &&
          farmer.email!.isNotEmpty) {
        try {
          await _firebase.signInWithEmail(
            email: farmer.email!,
            password: password,
          );
        } catch (_) {
          // Best-effort: offline/local authentication succeeded.
        }
      }
      _setLoading(false);
      return true;
    } else {
      _errorMessage = 'Invalid mobile number or password';
      _setLoading(false);
      return false;
    }
  }

  /// Firebase email/password sign-in. Guards against repeated submissions
  /// via [_isLoading]. Never logs the password.
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (_isLoading) return false;
    _setLoading(true);
    _clearError();
    try {
      final cred = await _firebase.signInWithEmail(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user != null) {
        _currentFarmer = _farmerFromFirebase(user);
        await _persistSession(_currentFarmer!);
      } else {
        await _storageService.setLoggedIn(true, name: email.trim());
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = AuthErrorMapper.messageFor(e);
      _setLoading(false);
      return false;
    }
  }

  /// Google Sign-In via the injected [GoogleAuthService]. The service performs
  /// the Google flow and the Firebase credential exchange; on success the
  /// resulting identity is persisted like any other login. Returns the outcome
  /// so the UI can distinguish cancellation (silent) from a real failure.
  Future<GoogleAuthStatus> signInWithGoogle() async {
    if (_isLoading) return GoogleAuthStatus.failed;
    _setLoading(true);
    _clearError();
    try {
      if (kDebugMode) {
        debugPrint('[GoogleSignIn] provider: starting sign-in');
      }
      final result = await _googleAuth.signIn().timeout(
        const Duration(seconds: 60),
      );
      if (kDebugMode) {
        debugPrint(
          '[GoogleSignIn] provider: service returned ${result.status}',
        );
      }
      if (!result.isSuccess) {
        return result.status;
      }
      final farmer = Farmer.forExternalAccount(
        email: result.email ?? '',
        displayName: result.displayName,
        photoUrl: result.photoUrl,
      );
      _currentFarmer = farmer;
      await _persistSession(farmer);
      if (kDebugMode) {
        debugPrint('[GoogleSignIn] provider: session persisted, success');
      }
      return GoogleAuthStatus.success;
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('[GoogleSignIn] provider: timeout after 60s');
      }
      _errorMessage = 'Google sign-in timed out. Please try again.';
      return GoogleAuthStatus.failed;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GoogleSignIn] provider: unexpected error: $e');
      }
      _errorMessage = AuthErrorMapper.messageFor(e);
      return GoogleAuthStatus.failed;
    } finally {
      _setLoading(false);
      if (kDebugMode) {
        debugPrint('[GoogleSignIn] provider: loading cleared');
      }
    }
  }

  /// Firebase email/password registration. On success also creates the
  /// local mock farmer profile so slot booking / tokens / queue screens
  /// (which read [currentFarmer]) keep working unchanged.
  /// Returns false with [errorMessage] set for duplicate email etc.
  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    String? aadhaar,
    String? dob,
  }) async {
    if (_isLoading) return false;
    _setLoading(true);
    _clearError();
    _verificationPhone = phone;
    try {
      if (_firebase.isAvailable) {
        await _firebase.createUserWithEmail(email: email, password: password);
        // Persist the confirmed farmer name on the Firebase account (the real
        // configured backend) — best-effort: account creation already succeeded.
        try {
          await _firebase.updateCurrentUserProfile(displayName: name);
        } catch (_) {}
      }
      Farmer? farmer;
      try {
        farmer = _authService.registerFarmer(
          name: name,
          phone: phone,
          password: password,
          aadhaar: aadhaar,
          email: email,
        );
        final hash = _authService.getPasswordHash(phone);
        if (hash != null) {
          await _storageService.persistRegisteredFarmer(farmer, hash);
        }
      } catch (_) {
        // Mock profile is best-effort; Firebase account already exists.
      }
      _currentFarmer = farmer;
      if (farmer != null) {
        await _persistSession(farmer);
      } else {
        await _storageService.setLoggedIn(true, phone: phone, name: name);
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = AuthErrorMapper.messageFor(e);
      _setLoading(false);
      return false;
    }
  }

  /// Sends a Firebase password-reset email. Returns true on success,
  /// false with [errorMessage] set otherwise. Loading state is exposed
  /// via [isLoading] so the UI can disable the button.
  Future<bool> sendPasswordReset({required String email}) async {
    if (_isLoading) return false;
    _setLoading(true);
    _clearError();
    try {
      await _firebase.sendPasswordReset(email: email);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = AuthErrorMapper.messageFor(e);
      _setLoading(false);
      return false;
    }
  }

  /// Sends an OTP for a login ([forRegistration] false) or registration flow.
  ///
  /// * Firebase configured -> starts **real Firebase Phone Authentication**
  ///   (the SMS comes from Google). Returns false with [errorMessage] set
  ///   when the real attempt cannot start (Phone provider disabled in the
  ///   console, invalid number, SMS quota, missing SHA fingerprint) — it
  ///   never silently degrades to an accepted-anywhere fake code.
  /// * Firebase not configured -> the disclosed demo path: no SMS is sent
  ///   and any 6-digit code is accepted at [confirmOtp] (DemoModeBanner
  ///   states exactly that).
  Future<bool> sendOtp(String phone, {required bool forRegistration}) async {
    _clearError();
    if (!_firebase.isAvailable) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (kDebugMode) {
        debugPrint('[DEMO OTP] Firebase not configured; no SMS sent');
      }
      return true;
    }

    _setLoading(true);
    _verificationId = null;
    _pendingPhoneCredential = null;
    final resendForSamePhone =
        _verificationPhone != null && _verificationPhone == phone;
    _verificationPhone = phone;
    final completer = Completer<bool>();
    try {
      await _firebase.verifyPhoneNumber(
        phoneNumber: phone,
        forceResendingToken: resendForSamePhone ? _resendToken : null,
        onVerificationCompleted: (credential) {
          // Android verified the code for us (instant verification or SMS
          // auto-retrieval): keep it as the verified credential.
          if (kDebugMode) {
            debugPrint(
              '[PhoneAuth] onVerificationCompleted: ${credential.runtimeType}',
            );
          }
          _pendingPhoneCredential = credential;
          _setLoading(false);
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
        onVerificationFailed: (error) {
          if (kDebugMode) {
            debugPrint('[PhoneAuth] onVerificationFailed: ${error.code}');
          }
          _errorMessage = AuthErrorMapper.phoneAuthMessageFor(error);
          _setLoading(false);
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
        onCodeSent: (verificationId, resendToken) {
          if (kDebugMode) {
            debugPrint('[PhoneAuth] onCodeSent');
          }
          _verificationId = verificationId;
          _resendToken = resendToken;
          _setLoading(false);
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
        onCodeAutoRetrievalTimeout: (verificationId) {
          // Auto-retrieval gave up; keep the id so a typed code still works.
          _verificationId ??= verificationId;
          // Do not complete here: we either already completed on codeSent, or
          // we may still get onVerificationFailed/onVerificationCompleted.
        },
      );
      return await completer.future;
    } catch (e) {
      _errorMessage = AuthErrorMapper.phoneAuthMessageFor(e);
      _setLoading(false);
      if (!completer.isCompleted) {
        completer.complete(false);
      }
      return false;
    }
  }

  /// Verifies the OTP (typed code, or the Android auto-verified credential)
  /// and completes login or the registration verification step.
  ///
  /// Real Firebase path when configured; disclosed demo path otherwise with
  /// identical semantics to before (any 6-digit code, registered numbers).
  Future<bool> confirmOtp(
    String phone,
    String otp, {
    required bool forRegistration,
  }) async {
    if (_isLoading) return false;
    final sendFailure = _errorMessage;
    _setLoading(true);
    _clearError();

    // ---- Disclosed demo path (Firebase not configured) ----
    if (!_firebase.isAvailable) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (forRegistration) {
        // Any 6-digit code (no SMS provider exists in this build).
        if (otp.length == 6 && RegExp(r'^\d{6}$').hasMatch(otp)) {
          _setLoading(false);
          return true;
        }
      } else {
        final farmer = _authService.verifyOtp(phone, otp);
        if (farmer != null) {
          _currentFarmer = farmer;
          await _persistSession(farmer);
          _setLoading(false);
          return true;
        }
      }
      _errorMessage = 'Invalid OTP. Please try again.';
      _setLoading(false);
      return false;
    }

    // ---- Real Firebase Phone Auth path ----
    try {
      var credential = _pendingPhoneCredential;
      _pendingPhoneCredential = null;
      if (credential == null && _verificationId != null) {
        credential = FirebaseAuthService.phoneCredential(
          verificationId: _verificationId!,
          smsCode: otp,
        );
      }
      if (credential == null) {
        // No verification in flight: either it never started (sendOtp's
        // failure is reported verbatim) or it expired.
        _errorMessage =
            sendFailure ??
            'Your OTP session expired. Tap Resend to get a new code.';
        _setLoading(false);
        return false;
      }

      final user = await _signInOrLinkPhone(credential);
      if (user == null) {
        _errorMessage = 'Phone verification failed. Please try again.';
        _setLoading(false);
        return false;
      }

      if (!forRegistration) {
        // Login: restore the local profile for the verified number when one
        // exists, otherwise a neutral profile from the verified Firebase
        // account — never a seeded demo identity.
        final farmer =
            _authService.getFarmer(phone) ??
            Farmer.forExternalAccount(
              email: '',
              displayName: user.displayName,
              mobile: user.phoneNumber ?? FirebaseAuthService.toE164(phone),
              photoUrl: user.photoURL,
            );
        _currentFarmer = farmer;
        await _persistSession(farmer);
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = AuthErrorMapper.phoneAuthMessageFor(e);
      _setLoading(false);
      return false;
    }
  }

  /// Signs in with a verified phone credential, or links it to the current
  /// Google/email account so one farmer can hold both providers.
  ///
  /// Conflict rules — no duplicate accounts, no silent data loss:
  /// * no signed-in session -> plain phone sign-in (the phone account is
  ///   created or reused, never duplicated);
  /// * this phone is already linked to the current account -> keep the
  ///   session as-is;
  /// * the phone belongs to a *different* Firebase account -> sign into that
  ///   account instead of minting a second one; the local profile keyed by
  ///   that number stays authoritative for the app, so neither identity is
  ///   overwritten behind the user's back.
  Future<User?> _signInOrLinkPhone(PhoneAuthCredential credential) async {
    final current = _firebase.currentUser;
    if (current == null) {
      final cred = await _firebase.signInWithPhoneCredential(credential);
      return cred.user;
    }
    try {
      final linked = await _firebase.linkPhoneCredential(credential);
      return linked.user ?? current;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked') {
        return current;
      }
      if (e.code == 'credential-already-in-use' ||
          e.code == 'phone-number-already-in-use') {
        final cred = await _firebase.signInWithPhoneCredential(credential);
        return cred.user;
      }
      rethrow;
    }
  }

  /// Completes the registration after OTP verification by creating the account.
  Future<bool> completeRegistration({
    required String name,
    required String phone,
    required String password,
    String? aadhaar,
    String? dob,
    String? email,
  }) async {
    if (_isLoading) return false;
    _setLoading(true);
    _clearError();

    await Future.delayed(const Duration(milliseconds: 300));

    // Data-loss backstop: never overwrite the local profile of an already
    // registered number, unless it is the number from this active registration session.
    if (_authService.isMobileRegistered(phone) && phone != _verificationPhone) {
      _errorMessage =
          'This mobile number is already registered. Please log in instead.';
      _setLoading(false);
      return false;
    }

    try {
      final farmer = _authService.registerFarmer(
        name: name,
        phone: phone,
        password: password,
        aadhaar: aadhaar,
        email: email,
      );
      final hash = _authService.getPasswordHash(phone);
      if (hash != null) {
        await _storageService.persistRegisteredFarmer(farmer, hash);
      }
      // Persist the confirmed name on the Firebase account (phone user just
      // verified, or an email account was created) — real-backend minimum.
      if (_firebase.isAvailable && _firebase.currentUser != null) {
        try {
          await _firebase.updateCurrentUserProfile(displayName: name);
        } catch (_) {
          // Best-effort: local registration already succeeded.
        }
      }
      _currentFarmer = farmer;
      await _persistSession(farmer);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Unable to complete registration. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> registerAndLogin({
    required String name,
    required String phone,
    required String password,
    String? aadhaar,
  }) async {
    if (_isLoading) return false;
    _setLoading(true);
    _clearError();

    await Future.delayed(const Duration(milliseconds: 300));

    if (_authService.isMobileRegistered(phone)) {
      _errorMessage =
          'This mobile number is already registered. Please log in instead.';
      _setLoading(false);
      return false;
    }

    try {
      final farmer = _authService.registerFarmer(
        name: name,
        phone: phone,
        password: password,
        aadhaar: aadhaar,
      );
      final hash = _authService.getPasswordHash(phone);
      if (hash != null) {
        await _storageService.persistRegisteredFarmer(farmer, hash);
      }
      _currentFarmer = farmer;
      await _persistSession(farmer);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Unable to complete registration. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _currentFarmer = null;
    // Drop any in-flight OTP session so a later login can't reuse a stale
    // verification id from the previous account.
    _verificationId = null;
    _resendToken = null;
    _verificationPhone = null;
    _pendingPhoneCredential = null;
    // Sign out of Google so the next sign-in shows the account chooser
    // (enables switching accounts) instead of silently reusing the last one.
    try {
      await _googleAuth.signOut();
    } catch (_) {
      // Best-effort: local logout must still succeed offline.
    }
    // Sign out of Firebase first so the persisted session is revoked.
    try {
      await _firebase.signOut();
    } catch (_) {
      // Best-effort: local logout must still succeed offline.
    }
    await _storageService.clearAuth();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
