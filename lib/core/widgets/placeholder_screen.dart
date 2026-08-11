import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_dimensions.dart';

/// A temporary, theme-aware placeholder used while feature screens are built
/// out phase-by-phase. It exists so routing and the overall shell can be
/// exercised end-to-end before the real UI lands.
///
/// Replace usages of this widget as each phase delivers its screens.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    this.icon = Icons.storefront_outlined,
    this.message = 'قيد الإنشاء',
  });

  final String title;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(AppConstants.appName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.sectionGap),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: AppDimensions.stackBase),
              Text(title, style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppDimensions.stackTight),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
