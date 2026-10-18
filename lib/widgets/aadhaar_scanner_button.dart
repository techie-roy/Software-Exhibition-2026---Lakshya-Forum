import 'package:flutter/material.dart';

import '../app/constants.dart';
import '../app/localizations.dart';

/// A styled scan button for Aadhaar scanning that seamlessly matches AgriQueue's design system.
class AadhaarScannerButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isCompact;

  const AadhaarScannerButton({
    super.key,
    required this.onPressed,
    this.isCompact = true,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    if (isCompact) {
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfacePaleGreen,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  size: 18,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: 4),
                Text(
                  s.scan,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.document_scanner_outlined, size: 20),
      label: Text(s.scanAadhaarCard),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        side: const BorderSide(color: AppColors.primaryGreen, width: 1.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
