import 'package:flutter/widgets.dart';

/// Spacing, radius and sizing tokens shared across GazaLook.
///
/// These mirror the design system defined in the mock-ups (Tailwind spacing +
/// borderRadius scales) so layouts stay pixel-consistent with the approved UI.
abstract final class AppDimensions {
  const AppDimensions._();

  // ---------------------------------------------------------------------------
  // Spacing scale
  // ---------------------------------------------------------------------------
  static const double stackTight = 4; // stack-tight
  static const double stackBase = 8; // stack-base
  static const double componentPadding = 12; // component-padding
  static const double gutter = 12; // grid gutter
  static const double containerMargin = 16; // screen edge margin
  static const double sectionGap = 32; // gap between page sections

  // ---------------------------------------------------------------------------
  // Border radius scale
  // ---------------------------------------------------------------------------
  static const double radiusDefault = 4; // 0.25rem
  static const double radiusLg = 8; // 0.5rem
  static const double radiusXl = 12; // 0.75rem — cards, buttons, inputs
  static const double radiusFull = 9999; // pills / circular

  static const Radius radiusXlValue = Radius.circular(radiusXl);
  static const BorderRadius borderRadiusXl =
      BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderRadiusLg =
      BorderRadius.all(Radius.circular(radiusLg));

  // ---------------------------------------------------------------------------
  // Component sizes
  // ---------------------------------------------------------------------------
  static const double appBarHeight = 56; // h-14
  static const double bottomNavHeight = 64; // h-16
  static const double inputHeight = 48; // h-12
  static const double buttonHeight = 48; // h-12 primary CTA
  static const double productAspectRatio = 3 / 4; // aspect-3-4 product cards
}
