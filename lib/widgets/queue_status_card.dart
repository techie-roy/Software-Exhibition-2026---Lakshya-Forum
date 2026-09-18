import 'package:flutter/material.dart';

import '../app/constants.dart';
import '../app/localizations.dart';
import '../services/mock_data_service.dart';
import 'info_card.dart';
import 'status_badge.dart';

class GateCrowdCard extends StatelessWidget {
  final MandiGateStatus status;

  const GateCrowdCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final isHigh = status.isHighCrowd;
    final barColor = isHigh ? AppColors.statusWarning : AppColors.primaryGreen;

    return InfoCard(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${status.gateName} • ${s.cropName(status.crop)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              StatusBadge(
                label: s.gateStatusName(status.statusText),
                type: isHigh ? BadgeType.warning : BadgeType.success,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${status.currentCount} / ${status.totalCapacity} ${s.farmers}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(status.progress * 100).toInt()}% ${s.capacity}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: status.progress,
              minHeight: 8,
              backgroundColor: AppColors.borderSubtle,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
