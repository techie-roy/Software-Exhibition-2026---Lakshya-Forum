import '../models/farmer.dart';
import '../utils/validators.dart';

class MockAuthService {
  // Mock registered database
  final Map<String, Farmer> _registeredFarmers = {
    '9876543210': const Farmer(
      id: 'FID-UP-78219',
      name: 'Rajesh Kumar',
      mobile: '+91 9876543210',
      mandiId: 'MND-LKO-01',
      mandiName: 'Lucknow Central Mandi',
      mandiAddress: 'Transport Nagar, Lucknow, UP',
      landSizeAcres: 6.5,
      village: 'Malihabad',
      district: 'Lucknow',
      state: 'Uttar Pradesh',
      kisanCreditCard: 'KCC-8821-4412-9901',
      aadhaarMasked: 'XXXX-XXXX-4819',
      bankAccountMasked: 'SBI ••••••••3912',
      bankName: 'State Bank of India',
      avatarInitials: 'RK',
    ),
    '9812345678': const Farmer(
      id: 'FID-UP-91042',
      name: 'Ramesh Patel',
      mobile: '+91 9812345678',
      mandiId: 'MND-LKO-01',
      mandiName: 'Lucknow Central Mandi',
      mandiAddress: 'Transport Nagar, Lucknow, UP',
      landSizeAcres: 4.2,
      village: 'Bakshi Ka Talab',
      district: 'Lucknow',
      state: 'Uttar Pradesh',
      kisanCreditCard: 'KCC-1122-3344-5566',
      aadhaarMasked: 'XXXX-XXXX-7721',
      bankAccountMasked: 'PNB ••••••••8819',
      bankName: 'Punjab National Bank',
      avatarInitials: 'RP',
    ),
  };

  // Mock passwords for phone numbers
  final Map<String, String> _passwords = {
    '9876543210': '123456',
    '9812345678': '123456',
  };

  bool isMobileRegistered(String phone) {
    final cleanPhone = Validators.sanitizeMobile(phone);
    return _registeredFarmers.containsKey(cleanPhone);
  }

  Farmer? getFarmer(String phone) {
    final cleanPhone = Validators.sanitizeMobile(phone);
    return _registeredFarmers[cleanPhone];
  }

  Farmer? loginWithPassword(String phone, String password) {
    final cleanPhone = Validators.sanitizeMobile(phone);
    if (!_registeredFarmers.containsKey(cleanPhone)) {
      return null;
    }
    final expectedPassword = _passwords[cleanPhone] ?? '123456';
    if (password == expectedPassword || password.isNotEmpty) {
      return _registeredFarmers[cleanPhone];
    }
    return null;
  }

  Farmer registerFarmer({
    required String name,
    required String phone,
    required String password,
    String? aadhaar,
  }) {
    final cleanPhone = Validators.sanitizeMobile(phone);
    final initials = name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
    
    String maskedAadhaar = 'XXXX-XXXX-9988';
    if (aadhaar != null && aadhaar.trim().isNotEmpty) {
      final cleanAadhaar = aadhaar.replaceAll(RegExp(r'\D'), '');
      if (cleanAadhaar.length >= 4) {
        maskedAadhaar = 'XXXX-XXXX-${cleanAadhaar.substring(cleanAadhaar.length - 4)}';
      }
    }

    final newFarmer = Farmer(
      id: 'FID-UP-${(10000 + _registeredFarmers.length * 7).toString()}',
      name: name.trim(),
      mobile: '+91 $cleanPhone',
      mandiId: 'MND-LKO-01',
      mandiName: 'Lucknow Central Mandi',
      mandiAddress: 'Transport Nagar, Lucknow, UP',
      landSizeAcres: 5.0,
      village: 'Kisan Nagar',
      district: 'Lucknow',
      state: 'Uttar Pradesh',
      kisanCreditCard: 'KCC-5544-3322-1100',
      aadhaarMasked: maskedAadhaar,
      bankAccountMasked: 'Bank ••••••••4422',
      bankName: 'Canara Bank',
      avatarInitials: initials.isNotEmpty ? initials : 'F',
    );

    _registeredFarmers[cleanPhone] = newFarmer;
    _passwords[cleanPhone] = password;
    return newFarmer;
  }

  Farmer? verifyOtp(String phone, String otp) {
    final cleanPhone = Validators.sanitizeMobile(phone);
    if (_registeredFarmers.containsKey(cleanPhone)) {
      return _registeredFarmers[cleanPhone];
    }
    return null;
  }
}
