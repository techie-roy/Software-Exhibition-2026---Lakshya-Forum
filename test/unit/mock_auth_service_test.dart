import 'package:flutter_test/flutter_test.dart';
import 'package:agri_queue/services/mock_auth_service.dart';

void main() {
  group('MockAuthService Tests', () {
    late MockAuthService authService;

    setUp(() {
      authService = MockAuthService();
    });

    test('Identifies registered farmer Rajesh Kumar (+91 9876543210)', () {
      expect(authService.isMobileRegistered('9876543210'), isTrue);
      expect(authService.isMobileRegistered('+91 9876543210'), isTrue);
      expect(authService.isMobileRegistered('98765-43210'), isTrue);

      final farmer = authService.getFarmer('9876543210');
      expect(farmer, isNotNull);
      expect(farmer!.name, equals('Rajesh Kumar'));
      expect(farmer.mandiName, equals('Lucknow Central Mandi'));
    });

    test('Identifies unregistered mobile number', () {
      expect(authService.isMobileRegistered('9111111111'), isFalse);
      expect(authService.getFarmer('9111111111'), isNull);
    });

    test('Authenticates registered user with password', () {
      final farmer = authService.loginWithPassword('9876543210', '123456');
      expect(farmer, isNotNull);
      expect(farmer!.name, 'Rajesh Kumar');
    });

    test('Verifies OTP for registered user', () {
      final farmer = authService.verifyOtp('9876543210', '123456');
      expect(farmer, isNotNull);
      expect(farmer!.name, 'Rajesh Kumar');
    });

    test('Registers new farmer and adds to mock database', () {
      final newFarmer = authService.registerFarmer(
        name: 'Suresh Verma',
        phone: '9844001122',
        password: 'password123',
      );

      expect(newFarmer.name, equals('Suresh Verma'));
      expect(authService.isMobileRegistered('9844001122'), isTrue);

      final loggedIn = authService.loginWithPassword(
        '9844001122',
        'password123',
      );
      expect(loggedIn, isNotNull);
      expect(loggedIn!.name, equals('Suresh Verma'));
    });
  });
}
