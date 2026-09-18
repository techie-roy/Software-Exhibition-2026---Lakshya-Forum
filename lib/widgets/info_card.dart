import 'package:flutter/material.dart';
import '../app/constants.dart';

class InfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final double borderRadius;
  final List<BoxShadow>? shadows;

  const InfoCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.borderRadius = AppDimensions.radiusLarge,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: BorderSide(
        color: borderColor ?? AppColors.borderSubtle,
        width: 1.0,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows ?? AppShadows.softCard,
      ),
      child: Material(
        color: backgroundColor ?? AppColors.cardBackground,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppDimensions.paddingMedium),
            child: child,
          ),
        ),
      ),
    );
  }
}
