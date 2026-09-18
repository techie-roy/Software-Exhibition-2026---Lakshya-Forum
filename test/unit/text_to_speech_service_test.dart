import 'package:flutter_test/flutter_test.dart';
import 'package:agri_queue/models/language.dart';
import 'package:agri_queue/services/text_to_speech_service.dart';

void main() {
  group('ttsLocaleForLanguageCode', () {
    test('maps every supported app language to its own TTS locale', () {
      expect(ttsLocaleForLanguageCode('en'), 'en-US');
      expect(ttsLocaleForLanguageCode('hi'), 'hi-IN');
      expect(ttsLocaleForLanguageCode('te'), 'te-IN');
      expect(ttsLocaleForLanguageCode('ta'), 'ta-IN');
      expect(ttsLocaleForLanguageCode('mr'), 'mr-IN');
      expect(ttsLocaleForLanguageCode('bn'), 'bn-IN');
      expect(ttsLocaleForLanguageCode('gu'), 'gu-IN');
      expect(ttsLocaleForLanguageCode('pa'), 'pa-IN');
      expect(ttsLocaleForLanguageCode('kn'), 'kn-IN');
    });

    test('all supported languages have an entry in the mapping', () {
      for (final language in AppLanguage.supportedLanguages) {
        expect(
          kAppToTtsLocale.containsKey(language.code),
          isTrue,
          reason: '${language.code} must map to a TTS locale',
        );
      }
    });

    test('unknown language falls back to en-US', () {
      expect(ttsLocaleForLanguageCode('xx'), 'en-US');
      expect(ttsLocaleForLanguageCode(''), 'en-US');
    });
  });
}