import 'package:flutter_test/flutter_test.dart';
import 'package:agri_queue/models/farmer.dart';
import 'package:agri_queue/services/mock_auth_service.dart';

void main() {
  late MockAuthService authService;

  setUp(() {
    authService = MockAuthService();
  });

  group('Demo authentication semantics (labelled, not real)', () {
    test('exposes a single canonical demo farmer', () {
      expect(MockAuthService.demoFarmer.name, 'Rajesh Kumar');
      expect(MockAuthService.demoFarmer.id, 'FID-UP-78219');
      expect(MockAuthService.demoFarmer.mobile, '+91 9876543210');
      expect(MockAuthService.demoOtp, '123456');
    });

    test('accepts any 6-digit OTP for a registered number', () {
      expect(authService.verifyOtp('9876543210', '000000'), isNotNull);
      expect(authService.verifyOtp('9876543210', '654321'), isNotNull);
    });

    test('rejects a non-6-digit OTP', () {
      expect(authService.verifyOtp('9876543210', '12'), isNull);
      expect(authService.verifyOtp('9876543210', 'abcdef'), isNull);
      expect(authService.verifyOtp('9876543210', ''), isNull);
    });

    test('rejects an empty password', () {
      expect(authService.loginWithPassword('9876543210', ''), isNull);
    });

    test(
      'authenticates with the registered password and rejects wrong password',
      () {
        expect(
          authService.loginWithPassword('9876543210', '123456'),
          isNotNull,
        );
        expect(
          authService.loginWithPassword('9876543210', 'wrongpassword'),
          isNull,
        );
      },
    );
  });

  group('Farmer.forExternalAccount', () {
    test('derives a neutral, non-impersonating profile from an email', () {
      final farmer = Farmer.forExternalAccount(email: 'john.doe@example.com');

      expect(farmer.name, 'John Doe');
      expect(farmer.avatarInitials, 'JD');
      expect(farmer.mobile, isEmpty);
      expect(farmer.mandiName, isEmpty);
      expect(farmer.landSizeAcres, 0);
      expect(farmer.id.startsWith('FID-EXT-'), isTrue);
    });

    test('prefers a display name when provided', () {
      final farmer = Farmer.forExternalAccount(
        email: 'x@example.com',
        displayName: 'Asha Devi',
      );
      expect(farmer.name, 'Asha Devi');
      expect(farmer.avatarInitials, 'AD');
    });

    test('is stable for the same account across calls', () {
      final a = Farmer.forExternalAccount(email: 'same@example.com');
      final b = Farmer.forExternalAccount(email: 'same@example.com');
      expect(a.id, b.id);
    });
  });

  group('Farmer.fromJson defaults are neutral', () {
    test('missing fields do not default to a seeded farmer', () {
      final farmer = Farmer.fromJson(const {});
      expect(farmer.name, isEmpty);
      expect(farmer.id, isEmpty);
      expect(farmer.mobile, isEmpty);
      expect(farmer.avatarInitials, 'F');
    });
  });
}
