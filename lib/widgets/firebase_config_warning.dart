import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/constants.dart';
import '../providers/auth_provider.dart';

/// Release-only warning shown when Firebase failed to initialize.
///
/// Debug builds and widget tests intentionally stay quiet (mock/OTP mode is
/// expected there), but a release build must never *silently* fall back to
/// mock authentication — so this banner is loud and always visible until
/// Firebase is configured.
class FirebaseConfigWarning extends StatelessWidget {
  const FirebaseConfigWarning({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kReleaseMode) return const SizedBox.shrink();
    final available = context.select<AuthProvider, bool>(
      (a) => a.isFirebaseAvailable,
    );
    if (available) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.statusAlertBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: AppColors.statusAlert),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.statusAlert),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Firebase is not configured in this build. '
              'Online (email) sign-in is unavailable — showing mock mode. '
              'Contact the developer.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
