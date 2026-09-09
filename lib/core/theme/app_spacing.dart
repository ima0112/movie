import 'package:flutter/widgets.dart';

/// Spacing and radius tokens for PakoTV.
///
/// Source of truth: `docs/DESIGN_SYSTEM.md`, section 3 ("Espaciado").
/// Always use the named token, never a bare number.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;

  /// Standard screen side margin.
  static const double xl = 20;

  static const double xxl = 24;

  /// Separation between Discover sections.
  static const double xxxl = 32;

  static const double radiusSm = 8;

  /// Posters, cards, tiles.
  static const double radiusMd = 12;

  /// Large cards, result sheets.
  static const double radiusLg = 16;

  /// Buttons, chips.
  static const double radiusPill = 999;

  /// Bottom sheets: rounded top corners, square bottom.
  static const BorderRadius bottomSheetRadius = BorderRadius.only(
    topLeft: Radius.circular(20),
    topRight: Radius.circular(20),
  );
}
