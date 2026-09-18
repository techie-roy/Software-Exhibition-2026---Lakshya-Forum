import 'package:flutter/foundation.dart';
import '../models/farmer.dart';
import '../services/local_storage_service.dart';
import '../services/mock_auth_service.dart';
class AuthProvider extends ChangeNotifier {
  final MockAuthService _authService;
  final LocalStorageService _storageService;

  Farmer? _currentFarmer;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._authService, this._storageService) {
    _init();
  }

  Farmer? get currentFarmer => _currentFarmer;
  bool get isLoggedIn => _currentFarmer != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _init() async {
    final loggedIn = await _storageService.isLoggedIn();
    if (loggedIn) {
      // Default to primary mock farmer Rajesh Kumar on auto-login
      _currentFarmer = _authService.getFarmer('9876543210');
      notifyListeners();
    }
  }

  bool isMobileRegistered(String phone) {
    return _authService.isMobileRegistered(phone);
  }

  Future<bool> loginWithPassword(String phone, String password) async {
    _setLoading(true);
    _clearError();

    // Fast mock delay for realistic feel
    await Future.delayed(const Duration(milliseconds: 300));

    final farmer = _authService.loginWithPassword(phone, password);
    if (farmer != null) {
      _currentFarmer = farmer;
      await _storageService.setLoggedIn(true, phone: phone, name: farmer.name);
      _setLoading(false);
      return true;
    } else {
      _errorMessage = 'Invalid mobile number or password';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyOtpAndLogin(String phone, String otp) async {
    _setLoading(true);
    _clearError();

    await Future.delayed(const Duration(milliseconds: 300));

    final farmer = _authService.verifyOtp(phone, otp);
    if (farmer != null) {
      _currentFarmer = farmer;
      await _storageService.setLoggedIn(true, phone: phone, name: farmer.name);
      _setLoading(false);
      return true;
    } else {
      _errorMessage = 'Invalid OTP. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  /// Mock: sends/generates an OTP for the given mobile number during registration.
  /// In production, replace this with a real SMS/OTP provider integration.
  Future<bool> sendRegistrationOtp(String phone) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock OTP is always accepted; replace with real provider later.
    if (kDebugMode) {
      debugPrint('[MOCK OTP] Sent to $phone');
    }
    return true;
  }

  /// Verifies OTP for a registration flow (user not yet in database).
  /// Mock: accepts any 6-digit code. Replace with real provider verification later.
  Future<bool> verifyRegistrationOtp(String phone, String otp) async {
    _setLoading(true);
    _clearError();

    await Future.delayed(const Duration(milliseconds: 300));

    // Mock OTP: accept any 6-digit code
    if (otp.length == 6 && RegExp(r'^\d{6}$').hasMatch(otp)) {
      _setLoading(false);
      return true;
    }

    _errorMessage = 'Invalid OTP. Please try again.';
    _setLoading(false);
    return false;
  }

  /// Completes the registration after OTP verification by creating the account.
  Future<bool> completeRegistration({
    required String name,
    required String phone,
    required String password,
    String? aadhaar,
    String? dob,
    String? email,
  }) async {
    _setLoading(true);
    _clearError();

    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final farmer = _authService.registerFarmer(
        name: name,
        phone: phone,
        password: password,
        aadhaar: aadhaar,
      );
      _currentFarmer = farmer;
      await _storageService.setLoggedIn(true, phone: phone, name: farmer.name);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Unable to complete registration. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> registerAndLogin({
    required String name,
    required String phone,
    required String password,
    String? aadhaar,
  }) async {
    _setLoading(true);
    _clearError();

    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final farmer = _authService.registerFarmer(
        name: name,
        phone: phone,
        password: password,
        aadhaar: aadhaar,
      );
      _currentFarmer = farmer;
      await _storageService.setLoggedIn(true, phone: phone, name: farmer.name);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Unable to complete registration. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _currentFarmer = null;
    await _storageService.clearAuth();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
