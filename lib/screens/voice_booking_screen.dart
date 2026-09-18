import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/constants.dart';
import '../app/localizations.dart';
import '../app/routes.dart';
import '../models/booking.dart';
import '../models/farmer.dart';
import '../models/slot.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/language_provider.dart';
import '../services/text_to_speech_service.dart';
import '../services/voice_booking_service.dart';
import '../services/voice_speech_engine.dart';
import '../utils/formatters.dart';
import '../widgets/info_card.dart';

/// Visible structural steps of the voice booking screen. The spoken
/// narration and the speaking/listening indicators live inside the [flow]
/// and [processing] steps, which always show the current prompt text.
enum _VoiceStep { idle, flow, processing, success, error }

enum _RetryAction { retryStart, listenCrop, listenTime, retryBooking }

class VoiceBookingScreen extends StatefulWidget {
  /// Injectable for widget tests; defaults to the real device engine.
  final VoiceSpeechEngine? speechEngine;

  /// Injectable for widget tests; defaults to the real device TTS service.
  final TextToSpeechService? tts;

  const VoiceBookingScreen({super.key, this.speechEngine, this.tts});

  @override
  State<VoiceBookingScreen> createState() => _VoiceBookingScreenState();
}

class _VoiceBookingScreenState extends State<VoiceBookingScreen> {
  static const Duration _listenTimeout = Duration(seconds: 12);

  late final VoiceSpeechEngine _engine;
  late final TextToSpeechService _tts;
  late final LanguageProvider _lang;

  _VoiceStep _step = _VoiceStep.idle;
  bool _isSpeaking = false;
  bool _isListening = false;
  bool _flowRunning = false;
  String _prompt = '';
  String? _cropId;
  int? _targetHour;
  String? _errorMessage;
  bool _isPermissionError = false;
  _RetryAction _retryAction = _RetryAction.retryStart;

  Booking? _bookedBooking;
  MandiSlot? _bookedSlot;
  bool _exactSlotBooked = true;

