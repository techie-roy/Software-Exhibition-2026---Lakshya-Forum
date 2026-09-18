import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/constants.dart';
import '../app/localizations.dart';
import '../models/queue.dart';
import '../providers/queue_provider.dart';
import '../utils/formatters.dart';
import '../widgets/info_card.dart';
import '../widgets/status_badge.dart';

class QueueTrackingScreen extends StatefulWidget {
  const QueueTrackingScreen({super.key});

  @override
  State<QueueTrackingScreen> createState() => _QueueTrackingScreenState();
}

class _QueueTrackingScreenState extends State<QueueTrackingScreen>
    with SingleTickerProviderStateMixin {
  static const int _refreshIntervalSeconds = 30;

  Timer? _countdownTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _countdown = _refreshIntervalSeconds;
  bool _isAutoRefreshing = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_countdown <= 1) {
        _onAutoRefresh();
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
  }

  Future<void> _onAutoRefresh() async {
    final provider = context.read<QueueProvider>();
    if (provider.isRefreshing) return;

    setState(() {
      _countdown = _refreshIntervalSeconds;
    });
    if (!_isAutoRefreshing) {
      _isAutoRefreshing = true;
      await provider.refreshQueue();
      _isAutoRefreshing = false;
    }
  }

  Future<void> _onManualRefresh() async {
    setState(() {
      _countdown = _refreshIntervalSeconds;
    });
    await context.read<QueueProvider>().refreshQueue();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queueProvider = context.watch<QueueProvider>();
    final queue = queueProvider.queueData;
    final s = S.of(context);

    final lastUpdatedText = AppFormatters.formatLiveTime(
      queueProvider.lastUpdated,
    );

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(s.liveMandiQueue),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 10, bottom: 10),
            child: _LiveIndicator(animation: _pulseAnimation),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoftMint,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.sync_rounded,
                      size: 16,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        queueProvider.isRefreshing
                            ? s.fetchingLiveData
                            : s.refreshingInSeconds(_countdown),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (!queueProvider.isRefreshing)
                      Text(
                        '${s.lastUpdated}: $lastUpdatedText',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    IconButton(
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.primaryGreen,
                      ),
                      tooltip: s.refresh,
                      onPressed: queueProvider.isRefreshing
                          ? null
                          : _onManualRefresh,
                    ),
                  ],
                ),
              ),
              if (queueProvider.isRefreshing) ...[
                const SizedBox(height: 6),
                const LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: AppColors.borderSubtle,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryGreen,
                  ),
                ),
              ],
              if (queueProvider.errorMessage != null) ...[
                const SizedBox(height: 6),
                InkWell(
                  onTap: _onManualRefresh,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.statusAlertBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.statusAlert),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 16,
                          color: AppColors.statusAlert,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.queueRefreshError,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                s.tapToRetry,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),

              InfoCard(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.yourLiveToken.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                queue.tokenNumber,
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryGreen,
                                  letterSpacing: 1.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfacePaleGreen,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.primaryGreen.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                s.assignedGate,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                queue.gate,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        s.cropName(queue.crop),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AppColors.borderSubtle),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _QueueMetricTile(
                            icon: Icons.people_alt_outlined,
                            label: s.farmersAhead,
                            value: '${queue.farmersAhead}',
                            color: AppColors.primaryLight,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QueueMetricTile(
                            icon: Icons.hourglass_top_rounded,
                            label: s.estimatedWait,
                            value: queue.formattedWaitTime,
                            color: AppColors.statusWarning,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Text(
                  s.procurementTimeline,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              InfoCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  children: List.generate(queue.steps.length, (index) {
                    final step = queue.steps[index];
                    final isLast = index == queue.steps.length - 1;

                    return _TimelineStepItem(step: step, isLast: isLast);
                  }),
                ),
              ),
              const SizedBox(height: 20),

              InfoCard(
                backgroundColor: AppColors.surfaceSoftMint,
                borderColor: AppColors.borderSubtle,
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.checklist_rounded,
                          size: 20,
                          color: AppColors.primaryGreen,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          s.beforeEnteringGate,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _ChecklistPoint(text: s.originalAadhaar),
                    const SizedBox(height: 8),
                    _ChecklistPoint(text: s.bankPassbook),
                    const SizedBox(height: 8),
                    _ChecklistPoint(text: s.landRecord),
                    const SizedBox(height: 8),
                    _ChecklistPoint(text: s.grainSample),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveIndicator extends StatelessWidget {
  final Animation<double> animation;

  const _LiveIndicator({required this.animation});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.statusAlertBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.statusAlert),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: animation,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.statusAlert,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            s.liveBadge,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.statusAlert,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueMetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _QueueMetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStepItem extends StatelessWidget {
  final QueueStep step;
  final bool isLast;

  const _TimelineStepItem({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final title = s.translate(step.titleKey);
    final description = s.translate(step.descriptionKey);
    Widget indicator;
    if (step.isCompleted) {
      indicator = Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: AppColors.primaryGreen,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 16, color: Colors.white),
      );
    } else if (step.isCurrent) {
      indicator = Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.surfacePaleGreen,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryGreen, width: 2.5),
        ),
        child: Center(
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    } else {
      indicator = Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderSubtle, width: 2),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            indicator,
            if (!isLast)
              Container(
                width: 2,
                height: 38,
                color: step.isCompleted
                    ? AppColors.primaryGreen
                    : AppColors.borderSubtle,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: step.isCurrent
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: step.isCurrent
                              ? AppColors.primaryGreen
                              : step.isCompleted
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (step.time != null)
                      Text(
                        step.time!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      )
                    else if (step.isCurrent)
                      StatusBadge(label: s.now, type: BadgeType.success),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (!isLast) const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChecklistPoint extends StatelessWidget {
  final String text;

  const _ChecklistPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 16,
          color: AppColors.primaryGreen,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
