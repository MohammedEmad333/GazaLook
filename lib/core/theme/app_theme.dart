import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_typography.dart';

/// The single source of truth for GazaLook's visual style.
///
/// Exposes [AppTheme.light] (the primary, Shein-like light experience). A dark
/// variant can be layered later; the mock-ups declare `darkMode: "class"` but
/// the shipped design is light-first, so we ship light now and keep the API
/// ready for dark.
///
/// Design language: warm light background, muted rose primary accent, generous
/// 12px rounded corners on cards/buttons/inputs, soft shadows, clean type.
abstract final class AppTheme {
  const AppTheme._();

  /// Light theme — the app's default and primary appearance.
  static ThemeData get light {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      surfaceDim: AppColors.surfaceDim,
      surfaceBright: AppColors.surfaceBright,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.inverseOnSurface,
      inversePrimary: AppColors.inversePrimary,
      surfaceTint: AppColors.surfaceTint,
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
    );

    final textTheme = AppTypography.textTheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppTypography.bodyFont,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,

      // -----------------------------------------------------------------------
      // App bar — flat, surface-tinted, centered wordmark.
      // -----------------------------------------------------------------------
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.headlineMedium?.copyWith(
          color: AppColors.primary,
        ),
        iconTheme: const IconThemeData(color: AppColors.onSurfaceVariant),
      ),

      // -----------------------------------------------------------------------
      // Cards — rounded 12px, soft shadow, lowest surface.
      // -----------------------------------------------------------------------
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusXl,
          side: BorderSide(color: AppColors.outlineVariant.withOpacity(0.2)),
        ),
      ),

      // -----------------------------------------------------------------------
      // Buttons — pill-adjacent 12px radius, 48px tall CTAs.
      // -----------------------------------------------------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimaryContainer,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          elevation: 0,
          textStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusXl,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusXl,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          side: const BorderSide(color: AppColors.outlineVariant),
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusXl,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),

      // -----------------------------------------------------------------------
      // Inputs — filled white field, 12px radius, focus ring in secondary.
      // -----------------------------------------------------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.containerMargin,
          vertical: AppDimensions.componentPadding,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.outline.withOpacity(0.7),
        ),
        border: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusXl,
          borderSide: const BorderSide(color: AppColors.surfaceVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusXl,
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusXl,
          borderSide: const BorderSide(
            color: AppColors.secondaryContainer,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusXl,
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),

      // -----------------------------------------------------------------------
      // Chips — filter chips (Women / Men / Kids / Offers).
      // -----------------------------------------------------------------------
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainer,
        selectedColor: AppColors.primaryContainer,
        labelStyle: textTheme.labelLarge,
        secondaryLabelStyle: textTheme.labelLarge,
        side: BorderSide(color: AppColors.outlineVariant.withOpacity(0.4)),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // -----------------------------------------------------------------------
      // Bottom navigation — translucent surface, primary-container active pill.
      // -----------------------------------------------------------------------
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.onPrimaryContainer,
        unselectedItemColor: AppColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // -----------------------------------------------------------------------
      // Bottom sheets — used for the size guide etc.
      // -----------------------------------------------------------------------
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXl),
          ),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.outlineVariant.withOpacity(0.3),
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.inverseOnSurface,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusLg,
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
    );
  }
}
