import 'package:flutter/material.dart';

import '../app/constants.dart';
import '../app/localizations.dart';
import '../models/market_price.dart';
import '../utils/formatters.dart';
import 'info_card.dart';

class DashboardMarketPriceCard extends StatelessWidget {
  final MarketPrice price;
  final VoidCallback onViewAll;

  const DashboardMarketPriceCard({
    super.key,
    required this.price,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final isUp = price.trend == PriceTrend.up;
    final trendColor = isUp ? AppColors.primaryGreen : AppColors.statusAlert;
    final trendBg = isUp ? AppColors.badgeGreenBg : AppColors.statusAlertBg;
    final trendIcon = isUp
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;
    final changeText = '${isUp ? '↑ ' : '↓ '}${price.changePercentage.abs()}%';
    final s = context.s;

    return InfoCard(
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surfacePaleGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.trending_up_rounded,
                        size: 18,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        s.marketPriceToday,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trendBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(trendIcon, size: 12, color: trendColor),
                    const SizedBox(width: 2),
                    Text(
                      changeText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: trendColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.cropName(price.cropName),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          AppFormatters.formatCurrency(price.currentPrice),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '/ ${price.unit}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  _PriceRangePill(
                    label: s.min,
                    amount: AppFormatters.formatCurrency(price.minPrice),
                  ),
                  const SizedBox(width: 8),
                  _PriceRangePill(
                    label: s.max,
                    amount: AppFormatters.formatCurrency(price.maxPrice),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 12),
          InkWell(
            onTap: onViewAll,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    s.viewAllPrices,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppColors.primaryGreen,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRangePill extends StatelessWidget {
  final String label;
  final String amount;

  const _PriceRangePill({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class DetailedMarketPriceCard extends StatelessWidget {
  final MarketPrice price;

  const DetailedMarketPriceCard({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final isUp = price.trend == PriceTrend.up;
    final isDown = price.trend == PriceTrend.down;
    final trendColor = isUp
        ? AppColors.primaryGreen
        : isDown
        ? AppColors.statusAlert
        : AppColors.textSecondary;
    final trendBg = isUp
        ? AppColors.badgeGreenBg
        : isDown
        ? AppColors.statusAlertBg
        : const Color(0xFFEEEEEE);

    return InfoCard(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfacePaleGreen,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                ),
                child: Center(
                  child: Text(
                    s.cropName(price.cropName).characters.take(1).toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.cropName(price.cropName),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      s.categoryName(price.category),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatters.formatCurrency(price.currentPrice),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: trendBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${isUp
                          ? '↑ +'
                          : isDown
                          ? '↓ '
                          : ''}${price.changePercentage}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: trendColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _PriceStat(
                    title: s.minPrice,
                    val: AppFormatters.formatCurrency(price.minPrice),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PriceStat(
                    title: s.maxPrice,
                    val: AppFormatters.formatCurrency(price.maxPrice),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PriceStat(
                    title: s.govtMsp,
                    val: AppFormatters.formatCurrency(price.mspPrice),
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

class _PriceStat extends StatelessWidget {
  final String title;
  final String val;

  const _PriceStat({required this.title, required this.val});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
