import 'package:flutter/material.dart';
import '../app/constants.dart';

enum BadgeType {
  success,
  warning,
  danger,
  neutral,
  info,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = BadgeType.success,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;

    switch (type) {
      case BadgeType.success:
        bg = AppColors.badgeGreenBg;
        text = AppColors.badgeGreenText;
        break;
      case BadgeType.warning:
        bg = AppColors.statusWarningBg;
        text = AppColors.statusWarning;
        break;
      case BadgeType.danger:
        bg = AppColors.statusAlertBg;
        text = AppColors.statusAlert;
        break;
      case BadgeType.neutral:
        bg = const Color(0xFFEEEEEE);
        text = AppColors.textSecondary;
        break;
      case BadgeType.info:
        bg = AppColors.statusPendingBg;
        text = AppColors.statusPending;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: text),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: text,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
