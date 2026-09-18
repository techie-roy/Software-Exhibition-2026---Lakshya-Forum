import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_queue/app/localizations.dart';
import 'package:agri_queue/models/language.dart';
import 'package:agri_queue/providers/language_provider.dart';
import 'package:agri_queue/services/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('S localization helpers', () {
    late LanguageProvider enProvider;
    late LanguageProvider hiProvider;
    late LanguageProvider teProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      enProvider = LanguageProvider(LocalStorageService());
      hiProvider = LanguageProvider(LocalStorageService());
      teProvider = LanguageProvider(LocalStorageService());
      // Let every provider's background _loadLanguage settle to the default
      // (English) before any writes to the shared mock preferences store.
      await Future<void>.delayed(Duration.zero);
      final hi = AppLanguage.supportedLanguages[1];
      final te = AppLanguage.supportedLanguages.firstWhere((l) => l.code == 'te');
      await hiProvider.setLanguage(hi);
      await teProvider.setLanguage(te);
    });

    test('English defaults resolve crop/category/gate names', () {
      final s = S(enProvider);
      expect(s.cropName('wheat'), 'Wheat');
      expect(s.cropName('paddy'), 'Paddy');
      expect(s.categoryName('cereals'), 'Cereals');
      expect(s.gateStatusName('high_crowd'), 'High Crowd');
      expect(s.translate('step_booked'), 'Booked');
      expect(s.refreshingInSeconds(30), 'Refreshing in 30s');
      expect(s.bookingId, 'Booking ID: ');
      expect(s.liveBadge, 'LIVE');
      expect(s.aiInsightText, startsWith('Wheat prices may remain stable'));
    });

    test('Hindi resolves stable IDs to localized names', () {
      final s = S(hiProvider);
      expect(s.cropName('wheat'), 'गेहूँ');
      expect(s.cropName('paddy'), 'धान');
      expect(s.categoryName('cereals'), 'अनाज');
      expect(s.gateStatusName('high_crowd'), 'उच्च भीड़');
      expect(s.translate('step_booked'), 'बुक किया');
      expect(s.bookingId, 'बुकिंग आईडी: ');
      expect(s.liveBadge, 'लाइव');
    });

    test('Unknown crop/category IDs fall back to the raw ID', () {
      final s = S(enProvider);
      expect(s.cropName('almond'), 'almond');
      expect(s.categoryName('unknown'), 'unknown');
      expect(s.gateStatusName('closed'), 'closed');
      expect(s.translate('nonexistent_key'), 'nonexistent_key');
    });

    test('Languages without a key fall back to English, never to the raw key', () {
      final s = S(teProvider);
      expect(s.translate('crop_wheat'), 'Wheat');
      expect(s.cropName('wheat'), 'Wheat');
      expect(s.translate('step_booked'), 'Booked');
    });
  });
}