  static const Farmer _fallbackFarmer = Farmer(
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

  @override
  void initState() {
    super.initState();
    _engine = widget.speechEngine ?? SpeechToTextVoiceEngine();
    _tts = widget.tts ?? FlutterTextToSpeechService();
    _lang = context.read<LanguageProvider>();
    _lang.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _lang.removeListener(_onLanguageChanged);
    _tts.stop();
    _tts.dispose();
    _engine.dispose();
    super.dispose();
  }

  void _onLanguageChanged() {
    final locale = ttsLocaleForLanguageCode(_lang.currentLanguage.code);
    _tts.setLanguage(locale);
    if (mounted) setState(() {});
  }

  String _speechLocaleOf() {
    switch (_lang.currentLanguage.code) {
      case 'hi':
        return 'hi-IN';
      case 'te':
        return 'te-IN';
      case 'ta':
        return 'ta-IN';
      case 'mr':
        return 'mr-IN';
      default:
        return 'en-IN';
    }
  }

  // ---------------------------------------------------------------------
  // Speech + TTS plumbing
  // ---------------------------------------------------------------------

  /// Stops any ongoing microphone session, then speaks [text] in the current
  /// language. Returns true when the utterance finished without error. When
  /// [failOnError] is true a TTS failure switches to the error step.
  Future<bool> _speakChecked(String text, {bool failOnError = true}) async {
    if (text.trim().isEmpty) return true;
    try {
      await _engine.cancel();
      final locale = ttsLocaleForLanguageCode(_lang.currentLanguage.code);
      await _tts.setLanguage(locale);
      await _tts.initialize();
      await _tts.speak(text);
      return true;
    } catch (_) {
      if (failOnError && mounted) {
        _fail(S.of(context).voiceTtsError, retry: _RetryAction.retryStart);
      }
      return false;
    }
  }

  // ---------------------------------------------------------------------
  // Flow drivers
  // ---------------------------------------------------------------------

  Future<void> _startFlow() async {
    if (_flowRunning) return;
    _flowRunning = true;
    if (mounted) {
      setState(() {
        _errorMessage = null;
        _isPermissionError = false;
      });
    }

    try {
      final granted = await _engine.requestPermission();
      if (!mounted) return;
      if (!granted) {
        await _speakChecked(
          S.of(context).voicePermissionDeniedSpeech,
          failOnError: false,
        );
        if (!mounted) return;
        _fail(
          S.of(context).microphonePermissionDenied,
          retry: _RetryAction.retryStart,
          isPermissionError: true,
        );
        return;
      }

      final init = await _engine.initialize();
      if (!mounted) return;
      if (init == VoiceSpeechInitResult.unavailable) {
        await _speakChecked(
          S.of(context).voiceUnavailable,
          failOnError: false,
        );
        if (!mounted) return;
        _fail(
          S.of(context).voiceUnavailable,
          retry: _RetryAction.retryStart,
        );
        return;
      }

      await _runCropPromptFlow();
    } finally {
      _flowRunning = false;
    }
  }

  Future<void> _runCropPromptFlow() async {
    if (!mounted) return;
    final s = S.of(context);
    final prompt = s.voiceCropPrompt;
    setState(() {
      _step = _VoiceStep.flow;
      _prompt = prompt;
      _isSpeaking = true;
      _isListening = false;
      _cropId = null;
      _targetHour = null;
    });

    if (!await _speakChecked(prompt)) return;
    if (!mounted) return;
    setState(() => _isSpeaking = false);
    await _listenForCrop();
  }

  Future<void> _listenForCrop() async {
    if (!mounted) return;
    final s = S.of(context);
    await _tts.stop();
    if (!mounted) return;
    setState(() {
      _step = _VoiceStep.flow;
      _prompt = s.voiceCropPrompt;
      _isListening = true;
      _isSpeaking = false;
    });

    final utterance = await _engine.recognize(
      localeId: _speechLocaleOf(),
      timeout: _listenTimeout,
    );
    if (!mounted) return;
    setState(() => _isListening = false);

    if (utterance.empty) {
      final msg = s.voiceNotUnderstood;
      setState(() => _prompt = msg);
      if (!await _speakChecked(msg)) return;
      if (!mounted) return;
      await _listenForCrop();
      return;
    }

    final cropId = VoiceBookingService.recognizeCrop(utterance.words);
    if (cropId == null) {
      final msg = s.voiceRepeatCrop;
      setState(() => _prompt = msg);
      if (!await _speakChecked(msg)) return;
      if (!mounted) return;
      await _listenForCrop();
      return;
    }

    setState(() => _cropId = cropId);
    await _timePromptFlow();
  }

  Future<void> _timePromptFlow() async {
    if (!mounted) return;
    final s = S.of(context);
    final prompt = s.voiceTimePrompt(s.cropName(_cropId!));
    setState(() {
      _step = _VoiceStep.flow;
      _prompt = prompt;
      _isSpeaking = true;
      _isListening = false;
    });

    if (!await _speakChecked(prompt)) return;
    if (!mounted) return;
    setState(() => _isSpeaking = false);
    await _listenForTime();
  }

  Future<void> _listenForTime() async {
    if (!mounted) return;
    final s = S.of(context);
    await _tts.stop();
    if (!mounted) return;
    setState(() {
      _step = _VoiceStep.flow;
      _prompt = s.whichTimeSlot;
      _isListening = true;
      _isSpeaking = false;
    });

    final utterance = await _engine.recognize(
      localeId: _speechLocaleOf(),
      timeout: _listenTimeout,
    );
    if (!mounted) return;
    setState(() => _isListening = false);

    if (utterance.empty) {
      final msg = s.voiceNotUnderstood;
      setState(() => _prompt = msg);
      if (!await _speakChecked(msg)) return;
      if (!mounted) return;
      await _listenForTime();
      return;
    }

    final hour = VoiceBookingService.recognizeHour(utterance.words);
    if (hour == null) {
      final msg = s.voiceRepeatTime;
      setState(() => _prompt = msg);
      if (!await _speakChecked(msg)) return;
      if (!mounted) return;
      await _listenForTime();
      return;
    }

    _targetHour = hour;
    await _processBooking();
  }

  Future<void> _processBooking() async {
    if (!mounted) return;
    final s = S.of(context);
    final targetHour = _targetHour!;
    final spoken = s.spokenTime(targetHour);

    // Announce the recognized time, then check availability.
    final checking = s.voiceCheckingAnnouncement(spoken);
    setState(() {
      _step = _VoiceStep.processing;
      _prompt = checking;
      _isSpeaking = true;
      _isListening = false;
    });
    if (!await _speakChecked(checking)) return;
    if (!mounted) return;
    setState(() => _isSpeaking = false);

    final bookingProvider = context.read<BookingProvider>();
    final farmer = context.read<AuthProvider>().currentFarmer;

    final matches = VoiceBookingService.findBestSlots(
      slots: bookingProvider.filteredSlots,
      cropId: _cropId!,
      targetHour: targetHour,
    );

    if (matches.isEmpty) {
      final msg = s.voiceNoSlotsAnnouncement;
      setState(() {
        _prompt = msg;
        _isSpeaking = true;
      });
      await _speakChecked(msg, failOnError: false);
      if (!mounted) return;
      setState(() => _isSpeaking = false);
      _fail(s.noAvailableSlots, retry: _RetryAction.retryBooking);
      return;
    }

    final best = matches.first;
    final exact = best.hourDifference == 0;
    final bookedStartHour = targetHour + best.hourDifference;

    final announcement = exact
        ? s.voiceSlotAvailableAnnouncement(spoken)
        : s.voiceFallbackAnnouncement(spoken, s.spokenTime(bookedStartHour));
    setState(() {
      _prompt = announcement;
      _isSpeaking = true;
    });
    if (!await _speakChecked(announcement)) return;
    if (!mounted) return;
    setState(() => _isSpeaking = false);

    // Create the REAL booking through the provider.
    final resolvedFarmer = farmer ?? _fallbackFarmer;
    final Booking booking;
    try {
      booking = bookingProvider.bookSlot(
        slot: best.slot,
        farmer: resolvedFarmer,
      );
    } catch (_) {
      _fail(s.voiceBookingError, retry: _RetryAction.retryBooking);
      return;
    }

    if (!mounted) return;
    setState(() {
      _bookedSlot = best.slot;
      _bookedBooking = booking;
      _exactSlotBooked = exact;
      _step = _VoiceStep.success;
      _isSpeaking = false;
      _isListening = false;
    });

    // Announce success with the REAL booked time and REAL token.
    await _speakChecked(
      s.voiceSuccessAnnouncement(
        s.spokenTime(bookedStartHour),
        booking.tokenNumber,
      ),
      failOnError: false,
    );
  }

  void _retryFromError() {
    switch (_retryAction) {
      case _RetryAction.retryStart:
        _startFlow();
        break;
      case _RetryAction.listenCrop:
        _listenForCrop();
        break;
      case _RetryAction.listenTime:
        _listenForTime();
        break;
      case _RetryAction.retryBooking:
        _processBooking();
        break;
    }
  }

  void _fail(
    String message, {
    required _RetryAction retry,
    bool isPermissionError = false,
  }) {
    if (!mounted) return;
    setState(() {
      _step = _VoiceStep.error;
      _errorMessage = message;
      _retryAction = retry;
      _isPermissionError = isPermissionError;
      _isListening = false;
      _isSpeaking = false;
    });
  }

  void _goToQueueTracking() {
    Navigator.of(context).pushNamed(AppRoutes.queueTracking);
  }

  void _close() {
    Navigator.of(context).pop(true);
  }

  // ---------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(s.bookByVoice),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: _buildBody(s),
        ),
      ),
    );
  }

  Widget _buildBody(S s) {
    switch (_step) {
      case _VoiceStep.idle:
        return _IdlePanel(s: s, onStart: _startFlow);
      case _VoiceStep.flow:
        return _FlowPanel(
          s: s,
          isSpeaking: _isSpeaking,
          isListening: _isListening,
          prompt: _prompt,
          cropLabel: _cropId == null ? null : s.cropName(_cropId!),
          timeLabel: _targetHour == null ? null : s.spokenTime(_targetHour!),
          onCancel: _close,
        );
      case _VoiceStep.processing:
        return _ProcessingPanel(
          s: s,
          prompt: _prompt,
          cropLabel: _cropId == null ? null : s.cropName(_cropId!),
          timeLabel: s.spokenTime(_targetHour!),
          isSpeaking: _isSpeaking,
        );
      case _VoiceStep.success:
        return _SuccessPanel(
          s: s,
          booking: _bookedBooking!,
          bookedSlot: _bookedSlot!,
          cropLabel: s.cropName(_cropId!),
          requestedHour: _targetHour!,
          exactBooked: _exactSlotBooked,
          onTrackQueue: _goToQueueTracking,
          onDone: _close,
        );
      case _VoiceStep.error:
        return _ErrorPanel(
          s: s,
          message: _errorMessage ?? '',
          isPermissionError: _isPermissionError,
          onRetry: _retryFromError,
          onGrantPermission: _startFlow,
          onOpenSettings: _engine.openAppSettings,
          onManual: _close,
        );
    }
  }
}

