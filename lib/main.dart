import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';
import 'services/firebase_auth_service.dart';
import 'services/google_auth_service.dart';
import 'services/local_storage_service.dart';
import 'services/mock_auth_service.dart';
import 'services/mock_data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set status bar styling for clean farmer UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Firebase initialization. On Android this reads google-services.json
  // (processed by the com.google.gms.google-services Gradle plugin).
  // No firebase_options.dart is present, so FlutterFire CLI configuration
  // has NOT been applied — Android works without it; other platforms need it.
  // If init fails, the app still starts, but release builds show a loud
  // FirebaseConfigWarning banner and never silently pretend mock auth is
  // the real backend.
  FirebaseAuthService firebaseAuthService = FirebaseAuthService();
  try {
    await Firebase.initializeApp();
    firebaseAuthService = FirebaseAuthService(auth: FirebaseAuth.instance);
    if (kDebugMode) {
      debugPrint('[Firebase] Initialized successfully.');
    }
  } catch (e) {
    // Missing configuration is expected before Firebase Console setup.
    // Do not log secrets here; only the fact that we fell back.
    if (kDebugMode) {
      debugPrint('[Firebase] Not configured, running in mock auth mode: $e');
    }
  }

  final localStorageService = LocalStorageService();
  final mockAuthService = MockAuthService();
  final mockDataService = MockDataService();
  // Google Sign-In is available only when Firebase initialised above; otherwise
  // the service reports itself unavailable and the UI hides the button.
  final googleAuthService = FirebaseGoogleAuthService(firebaseAuthService);

  // Startup routing facts (read once before runApp so the first frame is
  // already on the right screen): language selection only on first launch,
  // resume the session when a logged-in flag was persisted.
  var savedLanguageExists = false;
  var sessionWasLoggedIn = false;
  try {
    savedLanguageExists = await localStorageService.getSavedLanguage() != null;
    sessionWasLoggedIn = await localStorageService.isLoggedIn();
  } catch (_) {
    // Storage unavailable: fall back to first-launch behaviour.
  }

  runApp(
    AgriQueueApp(
      localStorageService: localStorageService,
      mockAuthService: mockAuthService,
      mockDataService: mockDataService,
      firebaseAuthService: firebaseAuthService,
      googleAuthService: googleAuthService,
      savedLanguageExists: savedLanguageExists,
      sessionWasLoggedIn: sessionWasLoggedIn,
    ),
  );
}
