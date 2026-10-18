import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/constants.dart';
import '../app/localizations.dart';
import '../app/routes.dart';
import '../models/registration_data.dart';
import '../providers/auth_provider.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';
import '../widgets/app_logo.dart';
import '../widgets/demo_mode_banner.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

class OtpScreen extends StatefulWidget {
  final String mobileNumber;
  final RegistrationData? registrationData;

  const OtpScreen({
    super.key,
    required this.mobileNumber,
    this.registrationData,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _digitControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isRegistered = false;
  int _redirectCountdown = 10;
  Timer? _redirectTimer;

  int _resendCountdown = 30;
  Timer? _resendTimer;
  bool _canResend = false;

  bool get _isRegistrationFlow => widget.registrationData != null;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _isRegistered = authProvider.isMobileRegistered(widget.mobileNumber);

    if (_isRegistrationFlow) {
      // The register screen already awaited the real OTP send (or the demo
      // no-op) before navigating here; the Resend button covers retries.
      _startResendTimer();
    } else if (_isRegistered) {
      _startResendTimer();
      if (authProvider.isPhoneAuthAvailable) {
        // Real Firebase Phone Auth: request the SMS as soon as the login
        // OTP screen opens (same entry points as before: auth/register
        // "Continue with OTP").
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _sendOtp();
        });
      } else {
        // Disclosed demo path: prefill the well-known demo code so manual
        // typing isn't needed when no SMS exists.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          const mockCode = '123456';
          for (int i = 0; i < 6; i++) {
            _digitControllers[i].text = mockCode[i];
          }
        });
      }
    } else {
      _startRedirectCountdown();
    }
  }

  Future<void> _sendOtp() async {
    final authProvider = context.read<AuthProvider>();
    final ok = await authProvider.sendOtp(
      widget.mobileNumber,
      forRegistration: _isRegistrationFlow,
    );
    if (!mounted || ok) return;
    final s = S.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(authProvider.errorMessage ?? s.otpSendFailed),
        backgroundColor: AppColors.statusAlert,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startRedirectCountdown() {
    _redirectCountdown = 10;
    _redirectTimer?.cancel();
    _redirectTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_redirectCountdown > 1) {
        setState(() {
          _redirectCountdown--;
        });
      } else {
        timer.cancel();
        _goToRegister();
      }
    });
  }

  void _startResendTimer() {
    setState(() {
      _resendCountdown = 30;
      _canResend = false;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCountdown > 1) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  void _goToRegister() {
    _redirectTimer?.cancel();
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.register,
      arguments: widget.mobileNumber,
    );
  }

  void _verifyOtp() async {
    final otp = _digitControllers.map((c) => c.text).join();
    final s = S.of(context);
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.enterAllDigits),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();

    if (_isRegistrationFlow) {
      final otpValid = await authProvider.confirmOtp(
        widget.mobileNumber,
        otp,
        forRegistration: true,
      );
      if (!mounted) return;

      if (!otpValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? s.invalidOtp),
            backgroundColor: AppColors.statusAlert,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final data = widget.registrationData!;
      final success = await authProvider.completeRegistration(
        name: data.name,
        phone: data.mobile,
        password: data.password,
        aadhaar: data.aadhaar,
        dob: data.dob,
        email: data.email,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.accountCreated),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.main,
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? s.registrationFailed),
            backgroundColor: AppColors.statusAlert,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      final success = await authProvider.confirmOtp(
        widget.mobileNumber,
        otp,
        forRegistration: false,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.main,
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? s.invalidOtp),
            backgroundColor: AppColors.statusAlert,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    _resendTimer?.cancel();
    for (var c in _digitControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Widget _buildOtpInput() {
    final authProvider = context.watch<AuthProvider>();
    final masked = AppFormatters.maskPhone(widget.mobileNumber);
    final s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        const Center(child: AppLogo(size: 64)),
        const SizedBox(height: 20),
        Text(
          s.verifyMobile,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          s.otpSentTo(masked),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 46,
              height: 54,
              child: TextFormField(
                controller: _digitControllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.borderSubtle,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.primaryGreen,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    _focusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        Center(
          child: _canResend
              ? TextButton(
                  onPressed: () {
                    _startResendTimer();
                    _sendOtp();
                  },
                  child: Text(
                    s.resendOtp,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                )
              : Text(
                  s.resendIn(_resendCountdown),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
        const SizedBox(height: 28),
        PrimaryButton(
          text: s.verifyContinue,
          isLoading: authProvider.isLoading,
          onPressed: _verifyOtp,
        ),
        const SizedBox(height: 12),
        SecondaryButton(
          text: s.changeMobile,
          onPressed: () {
            _redirectTimer?.cancel();
            _resendTimer?.cancel();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildUnregisteredView() {
    final cleanPhone = Validators.sanitizeMobile(widget.mobileNumber);
    final s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 30),
        Center(
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.statusWarningBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.statusWarning.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.person_search_outlined,
                size: 40,
                color: AppColors.statusWarning,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          s.mobileNotRegistered,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          s.notRegisteredDesc(cleanPhone),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: AppShadows.softCard,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      s.redirectingTo(_redirectCountdown),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$_redirectCountdown...',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          text: s.registerNow,
          icon: Icons.person_add_outlined,
          onPressed: _goToRegister,
        ),
        const SizedBox(height: 12),
        SecondaryButton(
          text: s.tryAnother,
          onPressed: () {
            _redirectTimer?.cancel();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            _redirectTimer?.cancel();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Always label the auth path, in every build mode: simulated
              // demo copy vs. real-Firebase-OTP copy.
              DemoModeBanner(
                realOtpVerification: authProvider.isPhoneAuthAvailable,
              ),
              _isRegistrationFlow
                  ? _buildOtpInput()
                  : (_isRegistered
                        ? _buildOtpInput()
                        : _buildUnregisteredView()),
            ],
          ),
        ),
      ),
    );
  }
}
