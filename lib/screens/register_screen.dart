import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/constants.dart';
import '../app/localizations.dart';
import '../app/routes.dart';
import '../models/registration_data.dart';
import '../providers/auth_provider.dart';
import '../services/aadhaar_ocr_service.dart';
import '../utils/aadhaar_validator.dart';
import '../utils/validators.dart';
import '../widgets/aadhaar_scanner_button.dart';
import '../widgets/app_logo.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import 'aadhaar_scanner_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String? initialMobile;

  const RegisterScreen({super.key, this.initialMobile});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _aadhaarController;
  late final TextEditingController _nameController;
  late final TextEditingController _dobController;
  late final TextEditingController _mobileController;
  late final TextEditingController _passwordController;
  late final TextEditingController _emailController;
  final _aadhaarFocusNode = FocusNode();
  String _rawAadhaar = '';
  bool _maskAadhaar = true;
  bool _obscurePassword = true;
  bool _hasScannedAadhaar = false;

  @override
  void initState() {
    super.initState();
    _aadhaarController = TextEditingController();
    _nameController = TextEditingController();
    _dobController = TextEditingController();
    _mobileController = TextEditingController(
      text: widget.initialMobile != null ? Validators.sanitizeMobile(widget.initialMobile!) : '',
    );
    _passwordController = TextEditingController();
    _emailController = TextEditingController();
    _aadhaarFocusNode.addListener(_handleAadhaarFocusChange);
  }

  void _handleAadhaarFocusChange() {
    if (!_aadhaarFocusNode.hasFocus) {
      if (_rawAadhaar.length == 12 && _maskAadhaar) {
        _aadhaarController.text = AadhaarValidator.formatMasked(_rawAadhaar);
      }
    } else {
      if (_rawAadhaar.length == 12 && _aadhaarController.text.contains('X')) {
        _aadhaarController.text = _rawAadhaar;
      }
    }
  }

  @override
  void dispose() {
    _aadhaarController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _aadhaarFocusNode.removeListener(_handleAadhaarFocusChange);
    _aadhaarFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleScanAadhaar() async {
    final scanResult = await Navigator.push<AadhaarScanResult>(
      context,
      MaterialPageRoute(
        builder: (context) => const AadhaarScannerScreen(),
      ),
    );

    if (scanResult != null && mounted) {
      final clean = AadhaarValidator.normalize(scanResult.aadhaarNumber);
      setState(() {
        _rawAadhaar = clean;
        _maskAadhaar = true;
        _hasScannedAadhaar = true;
        _aadhaarController.text = AadhaarValidator.formatMasked(clean);
        if (scanResult.isNameDetected && scanResult.name != null) {
          _nameController.text = scanResult.name!;
        }
        if (scanResult.isDobDetected && scanResult.dob != null) {
          _dobController.text = scanResult.dob!;
        }
      });
      _formKey.currentState?.validate();
    }
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;

    final cleanAadhaar = _rawAadhaar.isNotEmpty
        ? _rawAadhaar
        : AadhaarValidator.normalize(_aadhaarController.text.trim());

    final regData = RegistrationData(
      aadhaar: cleanAadhaar,
      name: _nameController.text.trim(),
      dob: _dobController.text.trim(),
      mobile: _mobileController.text.trim(),
      password: _passwordController.text,
      email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
    );

    Navigator.pushNamed(
      context,
      AppRoutes.otp,
      arguments: regData,
    );
  }

  void _handleContinueWithOtp() {
    final phone = _mobileController.text.trim();
    if (phone.isEmpty) {
      final s = S.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.pleaseEnterMobile),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.otp,
      arguments: phone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: AppLogo(size: 64)),
                  const SizedBox(height: 16),
                  Text(
                    s.createAccount,
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
                    s.registerSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Aadhaar Number (at the top)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.aadhaarNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        s.onDeviceOcr,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _aadhaarController,
                    focusNode: _aadhaarFocusNode,
                    keyboardType: TextInputType.number,
                    maxLength: 14,
                    validator: (val) {
                      final candidate = _rawAadhaar.isNotEmpty ? _rawAadhaar : val;
                      final err = AadhaarValidator.validateFormat(candidate);
                      return err == null ? null : s.translateValidation(err);
                    },
                    onChanged: (val) {
                      final clean = AadhaarValidator.normalize(val);
                      _rawAadhaar = clean;
                    },
                    decoration: InputDecoration(
                      hintText: 'XXXX XXXX 1234',
                      counterText: '',
                      prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.textSecondary),
                      suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_aadhaarController.text.isNotEmpty)
                            IconButton(
                              icon: Icon(
                                _maskAadhaar ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                              tooltip: _maskAadhaar ? s.showFullNumber : s.hideNumber,
                              onPressed: () {
                                setState(() {
                                  _maskAadhaar = !_maskAadhaar;
                                  if (_rawAadhaar.isNotEmpty) {
                                    _aadhaarController.text = _maskAadhaar
                                        ? AadhaarValidator.formatMasked(_rawAadhaar)
                                        : AadhaarValidator.formatGrouped(_rawAadhaar);
                                  }
                                });
                              },
                            ),
                          AadhaarScannerButton(
                            onPressed: _handleScanAadhaar,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          s.aadhaarPrivacyNote,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Scan success banner
                  if (_hasScannedAadhaar) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfacePaleGreen,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s.aadhaarDetected,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Full Name
                  Text(
                    s.fullName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    validator: (value) {
                      final err = Validators.validateFullName(value);
                      return err == null ? null : s.translateValidation(err);
                    },
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: s.hintFullName,
                      prefixIcon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date of Birth
                  Text(
                    s.dateOfBirth,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _dobController,
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      final err = Validators.validateDob(value);
                      return err == null ? null : s.translateValidation(err);
                    },
                    decoration: const InputDecoration(
                      hintText: 'DD/MM/YYYY',
                      prefixIcon: Icon(Icons.cake_outlined, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mobile Number
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        child: const Text(
                          '+91',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password
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
                      hintText: s.createPasswordHint,
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
                  const SizedBox(height: 16),

                  // Email (Optional)
                  Text(
                    s.emailOptional,
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
                    validator: (value) {
                      final err = Validators.validateEmail(value);
                      return err == null ? null : s.translateValidation(err);
                    },
                    decoration: const InputDecoration(
                      hintText: 'example@gmail.com',
                      prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    text: s.next,
                    isLoading: authProvider.isLoading,
                    onPressed: _handleNext,
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    text: s.continueWithOtp,
                    icon: Icons.sms_outlined,
                    onPressed: _handleContinueWithOtp,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          s.alreadyRegistered,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, AppRoutes.login);
                        },
                        child: Text(
                          s.login,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
