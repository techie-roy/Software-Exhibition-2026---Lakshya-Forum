import 'package:agri_queue/models/farmer.dart';
import 'package:agri_queue/providers/auth_provider.dart';
import 'package:agri_queue/services/local_storage_service.dart';
import 'package:agri_queue/services/mock_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<AuthProvider> buildProvider() async {
    final provider = AuthProvider(MockAuthService(), LocalStorageService());
    await provider.ready;
    return provider;
  }

  group('unified OTP flow (demo path — Firebase unavailable in tests)', () {
    test('reports OTP verification as unavailable without Firebase', () async {
      final provider = await buildProvider();
      expect(provider.isPhoneAuthAvailable, isFalse);
    });

    test('sendOtp never claims an SMS was sent', () async {
      final provider = await buildProvider();
      // The demo path resolves true so the UI can proceed, but it sends
      // nothing (no SMS provider exists without Firebase).
      expect(
        await provider.sendOtp('9876543210', forRegistration: false),
        isTrue,
      );
    });

    test('registration confirmOtp accepts only 6-digit codes', () async {
      final provider = await buildProvider();

      expect(
        await provider.confirmOtp('9844001122', '12345', forRegistration: true),
        isFalse,
      );
      expect(provider.errorMessage, isNotNull);

      expect(
        await provider.confirmOtp(
          '9844001122',
          '123456',
          forRegistration: true,
        ),
        isTrue,
      );
    });

    test('login confirmOtp signs in a registered number', () async {
      final provider = await buildProvider();

      final ok = await provider.confirmOtp(
        '9876543210',
        '654321',
        forRegistration: false,
      );

      expect(ok, isTrue);
      expect(provider.currentFarmer, isNotNull);
      expect(provider.currentFarmer!.mobile, contains('9876543210'));
    });

    test('login confirmOtp rejects an unregistered number', () async {
      final provider = await buildProvider();

      final ok = await provider.confirmOtp(
        '9111111111',
        '123456',
        forRegistration: false,
      );

      expect(ok, isFalse);
      expect(provider.errorMessage, isNotNull);
    });
  });

  group('duplicate registration guard (no silent profile overwrite)', () {
    test('completeRegistration refuses an already registered number', () async {
      final provider = await buildProvider();
      final before = MockAuthService().getFarmer('9876543210');

      final ok = await provider.completeRegistration(
        name: 'Imposter Name',
        phone: '9876543210',
        password: 'newpass',
      );

      expect(ok, isFalse);
      expect(provider.errorMessage, contains('already registered'));
      // The existing profile for that number is untouched.
      final after = MockAuthService().getFarmer('9876543210');
      expect(after!.name, before!.name);
      expect(after.id, before.id);
    });

    test('registerAndLogin refuses an already registered number', () async {
      final provider = await buildProvider();

      final ok = await provider.registerAndLogin(
        name: 'Imposter Name',
        phone: '9876543210',
        password: 'newpass',
      );

      expect(ok, isFalse);
      expect(provider.errorMessage, contains('already registered'));
    });

    test('completeRegistration still succeeds for a new number', () async {
      final provider = await buildProvider();

      final ok = await provider.completeRegistration(
        name: 'New Farmer',
        phone: '9844001122',
        password: 'pass1234',
      );

      expect(ok, isTrue);
      expect(provider.currentFarmer!.name, 'New Farmer');
      expect(provider.currentFarmer!.mobile, contains('9844001122'));
    });
  });

  group('external account profile with phone + Google photo', () {
    test('forExternalAccount keeps the verified number and photo URL', () {
      final farmer = Farmer.forExternalAccount(
        email: '',
        displayName: 'Abhilasha Singh',
        mobile: '+919876543210',
        photoUrl: 'https://example.com/photo.jpg',
      );

      expect(farmer.mobile, '+919876543210');
      expect(farmer.photoUrl, 'https://example.com/photo.jpg');
      expect(farmer.name, 'Abhilasha Singh');
    });

    test('phone-only accounts do not collide on one id', () {
      final a = Farmer.forExternalAccount(email: '', mobile: '+919876543210');
      final b = Farmer.forExternalAccount(email: '', mobile: '+919812345678');

      expect(a.id, isNot(b.id));
    });

    test('JSON round-trip preserves photoUrl and tolerates its absence', () {
      final withPhoto = Farmer.forExternalAccount(
        email: 'a@b.com',
        photoUrl: 'https://example.com/p.jpg',
      );
      final restored = Farmer.fromJson(withPhoto.toJson());
      expect(restored.photoUrl, 'https://example.com/p.jpg');

      // Older persisted profiles (no photoUrl key) still load.
      final legacy = Farmer.fromJson(withPhoto.toJson()..remove('photoUrl'));
      expect(legacy.photoUrl, isNull);
    });
  });
}
