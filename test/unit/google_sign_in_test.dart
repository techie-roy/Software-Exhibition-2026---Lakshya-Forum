import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_queue/providers/auth_provider.dart';
import 'package:agri_queue/services/firebase_auth_service.dart';
import 'package:agri_queue/services/google_auth_service.dart';
import 'package:agri_queue/services/local_storage_service.dart';
import 'package:agri_queue/services/mock_auth_service.dart';

/// Fake Google service so tests never touch the real plugin, Firebase, or any
/// Google credential. Mirrors the real contract: sign-in never throws and
/// reports its outcome via [GoogleAuthResult].
class FakeGoogleAuthService implements GoogleAuthService {
  FakeGoogleAuthService({
    this.isAvailable = true,
    this.result = const GoogleAuthResult.canceled(),
    this.throwOnSignIn,
  });

  @override
  bool isAvailable;

  GoogleAuthResult result;
  bool? throwOnSignIn;

  int signInCalls = 0;
  int signOutCalls = 0;

  @override
  Future<GoogleAuthResult> signIn() async {
    signInCalls++;
    if (throwOnSignIn == true) throw FirebaseNotConfiguredException();
    return result;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  AuthProvider newProvider(
    LocalStorageService storage,
    GoogleAuthService google,
  ) => AuthProvider(MockAuthService(), storage, googleAuthService: google);

  group('Google sign-in availability', () {
    test('button is gated on the injected service availability', () async {
      final available = newProvider(
        LocalStorageService(),
        FakeGoogleAuthService(isAvailable: true),
      );
      await available.ready;
      expect(available.googleSignInAvailable, isTrue);
      available.dispose();

      final unavailable = newProvider(
        LocalStorageService(),
        FakeGoogleAuthService(isAvailable: false),
      );
      await unavailable.ready;
      expect(unavailable.googleSignInAvailable, isFalse);
      unavailable.dispose();
    });

    test('defaults to unavailable when no service is injected', () async {
      final provider = AuthProvider(MockAuthService(), LocalStorageService());
      await provider.ready;
      expect(provider.googleSignInAvailable, isFalse);
      provider.dispose();
    });
  });

  group('Google sign-in success', () {
    test(
      'signs in, derives a neutral farmer and persists the session',
      () async {
        final storage = LocalStorageService();
        final google = FakeGoogleAuthService(
          result: const GoogleAuthResult.success(
            email: 'jane.doe@example.com',
            displayName: 'Jane Doe',
          ),
        );
        final provider = newProvider(storage, google);
        await provider.ready;

        final status = await provider.signInWithGoogle();

        expect(status, GoogleAuthStatus.success);
        expect(google.signInCalls, 1);
        expect(provider.currentFarmer, isNotNull);
        expect(provider.currentFarmer!.name, 'Jane Doe');
        expect(provider.isLoggedIn, isTrue);
        expect(await storage.isLoggedIn(), isTrue);
        provider.dispose();

        // Persisted identity survives a restart, exactly like other logins.
        final afterRestart = newProvider(storage, google);
        await afterRestart.ready;
        expect(afterRestart.currentFarmer!.name, 'Jane Doe');
        afterRestart.dispose();
      },
    );
  });

  group('Google sign-in cancellation and errors', () {
    test('cancellation leaves the user signed out with no error', () async {
      final provider = newProvider(
        LocalStorageService(),
        FakeGoogleAuthService(result: const GoogleAuthResult.canceled()),
      );
      await provider.ready;

      final status = await provider.signInWithGoogle();

      expect(status, GoogleAuthStatus.canceled);
      expect(provider.currentFarmer, isNull);
      expect(provider.isLoggedIn, isFalse);
      expect(provider.errorMessage, isNull);
      provider.dispose();
    });

    test('unavailable is reported distinctly and does not sign in', () async {
      final provider = newProvider(
        LocalStorageService(),
        FakeGoogleAuthService(result: const GoogleAuthResult.unavailable()),
      );
      await provider.ready;

      final status = await provider.signInWithGoogle();

      expect(status, GoogleAuthStatus.unavailable);
      expect(provider.currentFarmer, isNull);
      provider.dispose();
    });

    test('failure sets an error message and does not sign in', () async {
      final provider = newProvider(
        LocalStorageService(),
        FakeGoogleAuthService(result: const GoogleAuthResult.failed()),
      );
      await provider.ready;

      final status = await provider.signInWithGoogle();

      expect(status, GoogleAuthStatus.failed);
      expect(provider.currentFarmer, isNull);
      provider.dispose();
    });

    test('a thrown error is mapped and reported as failure', () async {
      final provider = newProvider(
        LocalStorageService(),
        FakeGoogleAuthService(throwOnSignIn: true),
      );
      await provider.ready;

      final status = await provider.signInWithGoogle();

      expect(status, GoogleAuthStatus.failed);
      expect(provider.errorMessage, isNotNull);
      expect(provider.currentFarmer, isNull);
      provider.dispose();
    });

    test(
      'loading state is always cleaned up on success/failure/cancel',
      () async {
        final storage = LocalStorageService();
        final cases = <GoogleAuthResult>[
          const GoogleAuthResult.success(email: 'a@b.com', displayName: 'A'),
          const GoogleAuthResult.failed(),
          const GoogleAuthResult.canceled(),
          const GoogleAuthResult.unavailable(),
        ];
        for (final r in cases) {
          final google = FakeGoogleAuthService(result: r);
          final provider = newProvider(storage, google);
          await provider.ready;
          expect(provider.isLoading, isFalse);
          final future = provider.signInWithGoogle();
          // During async work, loading should be true (microtask boundary)
          expect(provider.isLoading, isTrue);
          final status = await future;
          expect(status, r.status);
          expect(provider.isLoading, isFalse);
          provider.dispose();
        }
      },
    );

    test('loading state is cleaned up if service throws', () async {
      final provider = newProvider(
        LocalStorageService(),
        FakeGoogleAuthService(throwOnSignIn: true),
      );
      await provider.ready;
      final future = provider.signInWithGoogle();
      expect(provider.isLoading, isTrue);
      final status = await future;
      expect(status, GoogleAuthStatus.failed);
      expect(provider.isLoading, isFalse);
      provider.dispose();
    });
  });

  group('Google logout and account switching', () {
    test('logout signs out of Google and clears the session', () async {
      final storage = LocalStorageService();
      final google = FakeGoogleAuthService(
        result: const GoogleAuthResult.success(
          email: 'jane.doe@example.com',
          displayName: 'Jane Doe',
        ),
      );
      final provider = newProvider(storage, google);
      await provider.ready;
      await provider.signInWithGoogle();

      await provider.logout();

      expect(google.signOutCalls, 1);
      expect(provider.currentFarmer, isNull);
      expect(provider.isLoggedIn, isFalse);
      expect(await storage.isLoggedIn(), isFalse);
      provider.dispose();
    });

    test(
      'switching Google accounts does not leak the previous farmer',
      () async {
        final storage = LocalStorageService();
        final google = FakeGoogleAuthService(
          result: const GoogleAuthResult.success(
            email: 'first@example.com',
            displayName: 'First User',
          ),
        );
        final provider = newProvider(storage, google);
        await provider.ready;

        await provider.signInWithGoogle();
        final firstId = provider.currentFarmer!.id;
        expect(provider.currentFarmer!.name, 'First User');

        await provider.logout();

        google.result = const GoogleAuthResult.success(
          email: 'second@example.com',
          displayName: 'Second User',
        );
        await provider.signInWithGoogle();

        expect(provider.currentFarmer!.name, 'Second User');
        expect(provider.currentFarmer!.id, isNot(firstId));
        provider.dispose();
      },
    );
  });
}
