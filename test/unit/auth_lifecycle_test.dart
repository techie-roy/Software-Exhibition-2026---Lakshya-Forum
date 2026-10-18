import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_queue/providers/auth_provider.dart';
import 'package:agri_queue/services/local_storage_service.dart';
import 'package:agri_queue/services/mock_auth_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Full Farmer Registration -> Logout -> Password Login Lifecycle', () {
    test('Farmer registers, logs out, logs back in with exact password, and rejects wrong password', () async {
      final storage = LocalStorageService();
      final mockAuth = MockAuthService();

      final provider1 = AuthProvider(mockAuth, storage);
      await provider1.ready;

      // 1. Register with verified mobile and password
      const testPhone = '9844112233';
      const testPass = 'FarmerSecurePass123';
      const testName = 'Devendra Sharma';

      final registered = await provider1.completeRegistration(
        name: testName,
        phone: testPhone,
        password: testPass,
        aadhaar: '248937581944',
        dob: '12/04/1985',
      );
      expect(registered, isTrue);
      expect(provider1.isLoggedIn, isTrue);
      expect(provider1.currentFarmer!.name, equals(testName));
      expect(provider1.currentFarmer!.mobile, contains(testPhone));

      // 2. Log out
      await provider1.logout();
      expect(provider1.isLoggedIn, isFalse);
      expect(provider1.currentFarmer, isNull);
      provider1.dispose();

      // 3. Attempt login with WRONG password -> MUST FAIL
      final provider2 = AuthProvider(mockAuth, storage);
      await provider2.ready;
      final wrongLogin = await provider2.loginWithPassword(
        testPhone,
        'WrongPassword999',
      );
      expect(wrongLogin, isFalse);
      expect(provider2.isLoggedIn, isFalse);
      expect(
        provider2.errorMessage,
        equals('Invalid mobile number or password'),
      );

      // 4. Attempt login with correct password -> MUST SUCCEED
      final correctLogin = await provider2.loginWithPassword(
        testPhone,
        testPass,
      );
      expect(correctLogin, isTrue);
      expect(provider2.isLoggedIn, isTrue);
      expect(provider2.currentFarmer!.name, equals(testName));
      expect(provider2.currentFarmer!.mobile, contains(testPhone));

      // 5. Log out again
      await provider2.logout();
      expect(provider2.isLoggedIn, isFalse);
      provider2.dispose();

      // 6. Simulate cold-start process restart: new instance of MockAuthService over persisted storage
      final freshMockAuth = MockAuthService();
      final provider3 = AuthProvider(freshMockAuth, storage);
      await provider3.ready;

      // Unauthenticated state after restart because user logged out
      expect(provider3.isLoggedIn, isFalse);

      // Wrong password after restart -> MUST STILL FAIL
      final wrongLoginAfterRestart = await provider3.loginWithPassword(
        testPhone,
        'StillWrongPass',
      );
      expect(wrongLoginAfterRestart, isFalse);
      expect(provider3.isLoggedIn, isFalse);

      // Correct password after restart -> MUST SUCCEED
      final correctLoginAfterRestart = await provider3.loginWithPassword(
        testPhone,
        testPass,
      );
      expect(correctLoginAfterRestart, isTrue);
      expect(provider3.isLoggedIn, isTrue);
      expect(provider3.currentFarmer!.name, equals(testName));
      expect(provider3.currentFarmer!.mobile, contains(testPhone));

      provider3.dispose();
    });

    test('Pre-seeded demo farmer rejects wrong password and accepts exact password', () async {
      final storage = LocalStorageService();
      final mockAuth = MockAuthService();
      final provider = AuthProvider(mockAuth, storage);
      await provider.ready;

      // Wrong password for 9876543210
      final wrong = await provider.loginWithPassword('9876543210', 'wrong');
      expect(wrong, isFalse);
      expect(
        provider.errorMessage,
        equals('Invalid mobile number or password'),
      );

      // Correct password for 9876543210
      final correct = await provider.loginWithPassword('9876543210', '123456');
      expect(correct, isTrue);
      expect(provider.currentFarmer!.name, equals('Rajesh Kumar'));

      provider.dispose();
    });
  });
}
