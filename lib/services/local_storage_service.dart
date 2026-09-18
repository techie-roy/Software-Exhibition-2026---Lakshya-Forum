import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyLanguage = 'selected_language';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyFarmerPhone = 'farmer_phone';
  static const String _keyFarmerName = 'farmer_name';

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

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyFarmerPhone);
    await prefs.remove(_keyFarmerName);
  }
}
