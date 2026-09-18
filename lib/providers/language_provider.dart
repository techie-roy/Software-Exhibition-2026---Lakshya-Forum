import 'package:flutter/foundation.dart';
import '../models/language.dart';
import '../services/local_storage_service.dart';

class LanguageProvider extends ChangeNotifier {
  final LocalStorageService _storageService;

  AppLanguage _currentLanguage = AppLanguage.supportedLanguages.first; // English default

  LanguageProvider(this._storageService) {
    _loadLanguage();
  }

  AppLanguage get currentLanguage => _currentLanguage;

  Future<void> _loadLanguage() async {
    final savedCode = await _storageService.getSavedLanguage();
    if (savedCode != null) {
      final found = AppLanguage.supportedLanguages.firstWhere(
        (l) => l.code == savedCode,
        orElse: () => AppLanguage.supportedLanguages.first,
      );
      _currentLanguage = found;
      notifyListeners();
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage.code == language.code) return;
    _currentLanguage = language;
    notifyListeners();
    await _storageService.saveLanguage(language.code);
  }
}
