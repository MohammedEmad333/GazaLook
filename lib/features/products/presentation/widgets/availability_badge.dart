import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Local availability badge shown on the PDP.
///
/// In stock → store + Gaza delivery window; out of stock → a clear red state.
class AvailabilityBadge extends StatelessWidget {
  const AvailabilityBadge({
    super.key,
    required this.inStock,
    this.storeName,
  });

  final bool inStock;
  final String? storeName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!inStock) {
      return _Pill(
        icon: Icons.remove_shopping_cart_outlined,
        iconColor: AppColors.error,
        background: AppColors.errorContainer.withOpacity(0.4),
        child: Text(
          'غير متوفر حالياً',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.onErrorContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return _Pill(
      icon: Icons.storefront,
      iconColor: AppColors.secondary,
      background: AppColors.secondaryContainer.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'متوفر — التوصيل خلال 24-48 ساعة في غزة',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (storeName != null && storeName!.isNotEmpty)
            Text(
              storeName!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.iconColor,
    required this.background,
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.componentPadding,
        vertical: AppDimensions.stackBase,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppDimensions.borderRadiusLg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: AppDimensions.stackBase),
          Flexible(child: child),
        ],
      ),
    );
  }
}
