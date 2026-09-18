import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

/// Maps a supported app language code (from [AppLanguage.supportedLanguages])
/// to the TTS locale used by the platform voice.
const Map<String, String> kAppToTtsLocale = {
  'en': 'en-US',
  'hi': 'hi-IN',
  'te': 'te-IN',
  'ta': 'ta-IN',
  'mr': 'mr-IN',
  'bn': 'bn-IN',
  'gu': 'gu-IN',
  'pa': 'pa-IN',
  'kn': 'kn-IN',
};

/// Returns the TTS locale for an app language [code], falling back to
/// English (en-US) for unknown codes.
String ttsLocaleForLanguageCode(String code) =>
    kAppToTtsLocale[code] ?? 'en-US';

/// Abstraction over the device text-to-speech engine so the voice booking
/// screen can be driven by the real voice on-device and by a fake in tests.
abstract class TextToSpeechService {
  /// Prepares the TTS engine and installs completion/error handlers.
  Future<void> initialize();

  /// Switches the spoken voice to [locale] (e.g. 'hi-IN').
  Future<void> setLanguage(String locale);

  /// Speaks [text] and completes only after the utterance has finished
  /// (or has been interrupted by [stop]).
  Future<void> speak(String text);

  /// Interrupts any ongoing utterance immediately.
  Future<void> stop();

  /// Releases platform resources.
  Future<void> dispose();
}

class FlutterTextToSpeechService implements TextToSpeechService {
  final FlutterTts _tts = FlutterTts();

  bool _initialized = false;
  bool _speaking = false;
  Completer<void>? _active;
  Timer? _watchdog;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _tts.setCompletionHandler(_onFinished);
    _tts.setErrorHandler((message) => _onFinished());
    _tts.setCancelHandler(_onFinished);
    try {
      await _tts.awaitSpeakCompletion(true);
    } catch (_) {
      // Best-effort; the completion handler below is the source of truth.
    }
    _initialized = true;
  }

  void _onFinished() {
    _watchdog?.cancel();
    _watchdog = null;
    _speaking = false;
    final active = _active;
    _active = null;
    if (active != null && !active.isCompleted) {
      active.complete();
    }
  }

  @override
  Future<void> setLanguage(String locale) async {
    await initialize();
    await _tts.setLanguage(locale);
  }

  @override
  Future<void> speak(String text) async {
    await initialize();
    if (text.trim().isEmpty) return;

    // Prevent overlapping utterances.
    if (_speaking) {
      await stop();
    }

    final completer = Completer<void>();
    _active = completer;
    _speaking = true;
    _watchdog?.cancel();
    _watchdog = Timer(const Duration(seconds: 60), _onFinished);

    try {
      await _tts.speak(text, focus: true);
      await completer.future;
    } catch (_) {
      _onFinished();
      rethrow;
    } finally {
      _watchdog?.cancel();
      _watchdog = null;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      // Ignore platform stop errors; the utterance is considered finished.
    }
    _onFinished();
  }

  @override
  Future<void> dispose() async {
    await stop();
    try {
      await _tts.stop();
    } catch (_) {}
  }
}