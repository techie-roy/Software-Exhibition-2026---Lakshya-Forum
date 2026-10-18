import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_queue/providers/auth_provider.dart';
import 'package:agri_queue/services/local_storage_service.dart';
import 'package:agri_queue/services/mock_auth_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  AuthProvider newProvider(LocalStorageService storage) =>
      AuthProvider(MockAuthService(), storage);

  group('Identity restoration', () {
    test('restores the exact farmer that logged in, not a default', () async {
      final storage = LocalStorageService();

      final first = newProvider(storage);
      await first.ready;
      expect(first.isLoggedIn, isFalse);

      final ok = await first.loginWithPassword('9812345678', '123456');
      expect(ok, isTrue);
      expect(first.currentFarmer!.name, 'Ramesh Patel');
      expect(first.currentFarmer!.id, 'FID-UP-91042');
      first.dispose();

      // Simulate a fresh app launch over the same persisted storage.
      final second = newProvider(storage);
      await second.ready;
      expect(second.currentFarmer, isNotNull);
      expect(second.currentFarmer!.name, 'Ramesh Patel');
      expect(second.currentFarmer!.id, 'FID-UP-91042');
      second.dispose();
    });

    test('restores a newly registered farmer after restart', () async {
      final storage = LocalStorageService();

      final first = newProvider(storage);
      await first.ready;
      final ok = await first.completeRegistration(
        name: 'Suresh Verma',
        phone: '9844001122',
        password: 'pass1234',
      );
      expect(ok, isTrue);
      expect(first.currentFarmer!.name, 'Suresh Verma');
      first.dispose();

      final second = newProvider(storage);
      await second.ready;
      expect(second.currentFarmer, isNotNull);
      expect(second.currentFarmer!.name, 'Suresh Verma');
      expect(second.currentFarmer!.mobile.contains('9844001122'), isTrue);
      second.dispose();
    });

    test('does not invent a farmer when no session was saved', () async {
      final storage = LocalStorageService();
      final provider = newProvider(storage);
      await provider.ready;
      expect(provider.isLoggedIn, isFalse);
      expect(provider.currentFarmer, isNull);
      provider.dispose();
    });
  });

  group('Account switching and logout', () {
    test('switching accounts does not leak the previous farmer', () async {
      final storage = LocalStorageService();
      final provider = newProvider(storage);
      await provider.ready;

      await provider.loginWithPassword('9876543210', '123456');
      expect(provider.currentFarmer!.name, 'Rajesh Kumar');

      await provider.logout();
      expect(provider.currentFarmer, isNull);

      await provider.loginWithPassword('9812345678', '123456');
      expect(provider.currentFarmer!.name, 'Ramesh Patel');
      expect(provider.displayFarmer.name, 'Ramesh Patel');
      provider.dispose();
    });

    test('logout clears identity and the persisted session', () async {
      final storage = LocalStorageService();
      final provider = newProvider(storage);
      await provider.ready;

      await provider.loginWithPassword('9876543210', '123456');
      await provider.logout();

      expect(provider.currentFarmer, isNull);
      expect(provider.isLoggedIn, isFalse);
      expect(await storage.isLoggedIn(), isFalse);
      expect(await storage.getSavedFarmerProfile(), isNull);
      provider.dispose();

      final afterRestart = newProvider(storage);
      await afterRestart.ready;
      expect(afterRestart.isLoggedIn, isFalse);
      expect(afterRestart.currentFarmer, isNull);
      afterRestart.dispose();
    });
  });

  group('Demo mode and secret hygiene', () {
    test('demo mode is on when Firebase is unavailable', () async {
      final provider = newProvider(LocalStorageService());
      await provider.ready;
      expect(provider.isFirebaseAvailable, isFalse);
      expect(provider.isDemoMode, isTrue);
      provider.dispose();
    });

    test('persisted session never contains passwords or OTPs', () async {
      final storage = LocalStorageService();
      final provider = newProvider(storage);
      await provider.ready;
      await provider.loginWithPassword('9876543210', '123456');

      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      expect(keys.any((k) => k.toLowerCase().contains('password')), isFalse);
      expect(keys.any((k) => k.toLowerCase().contains('otp')), isFalse);
      for (final key in keys) {
        final value = prefs.get(key);
        expect(
          '$value'.contains('123456'),
          isFalse,
          reason: 'value for "$key" must not persist the demo password/OTP',
        );
      }
      provider.dispose();
    });

    test('display falls back to the single canonical demo identity', () async {
      final provider = newProvider(LocalStorageService());
      await provider.ready;
      expect(provider.displayFarmer.name, MockAuthService.demoFarmer.name);
      expect(provider.currentFarmer, isNull);
      provider.dispose();
    });
  });
}
