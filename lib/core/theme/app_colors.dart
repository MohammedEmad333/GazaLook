import 'package:flutter/material.dart';

/// Centralised colour palette for GazaLook.
///
/// Values are lifted 1:1 from the design mock-ups (Material 3 token names) so
/// the Flutter UI matches the approved Shein-like aesthetic: a light,
/// warm-neutral background with a muted rose/mauve primary accent.
///
/// Keep raw [Color] literals here only — never scatter hex values across
/// widgets. Widgets should read colours from `Theme.of(context).colorScheme`
/// wherever possible, falling back to these named constants for the few
/// bespoke tokens Material's [ColorScheme] does not model.
abstract final class AppColors {
  const AppColors._();

  // ---------------------------------------------------------------------------
  // Primary
  // ---------------------------------------------------------------------------
  static const Color primary = Color(0xFF805253);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFE9AFAF);
  static const Color onPrimaryContainer = Color(0xFF6C4141);
  static const Color primaryFixed = Color(0xFFFFDAD9);
  static const Color primaryFixedDim = Color(0xFFF3B8B8);
  static const Color inversePrimary = Color(0xFFF3B8B8);

  // ---------------------------------------------------------------------------
  // Secondary (warm sand / caramel accents)
  // ---------------------------------------------------------------------------
  static const Color secondary = Color(0xFF6E5B44);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFF8DFC0);
  static const Color onSecondaryContainer = Color(0xFF746149);

  // ---------------------------------------------------------------------------
  // Tertiary
  // ---------------------------------------------------------------------------
  static const Color tertiary = Color(0xFF6B5B50);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFCDBAAC);
  static const Color onTertiaryContainer = Color(0xFF584A3F);

  // ---------------------------------------------------------------------------
  // Background & surfaces
  // ---------------------------------------------------------------------------
  static const Color background = Color(0xFFFCF9F8);
  static const Color onBackground = Color(0xFF1B1C1C);
  static const Color surface = Color(0xFFFCF9F8);
  static const Color onSurface = Color(0xFF1B1C1C);
  static const Color onSurfaceVariant = Color(0xFF514443);

  static const Color surfaceDim = Color(0xFFDCD9D9);
  static const Color surfaceBright = Color(0xFFFCF9F8);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color surfaceContainer = Color(0xFFF0EDED);
  static const Color surfaceContainerHigh = Color(0xFFEAE7E7);
  static const Color surfaceContainerHighest = Color(0xFFE4E2E1);
  static const Color surfaceVariant = Color(0xFFE4E2E1);
  static const Color surfaceTint = Color(0xFF805253);

  static const Color inverseSurface = Color(0xFF303030);
  static const Color inverseOnSurface = Color(0xFFF3F0F0);

  // ---------------------------------------------------------------------------
  // Outline & error
  // ---------------------------------------------------------------------------
  static const Color outline = Color(0xFF837373);
  static const Color outlineVariant = Color(0xFFD5C2C2);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // ---------------------------------------------------------------------------
  // Semantic helpers (used by badges / availability chips)
  // ---------------------------------------------------------------------------
  /// "In stock" / positive availability accent.
  static const Color success = Color(0xFF6E5B44);

  /// Soft shadow used on cards and banners across the mock-ups
  /// (`0px 4px 20px rgba(0,0,0,0.04)`).
  static const Color cardShadow = Color(0x0A000000);
}
