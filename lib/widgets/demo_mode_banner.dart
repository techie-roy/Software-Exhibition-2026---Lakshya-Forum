import 'package:flutter/material.dart';

import '../app/constants.dart';
import '../app/localizations.dart';

/// Clear, always-on label disclosing what is simulated in the credential/OTP
/// sign-in paths, so demo acceptance is never presented to the user as real
/// authentication.
///
/// Two honest states, no third:
/// * [realOtpVerification] = false (default, and whenever Firebase is not
///   configured): the mobile-number + password AND OTP paths are simulated —
///   any password / any 6-digit OTP is accepted for demonstration.
/// * [realOtpVerification] = true: OTP verification runs real Firebase Phone
///   Auth (Google sends the SMS), but password sign-in is STILL simulated
///   (there is no password backend) — that remains disclosed.
///
/// The default parameters render the demo disclosure, so the banner never
/// depends on a provider being present (see demo_mode_banner_test). What it
/// must never do is hide disclosure entirely on Firebase-configured builds.
class DemoModeBanner extends StatelessWidget {
  const DemoModeBanner({super.key, this.realOtpVerification = false});

  /// True when OTP verification uses real Firebase Phone Authentication.
  final bool realOtpVerification;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.statusWarningBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: AppColors.statusWarning),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.science_outlined, color: AppColors.statusWarning),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  realOtpVerification ? s.demoModeTitleReal : s.demoModeTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  realOtpVerification ? s.demoModeBodyReal : s.demoModeBody,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