// -----------------------------------------------------------------------
// Panels
// -----------------------------------------------------------------------

class _IdlePanel extends StatelessWidget {
  final S s;
  final VoidCallback onStart;

  const _IdlePanel({required this.s, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Container(
          width: 132,
          height: 132,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.mic_rounded, size: 64, color: Colors.white),
        ),
        const SizedBox(height: 28),
        Text(
          s.pressMicToSpeak,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          s.voiceExampleHint,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            height: 1.4,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: onStart,
          icon: const Icon(Icons.mic_rounded),
          label: Text(s.startVoice),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
      ],
    );
  }
}

class _PulsingMic extends StatefulWidget {
  final bool listening;

  const _PulsingMic({required this.listening});

  @override
  State<_PulsingMic> createState() => _PulsingMicState();
}

class _PulsingMicState extends State<_PulsingMic>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        return Transform.scale(
          scale: widget.listening ? _pulse.value : 1.0,
          child: Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              color: AppColors.surfacePaleGreen,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Icon(
              widget.listening
                  ? Icons.graphic_eq_rounded
                  : Icons.mic_rounded,
              size: 64,
              color: AppColors.primaryGreen,
            ),
          ),
        );
      },
    );
  }
}

class _SpeakingIcon extends StatelessWidget {
  const _SpeakingIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 132,
      decoration: BoxDecoration(
        color: AppColors.surfacePaleGreen,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.volume_up_rounded,
        size: 64,
        color: AppColors.primaryGreen,
      ),
    );
  }
}

