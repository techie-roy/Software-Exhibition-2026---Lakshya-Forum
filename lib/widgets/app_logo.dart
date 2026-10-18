import 'package:flutter/material.dart';

import '../app/constants.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showBadgeOnly;

  const AppLogo({super.key, this.size = 64, this.showBadgeOnly = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfacePaleGreen,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.agriculture_rounded,
          size: size * 0.58,
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }
}
