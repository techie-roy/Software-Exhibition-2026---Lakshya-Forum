import '../models/farmer.dart';
import '../utils/password_hasher.dart';
import '../utils/validators.dart';

class MockAuthService {
  /// The single canonical demo farmer used across the prototype. Kept in one
  /// place so screens never hardcode an identity literal themselves.
  static const Farmer demoFarmer = Farmer(
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
  );

  /// The convenience demo OTP shown/auto-filled in the UI. It is NOT a secret
  /// and NOT the only accepted code (any 6-digit code is accepted in demo mode).
  static const String demoOtp = '123456';

  // Registered farmers database
  final Map<String, Farmer> _registeredFarmers = {
    '9876543210': demoFarmer,
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

  // Secure cryptographic password verifier hashes (salt = phone number)
  final Map<String, String> _passwordHashes = {
    '9876543210': PasswordHasher.hashPassword('123456', '9876543210'),
    '9812345678': PasswordHasher.hashPassword('123456', '9812345678'),
  };

  void loadPersistedData({
    required Map<String, Farmer> farmers,
    required Map<String, String> verifiers,
  }) {
    _registeredFarmers.addAll(farmers);
    _passwordHashes.addAll(verifiers);
  }

  String? getPasswordHash(String phone) {
    final cleanPhone = Validators.sanitizeMobile(phone);
    return _passwordHashes[cleanPhone];
  }

  bool isMobileRegistered(String phone) {
    final cleanPhone = Validators.sanitizeMobile(phone);
    return _registeredFarmers.containsKey(cleanPhone);
  }

  Farmer? getFarmer(String phone) {
    final cleanPhone = Validators.sanitizeMobile(phone);
    return _registeredFarmers[cleanPhone];
  }

  /// Verifies credentials against cryptographic salted hashes.
  /// Rejects incorrect passwords with null — never accepts arbitrary passwords.
  Farmer? loginWithPassword(String phone, String password) {
    final cleanPhone = Validators.sanitizeMobile(phone);
    final farmer = _registeredFarmers[cleanPhone];
    if (farmer == null) return null;
    if (password.isEmpty) return null;

    final expectedHash = _passwordHashes[cleanPhone];
    if (expectedHash == null) {
      return null;
    }

    if (!PasswordHasher.verifyPassword(
      password: password,
      salt: cleanPhone,
      expectedHash: expectedHash,
    )) {
      return null;
    }

    return farmer;
  }

  Farmer registerFarmer({
    required String name,
    required String phone,
    required String password,
    String? aadhaar,
    String? email,
  }) {
    final cleanPhone = Validators.sanitizeMobile(phone);
    final initials = name
        .trim()
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    String maskedAadhaar = 'XXXX-XXXX-9988';
    if (aadhaar != null && aadhaar.trim().isNotEmpty) {
      final cleanAadhaar = aadhaar.replaceAll(RegExp(r'\D'), '');
      if (cleanAadhaar.length >= 4) {
        maskedAadhaar =
            'XXXX-XXXX-${cleanAadhaar.substring(cleanAadhaar.length - 4)}';
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
      email: email,
    );

    _registeredFarmers[cleanPhone] = newFarmer;
    _passwordHashes[cleanPhone] = PasswordHasher.hashPassword(
      password,
      cleanPhone,
    );
    return newFarmer;
  }

  /// Demo-only OTP verification.
  ///
  /// Rejects anything that is not a 6-digit code, then returns the registered
  /// farmer. Any 6-digit code is accepted in demo mode ([demoOtp] is only a
  /// convenience hint). This is NOT real verification; the UI labels demo mode.
  Farmer? verifyOtp(String phone, String otp) {
    final cleanPhone = Validators.sanitizeMobile(phone);
    final farmer = _registeredFarmers[cleanPhone];
    if (farmer == null) return null;
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) return null;
    return farmer;
  }
}
