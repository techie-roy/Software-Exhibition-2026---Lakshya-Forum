import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/farmer.dart';

class LocalStorageService {
  static const String _keyLanguage = 'selected_language';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyFarmerPhone = 'farmer_phone';
  static const String _keyFarmerName = 'farmer_name';
  static const String _keyFarmerProfile = 'farmer_profile';
  static const String _keyRegisteredAccounts = 'registered_accounts_db';
  static const String _keyAuthVerifiers = 'auth_verifier_store_db';

  Future<void> saveLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, langCode);
  }

  Future<String?> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage);
  }

  Future<void> setLoggedIn(bool value, {String? phone, String? name}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, value);
    if (phone != null) await prefs.setString(_keyFarmerPhone, phone);
    if (name != null) await prefs.setString(_keyFarmerName, name);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<String?> getSavedFarmerPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFarmerPhone);
  }

  Future<String?> getSavedFarmerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFarmerName);
  }

  /// Persists the full signed-in profile so the exact farmer is restored on
  /// next launch. Only non-secret profile data is stored here; passwords and
  /// OTPs are never written to local storage.
  Future<void> saveFarmerProfile(Farmer farmer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFarmerProfile, jsonEncode(farmer.toJson()));
  }

  Future<Farmer?> getSavedFarmerProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyFarmerProfile);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return Farmer.fromJson(decoded);
      }
    } catch (_) {
      // Corrupt/unreadable profile: treat as signed out rather than guessing.
    }
    return null;
  }

  /// Persists a registered farmer account and its secure cryptographic verifier
  /// (hash). Plaintext passwords are NEVER stored.
  Future<void> persistRegisteredFarmer(
    Farmer farmer,
    String verifierHash,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = await getPersistedRegisteredFarmers();
    final verifiers = await getPersistedAuthVerifiers();

    final phoneDigits = farmer.mobile.replaceAll(RegExp(r'\D'), '');
    final cleanPhone = phoneDigits.length > 10
        ? phoneDigits.substring(phoneDigits.length - 10)
        : phoneDigits;

    accounts[cleanPhone] = farmer;
    verifiers[cleanPhone] = verifierHash;

    final accountsJson = accounts.map((k, v) => MapEntry(k, v.toJson()));
    await prefs.setString(_keyRegisteredAccounts, jsonEncode(accountsJson));
    await prefs.setString(_keyAuthVerifiers, jsonEncode(verifiers));
  }

  Future<Map<String, Farmer>> getPersistedRegisteredFarmers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyRegisteredAccounts);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded.map(
          (k, v) => MapEntry(k, Farmer.fromJson(v as Map<String, dynamic>)),
        );
      }
    } catch (_) {}
    return {};
  }

  Future<Map<String, String>> getPersistedAuthVerifiers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyAuthVerifiers);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded.map((k, v) => MapEntry(k, v.toString()));
      }
    } catch (_) {}
    return {};
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyFarmerPhone);
    await prefs.remove(_keyFarmerName);
    await prefs.remove(_keyFarmerProfile);
  }
}