class _FlowPanel extends StatelessWidget {
  final S s;
  final bool isSpeaking;
  final bool isListening;
  final String prompt;
  final String? cropLabel;
  final String? timeLabel;
  final VoidCallback onCancel;

  const _FlowPanel({
    required this.s,
    required this.isSpeaking,
    required this.isListening,
    required this.prompt,
    this.cropLabel,
    this.timeLabel,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        if (cropLabel != null || timeLabel != null) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              if (cropLabel != null) _Chip(label: cropLabel!),
              if (timeLabel != null) _Chip(label: timeLabel!),
            ],
          ),
          const SizedBox(height: 20),
        ],
        if (isListening)
          const _PulsingMic(listening: true)
        else if (isSpeaking)
          const _SpeakingIcon()
        else
          const _PulsingMic(listening: false),
        const SizedBox(height: 24),
        Text(
          isListening
              ? s.listening
              : isSpeaking
              ? s.speakNow
              : s.listenAgain,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          prompt,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            height: 1.45,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: onCancel,
          icon: const Icon(Icons.close_rounded),
          label: Text(s.cancel),
        ),
      ],
    );
  }
}

class _ProcessingPanel extends StatelessWidget {
  final S s;
  final String prompt;
  final String? cropLabel;
  final String timeLabel;
  final bool isSpeaking;

