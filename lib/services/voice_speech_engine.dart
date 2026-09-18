import 'dart:async';

import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:speech_to_text/speech_to_text.dart';

enum VoiceSpeechInitResult { success, unavailable }

class VoiceUtterance {
  final String words;

  const VoiceUtterance([this.words = '']);

  bool get empty => words.trim().isEmpty;

  factory VoiceUtterance.empty() => const VoiceUtterance();

  @override
  String toString() => 'VoiceUtterance("$words")';
}

/// Abstraction over platform speech recognition and microphone permission so
/// the voice booking screen can be driven by the real engine on-device and by
/// a fake engine in widget tests.
abstract class VoiceSpeechEngine {
  bool get isInitialized;

  /// Checks that speech recognition is available on this device and prepares
  /// the engine. Does not request microphone permission.
  Future<VoiceSpeechInitResult> initialize();

  /// Requests microphone permission via the platform permission dialog.
  Future<bool> requestPermission();

  /// Opens the system app settings (used when permission is permanently denied).
  Future<void> openAppSettings();

  /// Listens for a single utterance. Completes with the recognized words, or
  /// an empty [VoiceUtterance] if nothing was recognized within [timeout].
  Future<VoiceUtterance> recognize({
    required String localeId,
    required Duration timeout,
  });

  /// Stops the current listening session, if any.
  Future<void> cancel();

  /// Releases platform resources.
  Future<void> dispose();
}

class SpeechToTextVoiceEngine implements VoiceSpeechEngine {
  final SpeechToText _speech = SpeechToText();

  bool _initialized = false;
  bool _listening = false;
  Timer? _timeout;
  Completer<VoiceUtterance>? _activeCompleter;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<VoiceSpeechInitResult> initialize() async {
    if (_initialized) return VoiceSpeechInitResult.success;
    try {
      final available = await _speech.initialize();
      _initialized = available;
      return available
          ? VoiceSpeechInitResult.success
          : VoiceSpeechInitResult.unavailable;
    } catch (_) {
      _initialized = false;
      return VoiceSpeechInitResult.unavailable;
    }
  }

  @override
  Future<bool> requestPermission() async {
    final status = await ph.Permission.microphone.request();
    return status.isGranted;
  }

  @override
  Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  @override
  Future<VoiceUtterance> recognize({
    required String localeId,
    required Duration timeout,
  }) async {
    final init = await initialize();
    if (init == VoiceSpeechInitResult.unavailable) {
      return VoiceUtterance.empty();
    }

    if (_activeCompleter != null && !_activeCompleter!.isCompleted) {
      await cancel();
    }

    final completer = Completer<VoiceUtterance>();
    _activeCompleter = completer;
    _listening = true;

    Future<void> finish(VoiceUtterance utterance) {
      if (completer.isCompleted) return Future.value();
      _timeout?.cancel();
      _listening = false;
      _activeCompleter = null;
      completer.complete(utterance);
      return Future.value();
    }

    await _speech.stop();
    await _speech.listen(
      onResult: (result) {
        final words = result.recognizedWords.trim();
        if (words.isEmpty) return;
        finish(VoiceUtterance(words));
      },
      listenOptions: SpeechListenOptions(
        partialResults: false,
        localeId: localeId,
        listenFor: timeout,
        pauseFor: const Duration(seconds: 4),
      ),
    );

    _timeout?.cancel();
    _timeout = Timer(timeout + const Duration(seconds: 2), () {
      finish(VoiceUtterance.empty());
      if (_listening) {
        _speech.stop();
      }
    });

    return completer.future;
  }

  @override
  Future<void> cancel() async {
    _timeout?.cancel();
    _timeout = null;
    if (_speech.isListening) {
      await _speech.stop();
    }
    _listening = false;
    final completers = _activeCompleter;
    _activeCompleter = null;
    if (completers != null && !completers.isCompleted) {
      completers.complete(VoiceUtterance.empty());
    }
  }

  @override
  Future<void> dispose() async {
    await cancel();
    await _speech.cancel();
  }
}