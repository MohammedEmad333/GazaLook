import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography scale for GazaLook.
///
/// Two families, matching the mock-ups:
///   * **Montserrat** — display / headline (bold, tight tracking).
///   * **Inter**      — body / labels (clean, highly legible at small sizes).
///
/// The `.ttf` assets are declared (commented) in `pubspec.yaml`. Until they are
/// bundled Flutter falls back to the platform default, so the app still renders
/// correctly during early development.
abstract final class AppTypography {
  const AppTypography._();

  static const String displayFont = 'Montserrat';
  static const String bodyFont = 'Inter';

  /// Full [TextTheme] wired into [ThemeData]. Colour defaults to
  /// [AppColors.onSurface]; individual widgets override per context.
  static TextTheme get textTheme => const TextTheme(
        // display-lg — 32/40, -0.02em, 700
        displayLarge: TextStyle(
          fontFamily: displayFont,
          fontSize: 32,
          height: 40 / 32,
          letterSpacing: -0.64,
          fontWeight: FontWeight.w700,
          color: AppColors.onBackground,
        ),
        // display-lg-mobile — 24/30, 700
        displayMedium: TextStyle(
          fontFamily: displayFont,
          fontSize: 24,
          height: 30 / 24,
          fontWeight: FontWeight.w700,
          color: AppColors.onBackground,
        ),
        // headline-md — 20/28, 600
        headlineMedium: TextStyle(
          fontFamily: displayFont,
          fontSize: 20,
          height: 28 / 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        // headline-md as a section title (reused as titleLarge)
        titleLarge: TextStyle(
          fontFamily: displayFont,
          fontSize: 20,
          height: 28 / 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        // body-lg — 16/24, 400
        bodyLarge: TextStyle(
          fontFamily: bodyFont,
          fontSize: 16,
          height: 24 / 16,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
        ),
        // body-sm — 14/20, 400
        bodyMedium: TextStyle(
          fontFamily: bodyFont,
          fontSize: 14,
          height: 20 / 14,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
        ),
        // supporting caption
        bodySmall: TextStyle(
          fontFamily: bodyFont,
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurfaceVariant,
        ),
        // label-uppercase — 12/16, +0.05em, 600
        labelLarge: TextStyle(
          fontFamily: bodyFont,
          fontSize: 12,
          height: 16 / 12,
          letterSpacing: 0.6,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        labelMedium: TextStyle(
          fontFamily: bodyFont,
          fontSize: 12,
          height: 16 / 12,
          letterSpacing: 0.6,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurfaceVariant,
        ),
      );
}
