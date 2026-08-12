import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// The home search field with a trailing filter (tune) affordance.
///
/// Presentational for Phase 3 — a dedicated search screen is wired later.
/// [onTap] / [onFilterTap] are optional hooks.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key, this.onTap, this.onFilterTap});

  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: AppDimensions.borderRadiusXl,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.borderRadiusXl,
        child: Container(
          height: AppDimensions.inputHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: AppDimensions.borderRadiusXl,
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Row(
            children: <Widget>[
              const Icon(Icons.search, color: AppColors.outline, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ابحث عن أحدث التصاميم...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.outline.withOpacity(0.7),
                  ),
                ),
              ),
              IconButton(
                onPressed: onFilterTap,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.tune, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
