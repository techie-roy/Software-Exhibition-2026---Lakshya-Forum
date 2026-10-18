import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/constants.dart';
import '../app/localizations.dart';
import '../app/routes.dart';
import '../providers/auth_provider.dart';
import '../services/google_auth_service.dart';
import '../utils/validators.dart';
import '../widgets/app_logo.dart';
import '../widgets/demo_mode_banner.dart';
import '../widgets/firebase_config_warning.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import 'language_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController(text: '9876543210');
  final _passwordController = TextEditingController(text: '123456');
  final _emailController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final authProvider = context.read<AuthProvider>();
    // Prevent repeated submissions while a request is in flight.
    if (authProvider.isLoading) return;

    final email = _emailController.text.trim();
    // Firebase email path: when an email is entered, validate email +
    // Firebase password rules and sign in with Firebase.
    if (email.isNotEmpty) {
      final emailErr = Validators.validateEmailRequired(_emailController.text);
      final passErr = Validators.validateFirebasePassword(
        _passwordController.text,
      );
      final s = S.of(context);
      if (emailErr != null || passErr != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.translateValidation(emailErr ?? passErr!)),
            backgroundColor: AppColors.statusAlert,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      final success = await authProvider.signInWithEmail(
        email: email,
        password: _passwordController.text,
      );
      if (!mounted) return;
      if (success) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      } else {
        final s2 = S.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? s2.invalidLogin),
            backgroundColor: AppColors.statusAlert,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final success = await authProvider.loginWithPassword(
      _mobileController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else {
      final s = S.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? s.invalidLogin),
          backgroundColor: AppColors.statusAlert,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isLoading) return;

    final status = await authProvider.signInWithGoogle();
    if (!mounted) return;
    final s = S.of(context);

    switch (status) {
      case GoogleAuthStatus.success:
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      case GoogleAuthStatus.canceled:
        // User dismissed the chooser: no error to show.
        return;
      case GoogleAuthStatus.unavailable:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.googleSignInUnavailable),
            backgroundColor: AppColors.statusAlert,
            behavior: SnackBarBehavior.floating,
          ),
        );
      case GoogleAuthStatus.failed:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? s.googleSignInFailed),
            backgroundColor: AppColors.statusAlert,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  void _handleContinueWithOtp() {
    final phone = _mobileController.text.trim();
    if (phone.isEmpty) {
      final s = S.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.otpHint), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    Navigator.pushNamed(context, AppRoutes.otp, arguments: phone);
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController(
      text: _emailController.text.trim(),
    );
    var isSending = false;
    String? dialogError;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final s = S.of(dialogContext);
          Future<void> sendReset() async {
            final email = emailController.text.trim();
            final err = Validators.validateEmailRequired(email);
            if (err != null) {
              setDialogState(() {
                dialogError = s.translateValidation(err);
              });
              return;
            }
            setDialogState(() {
              isSending = true;
              dialogError = null;
            });
            final authProvider = context.read<AuthProvider>();
            final ok = await authProvider.sendPasswordReset(email: email);
            if (!dialogContext.mounted) return;
            setDialogState(() {
              isSending = false;
            });
            if (ok) {
              Navigator.pop(dialogContext);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(s.resetEmailSent),
                  backgroundColor: AppColors.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else {
              setDialogState(() {
                dialogError = authProvider.errorMessage ?? s.invalidLogin;
              });
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            ),
            title: Row(
              children: [
                const Icon(Icons.help_outline, color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    s.resetViaEmailTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    s.resetViaEmailDesc,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: s.emailLoginHint,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.textSecondary,
                      ),
                      errorText: dialogError,
                    ),
                    onChanged: (_) {
                      if (dialogError != null) {
                        setDialogState(() {
                          dialogError = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.resetPasswordDesc,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSending
                    ? null
                    : () => Navigator.pop(dialogContext),
                child: Text(
                  s.close,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: isSending ? null : sendReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                child: isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(s.sendResetLink),
              ),
              TextButton(
                onPressed: isSending
                    ? null
                    : () {
                        Navigator.pop(dialogContext);
                        _handleContinueWithOtp();
                      },
                child: Text(s.useOtpInstead),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLarge,
              vertical: 24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Always label the auth path, in every build mode.
                  DemoModeBanner(
                    realOtpVerification: authProvider.isPhoneAuthAvailable,
                  ),
                  // Loud in release builds if Firebase failed to init.
                  const FirebaseConfigWarning(),
                  const Center(child: AppLogo(size: 68)),
                  const SizedBox(height: 20),
                  Text(
                    s.welcomeBack,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    s.mobileNumber,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    validator: (value) {
                      final err = Validators.validateMobile(value);
                      return err == null ? null : s.translateValidation(err);
                    },
                    decoration: InputDecoration(
                      hintText: '9876543210',
                      counterText: '',
                      prefixIcon: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        child: const Text(
                          '+91',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    s.password,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (value) {
                      final err = Validators.validatePassword(value);
                      return err == null ? null : s.translateValidation(err);
                    },
                    decoration: InputDecoration(
                      hintText: s.enterPasswordHint,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showForgotPasswordDialog,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        '${s.forgotPassword}?',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          s.orDivider,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    s.emailAddress,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: InputDecoration(
                      hintText: s.emailLoginHint,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.loginWithEmail,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    text: s.login,
                    isLoading: authProvider.isLoading,
                    onPressed: _handleLogin,
                  ),
                  if (authProvider.googleSignInAvailable) ...[
                    const SizedBox(height: 12),
                    GoogleSignInButton(
                      text: s.continueWithGoogle,
                      isLoading: authProvider.isLoading,
                      onPressed: _handleGoogleSignIn,
                    ),
                  ],
                  const SizedBox(height: 12),
                  SecondaryButton(
                    text: s.continueWithOtp,
                    icon: Icons.sms_outlined,
                    onPressed: _handleContinueWithOtp,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          s.noAccount,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                        child: Text(
                          s.register,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Language selection stays reachable from login
                  // (settings mode); first-launch selection is handled
                  // by the startup route.
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const LanguageScreen(isSettingsMode: true),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.language_outlined,
                        size: 18,
                        color: AppColors.primaryGreen,
                      ),
                      label: Text(
                        s.languageLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
