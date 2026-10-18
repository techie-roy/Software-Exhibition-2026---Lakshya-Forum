import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_queue/providers/auth_provider.dart';
import 'package:agri_queue/services/local_storage_service.dart';
import 'package:agri_queue/services/mock_auth_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Registration with email and phone completes without duplicate-number error', () async {
    final storage = LocalStorageService();
    final mockAuth = MockAuthService();
    final provider = AuthProvider(mockAuth, storage);
    await provider.ready;

    const phone = '9877112233';
    const email = 'farmer.test@example.com';
    const password = 'FarmerPass123';
    const name = 'Kailash Chander';

    // Step 1: registerWithEmail initiates the registration
    final initOk = await provider.registerWithEmail(
      email: email,
      password: password,
      name: name,
      phone: phone,
      aadhaar: '248937581944',
      dob: '01/01/1980',
    );
    expect(initOk, isTrue);

    // Step 2: completeRegistration should NOT fail with "already registered"
    final completeOk = await provider.completeRegistration(
      name: name,
      phone: phone,
      password: password,
      aadhaar: '248937581944',
      dob: '01/01/1980',
      email: email,
    );

    expect(completeOk, isTrue);
    expect(provider.currentFarmer, isNotNull);
    expect(provider.currentFarmer!.name, equals(name));
    expect(provider.currentFarmer!.email, equals(email));

    // Step 3: Log out and log back in with mobile + password
    await provider.logout();
    expect(provider.isLoggedIn, isFalse);

    final wrongLogin = await provider.loginWithPassword(phone, 'wrongpass');
    expect(wrongLogin, isFalse);

    final correctLogin = await provider.loginWithPassword(phone, password);
    expect(correctLogin, isTrue);
    expect(provider.currentFarmer!.name, equals(name));

    provider.dispose();
  });
}
