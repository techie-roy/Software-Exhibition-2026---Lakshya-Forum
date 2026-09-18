import 'package:flutter/material.dart';

class AppColors {
  // Primary Greens
  static const Color primaryGreen = Color(0xFF1B5E20); // Deep agricultural green
  static const Color primaryLight = Color(0xFF2E7D32);
  static const Color primaryDark = Color(0xFF0F3E13);

  // Soft Surface Greens
  static const Color surfacePaleGreen = Color(0xFFE8F5E9); // Pale green background surface
  static const Color surfaceSoftMint = Color(0xFFF1F8F3);
  static const Color badgeGreenBg = Color(0xFFDFF0E2);
  static const Color badgeGreenText = Color(0xFF1B5E20);

  // Backgrounds
  static const Color scaffoldBackground = Color(0xFFF8FAF8); // Crisp off-white agricultural bg
  static const Color cardBackground = Colors.white;

  // Status Colors
  static const Color statusActive = Color(0xFF2E7D32);
  static const Color statusWarning = Color(0xFFE65100);
  static const Color statusWarningBg = Color(0xFFFFF3E0);
  static const Color statusAlert = Color(0xFFC62828);
  static const Color statusAlertBg = Color(0xFFFFEBEE);
  static const Color statusPending = Color(0xFF5C6BC0);
  static const Color statusPendingBg = Color(0xFFEDE7F6);

  // Borders & Dividers
  static const Color borderSubtle = Color(0xFFE2E8E2);
  static const Color borderSelected = Color(0xFF2E7D32);

  // Neutrals & Typography
  static const Color textPrimary = Color(0xFF1A231C);
  static const Color textSecondary = Color(0xFF5C6B5F);
  static const Color textMuted = Color(0xFF8A9A8D);
  static const Color textHint = Color(0xFFA6B5A9);
}

class AppDimensions {
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 20.0;
  static const double paddingXLarge = 24.0;
}

class AppShadows {
  static final List<BoxShadow> softCard = [
    const BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.03),
      blurRadius: 10,
      offset: Offset(0, 3),
      spreadRadius: 0,
    ),
  ];

  static final List<BoxShadow> elevatedCard = [
    const BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.06),
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
}