  const _ProcessingPanel({
    required this.s,
    required this.prompt,
    this.cropLabel,
    required this.timeLabel,
    required this.isSpeaking,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        if (cropLabel != null) ...[
          Text(
            s.cropSelected,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            cropLabel!,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
        ],
        const SizedBox(
          width: 52,
          height: 52,
          child: CircularProgressIndicator(
            strokeWidth: 3.5,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          prompt,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            height: 1.45,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          s.checkingAvailability,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfacePaleGreen,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }
}

class _SuccessPanel extends StatelessWidget {
  final S s;
  final Booking booking;
  final MandiSlot bookedSlot;
  final String cropLabel;
  final int requestedHour;
  final bool exactBooked;
  final VoidCallback onTrackQueue;
  final VoidCallback onDone;

  const _SuccessPanel({
    required this.s,
    required this.booking,
    required this.bookedSlot,
    required this.cropLabel,
    required this.requestedHour,
    required this.exactBooked,
    required this.onTrackQueue,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          const Icon(
            Icons.verified_rounded,
            size: 72,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(height: 16),
          Text(
            s.voiceBookingSuccess,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          if (!exactBooked) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.statusWarningBg,
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusMedium,
                ),
                border: Border.all(
                  color: AppColors.statusWarning.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.sync_alt_rounded,
                    color: AppColors.statusWarning,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      s.requestedSlotUnavailableAuto,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          InfoCard(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!exactBooked) ...[
                  _SuccessRow(
                    label: s.requestedSlot,
                    value: s.spokenTime(requestedHour),
                  ),
                  const Divider(height: 16, color: AppColors.borderSubtle),
                  _SuccessRow(
                    label: s.reasonLabel,
                    value: s.fallbackReason,
                  ),
                  const Divider(height: 16, color: AppColors.borderSubtle),
                ],
                _SuccessRow(label: s.crop, value: cropLabel),
                const Divider(height: 16, color: AppColors.borderSubtle),
                _SuccessRow(
                  label: s.bookedSlot,
                  value: bookedSlot.timeRange,
                ),
                const Divider(height: 16, color: AppColors.borderSubtle),
                _SuccessRow(label: s.date, value: AppFormatters.formatDate(bookedSlot.date)),
                const Divider(height: 16, color: AppColors.borderSubtle),
                _SuccessRow(label: 'Gate', value: bookedSlot.gate),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            s.tokenDetails,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfacePaleGreen,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.confirmation_number_outlined,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.yourTokenNumber,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  booking.tokenNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onTrackQueue,
            icon: const Icon(Icons.queue_rounded),
            label: Text(s.trackLiveQueue),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onDone,
            child: Text(
              s.goToDashboard,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  final S s;
  final String message;
  final bool isPermissionError;
  final VoidCallback onRetry;
  final VoidCallback onGrantPermission;
  final VoidCallback onOpenSettings;
  final VoidCallback onManual;

  const _ErrorPanel({
    required this.s,
    required this.message,
    required this.isPermissionError,
    required this.onRetry,
    required this.onGrantPermission,
    required this.onOpenSettings,
    required this.onManual,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Icon(
          Icons.mic_off_rounded,
          size: 64,
          color: AppColors.statusWarning,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
        ),
        const Spacer(),
        if (isPermissionError) ...[
          ElevatedButton.icon(
            onPressed: onGrantPermission,
            icon: const Icon(Icons.mic_rounded),
            label: Text(s.grantMicPermission),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onOpenSettings,
            icon: const Icon(Icons.settings_rounded),
            label: Text(s.openSettings),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
          ),
        ] else ...[
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.mic_rounded),
            label: Text(s.tryAgain),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
        ],
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: onManual,
          icon: const Icon(Icons.touch_app_rounded),
          label: Text(s.tryManualBooking),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SuccessRow extends StatelessWidget {
  final String label;
  final String value;

  const _SuccessRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}