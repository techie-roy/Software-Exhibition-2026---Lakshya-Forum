import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_queue/models/language.dart';
import 'package:agri_queue/providers/auth_provider.dart';
import 'package:agri_queue/providers/booking_provider.dart';
import 'package:agri_queue/providers/language_provider.dart';
import 'package:agri_queue/providers/queue_provider.dart';
import 'package:agri_queue/screens/voice_booking_screen.dart';
import 'package:agri_queue/services/local_storage_service.dart';
import 'package:agri_queue/services/mock_auth_service.dart';
import 'package:agri_queue/services/mock_data_service.dart';
import 'package:agri_queue/services/text_to_speech_service.dart';
import 'package:agri_queue/services/voice_speech_engine.dart';

// English strings (the default test language).
const enCropPrompt =
    'Please tell me the crop you want to book. For example, wheat, paddy, or mustard.';
const enTimePromptWheat =
    'You selected Wheat. Please tell me which time slot you need.';
const enChecking9 = 'You selected 9:00 AM. Checking slot availability.';
const enAvail9 =
    'The slot at 9:00 AM is available. Your token is being booked.';
const enFallback1To7 =
    'The slot at 1:00 AM is not available. Booking the nearest available slot for you at 7:00 AM.';
const enSuccessPrefix =
    'Your token has been booked successfully. Your slot is at ';
const enDeniedSpeech =
    'Microphone permission not granted. Please grant microphone permission and try again.';
const enTtsError =
    'Voice assistant could not be started. Please check your device settings and try again.';
const enRejected = 'Microphone permission is required for voice booking.';
const hiCropPrompt = 'कृपया फसल का नाम बताइए। जैसे गेहूं, धान या सरसों।';

class FakeTextToSpeechService implements TextToSpeechService {
  final List<String> log;
  final Duration speakDelay;
  final bool failStart;
  final bool failSpeak;

  int initializeCount = 0;
  int setLanguageCount = 0;
  int speakCount = 0;
  int stopCount = 0;
  int disposeCount = 0;
  String? lastLocale;
  final List<String> spokenTexts = [];

  FakeTextToSpeechService({
    required this.log,
    this.speakDelay = Duration.zero,
    this.failStart = false,
    this.failSpeak = false,
  });

  @override
  Future<void> initialize() async {
    initializeCount++;
    if (failStart) throw StateError('tts unavailable');
    log.add('ttsInit');
  }

  @override
  Future<void> setLanguage(String locale) async {
    setLanguageCount++;
    lastLocale = locale;
    log.add('setLanguage:$locale');
  }

  @override
  Future<void> speak(String text) async {
    speakCount++;
    if (failSpeak) throw StateError('tts speak failed');
    log.add('speak:$text');
    if (speakDelay > Duration.zero) {
      await Future<void>.delayed(speakDelay);
    }
    spokenTexts.add(text);
    log.add('speakDone:$text');
  }

  @override
  Future<void> stop() async {
    stopCount++;
    log.add('ttsStop');
  }

  @override
  Future<void> dispose() async {
    disposeCount++;
    log.add('ttsDispose');
  }
}

class FakeVoiceSpeechEngine implements VoiceSpeechEngine {
  final List<String> log;
  final List<String> results;
  final bool permissionGranted;
  final bool speechAvailable;

  int initializeCount = 0;
  int permissionCount = 0;
  int recognizeCallCount = 0;
  int openSettingsCount = 0;
  int cancelCount = 0;
  int disposeCount = 0;

  bool _isInitialized = false;

  FakeVoiceSpeechEngine({
    required this.log,
    this.results = const [],
    this.permissionGranted = true,
    this.speechAvailable = true,
  });

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<VoiceSpeechInitResult> initialize() async {
    initializeCount++;
    _isInitialized = speechAvailable;
    log.add('speechInit');
    return speechAvailable
        ? VoiceSpeechInitResult.success
        : VoiceSpeechInitResult.unavailable;
  }

  @override
  Future<bool> requestPermission() async {
    permissionCount++;
    log.add('perm');
    return permissionGranted;
  }

  @override
  Future<void> openAppSettings() async {
    openSettingsCount++;
  }

  @override
  Future<VoiceUtterance> recognize({
    required String localeId,
    required Duration timeout,
  }) async {
    recognizeCallCount++;
    log.add('listen');
    final index = recognizeCallCount - 1;
    if (index < results.length) return VoiceUtterance(results[index]);
    return VoiceUtterance.empty();
  }

  @override
  Future<void> cancel() async {
    cancelCount++;
    log.add('cancel');
  }

  @override
  Future<void> dispose() async {
    disposeCount++;
    log.add('speechDispose');
  }
}

class VoiceHarness {
  final MockDataService data;
  final LocalStorageService storage = LocalStorageService();
  late final LanguageProvider lang = LanguageProvider(storage);
  late final AuthProvider auth = AuthProvider(MockAuthService(), storage);
  late final BookingProvider booking = BookingProvider(data);
  late final QueueProvider queue = QueueProvider(data);

  VoiceHarness(this.data);

  Widget buildApp({
    required FakeTextToSpeechService tts,
    required FakeVoiceSpeechEngine speech,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: lang),
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: booking),
        ChangeNotifierProvider.value(value: queue),
      ],
      child: MaterialApp(
        home: VoiceBookingScreen(tts: tts, speechEngine: speech),
      ),
    );
  }
}

/// Events that matter for the TTS<->listen synchronization check.
List<String> _speakListenEvents(List<String> log) {
  return [
    for (final e in log)
      if (e == 'listen' || e.startsWith('speak:') || e.startsWith('speakDone:'))
        e,
  ];
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('VoiceBookingScreen with TTS', () {
    testWidgets('Initial state renders mic UI before any voice call', (
      WidgetTester tester,
    ) async {
      final log = <String>[];
      final tts = FakeTextToSpeechService(log: log);
      final speech = FakeVoiceSpeechEngine(log: log);
      final harness = VoiceHarness(MockDataService());

      await tester.pumpWidget(harness.buildApp(tts: tts, speech: speech));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Book by Voice'), findsOneWidget);
      expect(find.text('Press the mic and speak'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
      expect(tts.initializeCount, 0);
      expect(tts.speakCount, 0);
      expect(speech.permissionCount, 0);
      expect(speech.recognizeCallCount, 0);
    });

    testWidgets(
      'VERY IMPORTANT: speak(crop) completes BEFORE listening; full ordered '
      'flow speak->listen->speak->listen->check->speak->book->speak(success)',
      (WidgetTester tester) async {
        final log = <String>[];
        final tts = FakeTextToSpeechService(
          log: log,
          speakDelay: const Duration(milliseconds: 40),
        );
        final speech = FakeVoiceSpeechEngine(
          log: log,
          results: const ['wheat', '9 AM'],
        );
        final harness = VoiceHarness(MockDataService());

        await tester.pumpWidget(harness.buildApp(tts: tts, speech: speech));
        await tester.pump(const Duration(milliseconds: 100));

        await tester.tap(find.text('Start'));
        // Let the whole flow run to completion (5 short utterances).
        for (var i = 0; i < 8; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        await tester.pump(const Duration(milliseconds: 150));

        final events = _speakListenEvents(log);

        // No listening ever starts while an utterance is still speaking.
        expect(
          events.indexOf('listen') > events.indexOf('speakDone:$enCropPrompt'),
          isTrue,
          reason: 'listening must NOT start before the crop prompt finished',
        );

        final expectedLead = <String>[
          'speak:$enCropPrompt',
          'speakDone:$enCropPrompt',
          'listen',
          'speak:$enTimePromptWheat',
          'speakDone:$enTimePromptWheat',
          'listen',
          'speak:$enChecking9',
          'speakDone:$enChecking9',
          'speak:$enAvail9',
          'speakDone:$enAvail9',
        ];
        expect(events.take(expectedLead.length), expectedLead);

        expect(events.length, 12);
        expect(
          events[10].startsWith('speak:$enSuccessPrefix'),
          isTrue,
          reason: 'success announcement must be spoken after booking',
        );
        expect(events[11].startsWith('speakDone:$enSuccessPrefix'), isTrue);

        // No duplicate speak/listen.
        expect(tts.speakCount, 5);
        expect(speech.recognizeCallCount, 2);

        // Flow reached the success UI with the real booking.
        expect(find.text('Token booked successfully'), findsOneWidget);
        final booked = harness.data.activeBooking;
        expect(booked.crop, 'wheat');
      },
    );

    testWidgets('Success announcement speaks the REAL token and booked time', (
      WidgetTester tester,
    ) async {
      final log = <String>[];
      final tts = FakeTextToSpeechService(log: log);
      final speech = FakeVoiceSpeechEngine(
        log: log,
        results: const ['wheat', '9 AM'],
      );
      final harness = VoiceHarness(MockDataService());

      await tester.pumpWidget(harness.buildApp(tts: tts, speech: speech));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Start'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Token booked successfully'), findsOneWidget);

      final booked = harness.data.activeBooking;
      final successSpoken = tts.spokenTexts.last;
      expect(
        successSpoken.contains(booked.tokenNumber),
        isTrue,
        reason: 'success voice must contain the REAL generated token',
      );
      expect(
        successSpoken.contains('9:00 AM'),
        isTrue,
        reason: 'success voice must contain the REAL booked slot time',
      );
      expect(successSpoken.startsWith(enSuccessPrefix), isTrue);

      // UI shows real values.
      expect(find.text(booked.tokenNumber), findsOneWidget);
      expect(find.text('09:00 AM – 11:00 AM'), findsOneWidget);
      expect(find.text('Gate 2'), findsWidgets);
    });

    testWidgets(
      'Unavailable requested slot auto-books nearest and clearly distinguishes '
      'requested vs booked in UI and voice',
      (WidgetTester tester) async {
        final log = <String>[];
        final tts = FakeTextToSpeechService(log: log);
        final speech = FakeVoiceSpeechEngine(
          log: log,
          results: const ['wheat', '1 am'],
        );
        final harness = VoiceHarness(MockDataService());

        await tester.pumpWidget(harness.buildApp(tts: tts, speech: speech));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(find.text('Start'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.text('Token booked successfully'), findsOneWidget);

        // Fallback announcement was spoken before booking.
        expect(tts.spokenTexts.any((t) => t == enFallback1To7), isTrue);

        // Success voice uses the ACTUAL booked slot time and token.
        final booked = harness.data.activeBooking;
        expect(booked.timeRange, '07:00 AM – 09:00 AM');
        final successSpoken = tts.spokenTexts.last;
        expect(successSpoken.contains(booked.tokenNumber), isTrue);
        expect(successSpoken.contains('7:00 AM'), isTrue);

        // UI clearly distinguishes requested vs booked vs reason.
        expect(find.text('Requested Slot'), findsOneWidget);
        expect(find.text('1:00 AM'), findsWidgets);
        expect(find.text('Booked Slot'), findsOneWidget);
        expect(find.text('07:00 AM – 09:00 AM'), findsWidgets);
        expect(find.text('Reason'), findsOneWidget);
      },
    );
  });

  group('VoiceBookingScreen error states', () {
    testWidgets('Permission denied speaks the announcement and never listens', (
      WidgetTester tester,
    ) async {
      final log = <String>[];
      final tts = FakeTextToSpeechService(log: log);
      final speech = FakeVoiceSpeechEngine(log: log, permissionGranted: false);
      final harness = VoiceHarness(MockDataService());

      await tester.pumpWidget(harness.buildApp(tts: tts, speech: speech));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Start'));
      await tester.pump(const Duration(milliseconds: 50));

      expect(tts.spokenTexts, contains(enDeniedSpeech));
      expect(speech.recognizeCallCount, 0);
      expect(
        find.text('Microphone permission is required for voice booking.'),
        findsOneWidget,
      );
      expect(find.text('Grant Microphone Permission'), findsOneWidget);
      expect(find.text('Open Settings'), findsOneWidget);

      // Retrying re-asks for permission.
      await tester.tap(find.text('Grant Microphone Permission'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(speech.permissionCount, 2);
      expect(tts.spokenTexts.where((t) => t == enDeniedSpeech).length, 2);
    });

    testWidgets('Speech engine unavailable speaks error and shows error UI', (
      WidgetTester tester,
    ) async {
      final log = <String>[];
      final tts = FakeTextToSpeechService(log: log);
      final speech = FakeVoiceSpeechEngine(log: log, speechAvailable: false);
      final harness = VoiceHarness(MockDataService());

      await tester.pumpWidget(harness.buildApp(tts: tts, speech: speech));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Start'));
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        tts.spokenTexts.last,
        'Voice booking unavailable. You can book manually.',
      );
      expect(speech.recognizeCallCount, 0);
      expect(
        find.text('Voice booking unavailable. You can book manually.'),
        findsOneWidget,
      );
    });

    testWidgets('No speech detected speaks not-understood then re-listens', (
      WidgetTester tester,
    ) async {
      final log = <String>[];
      final tts = FakeTextToSpeechService(log: log);
      final speech = FakeVoiceSpeechEngine(
        log: log,
        results: const ['wheat', '', '9 AM'],
      );
      final harness = VoiceHarness(MockDataService());

      await tester.pumpWidget(harness.buildApp(tts: tts, speech: speech));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Start'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        tts.spokenTexts.any(
          (t) => t == 'I did not understand that. Please say it again.',
        ),
        isTrue,
      );
      // Retried listening completed the booking.
      expect(speech.recognizeCallCount, greaterThanOrEqualTo(3));
      expect(find.text('Token booked successfully'), findsOneWidget);
    });

    testWidgets('Unknown crop speaks repeat-crop then re-listens', (
      WidgetTester tester,
    ) async {
      final log = <String>[];
      final tts = FakeTextToSpeechService(log: log);
      final speech = FakeVoiceSpeechEngine(
        log: log,
        results: const ['hello there', 'wheat', '9 AM'],
      );
      final harness = VoiceHarness(MockDataService());

      await tester.pumpWidget(harness.buildApp(tts: tts, speech: speech));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Start'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        tts.spokenTexts.any(
          (t) =>
              t ==
              'Could not recognize the crop. Please say the crop name again.',
        ),
        isTrue,
      );
      expect(speech.recognizeCallCount, greaterThanOrEqualTo(3));
      expect(find.text('Token booked successfully'), findsOneWidget);
    });

    testWidgets('Unknown time speaks repeat-time then re-listens', (
      WidgetTester tester,
    ) async {
      final log = <String>[];
      final tts = FakeTextToSpeechService(log: log);
      final speech = FakeVoiceSpeechEngine(
        log: log,
        results: const ['wheat', 'nonsense', '9 AM'],
      );
      final harness = VoiceHarness(MockDataService());

      await tester.pumpWidget(harness.buildApp(tts: tts, speech: speech));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Start'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        tts.spokenTexts.any(
          (t) =>
              t == 'Could not understand the time. Please say the time again.',
        ),
        isTrue,
      );
      expect(speech.recognizeCallCount, greaterThanOrEqualTo(3));
      expect(find.text('Token booked successfully'), findsOneWidget);
    });

    testWidgets('TTS initialization failure shows spoken + UI error', (
      WidgetTester tester,
    ) async {
      final log = <String>[];
      final tts = FakeTextToSpeechService(log: log, failStart: true);
      final speech = FakeVoiceSpeechEngine(log: log);
      final harness = VoiceHarness(MockDataService());

      await tester.pumpWidget(harness.buildApp(tts: tts, speech: speech));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Start'));
      await tester.pump(const Duration(milliseconds: 50));

      expect(tts.speakCount, 0);
      expect(find.text(enTtsError), findsWidgets);

      // Retrying re-attempts initialization without crashing.
      await tester.tap(find.text('Try Again'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(tts.initializeCount, 2);
      expect(find.text(enTtsError), findsWidgets);
    });

    testWidgets('Disposal stops and disposes both TTS and speech engine', (
      WidgetTester tester,
    ) async {
      final log = <String>[];
      final tts = FakeTextToSpeechService(
        log: log,
        speakDelay: const Duration(milliseconds: 40),
      );
      final speech = FakeVoiceSpeechEngine(log: log, results: const ['wheat']);
      final harness = VoiceHarness(MockDataService());

      await tester.pumpWidget(harness.buildApp(tts: tts, speech: speech));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Start'));
      await tester.pump(const Duration(milliseconds: 20));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));

      expect(tts.disposeCount, 1);
      expect(tts.stopCount, greaterThanOrEqualTo(1));
      expect(speech.disposeCount, 1);
    });
  });

  group('VoiceBookingScreen language and TTS locale', () {
    final hi = AppLanguage.supportedLanguages.firstWhere((l) => l.code == 'hi');
    final en = AppLanguage.supportedLanguages.firstWhere((l) => l.code == 'en');

    testWidgets('Default language sets English TTS locale', (
      WidgetTester tester,
    ) async {
      final log = <String>[];
      final tts = FakeTextToSpeechService(log: log);
      final speech = FakeVoiceSpeechEngine(
        log: log,
        results: const ['wheat', '9 AM'],
      );
      final harness = VoiceHarness(MockDataService());

      await tester.pumpWidget(harness.buildApp(tts: tts, speech: speech));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Start'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      expect(tts.lastLocale, 'en-US');
      expect(tts.spokenTexts.first, enCropPrompt);
    });

    testWidgets('Changing language to Hindi updates TTS locale and narration', (
      WidgetTester tester,
    ) async {
      final log = <String>[];
      final tts = FakeTextToSpeechService(log: log);
      final speech = FakeVoiceSpeechEngine(
        log: log,
        results: const ['wheat', '9 AM'],
      );
      final harness = VoiceHarness(MockDataService());

      await tester.pumpWidget(harness.buildApp(tts: tts, speech: speech));
      await tester.pump(const Duration(milliseconds: 100));

      await harness.lang.setLanguage(hi);
      await tester.pump(const Duration(milliseconds: 100));

      expect(tts.lastLocale, 'hi-IN');

      await tester.tap(find.text('शुरू करें'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      expect(tts.lastLocale, 'hi-IN');
      expect(tts.spokenTexts.first, hiCropPrompt);
      expect(tts.setLanguageCount, greaterThanOrEqualTo(2));

      // Live change after the screen is visible also works.
      await harness.lang.setLanguage(en);
      await tester.pump(const Duration(milliseconds: 100));
      expect(tts.lastLocale, 'en-US');
    });
  });
}
