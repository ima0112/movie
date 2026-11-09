import 'package:flutter/widgets.dart';

/// Spacing and radius tokens for PakoTV.
///
/// Source of truth: `docs/DESIGN_SYSTEM.md`, section 3 ("Espaciado").
/// Always use the named token, never a bare number.
class AppSpacing {
  const AppSpacing._();

  /// Hairline gap between stacked lines of text.
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;

  /// Standard screen side margin.
  static const double xl = 20;

  static const double xxl = 24;

  /// Separation between Discover sections.
  static const double xxxl = 32;

  // ── Layout roles ─────────────────────────────────────────────────────
  // Name the *role* of a gap, not its number: screens built from sections
  // read the same everywhere, and one change here moves all of them.

  /// Side margin of every screen's content (alias of [xl]).
  static const double screenMargin = xl;

  /// Empty space above each section of a scrolling screen (synopsis,
  /// where to watch, cast, similar…). A section owns this as its *top*
  /// padding and has no bottom padding, so one that hides itself (no data)
  /// leaves no hole.
  static const double sectionGap = xxl;

  /// Heading → the content right under it.
  static const double headingGap = md;

  /// Between sibling cards stacked in one group (info card → stat cards).
  static const double cardGap = md;

  /// Inside a card, on every side.
  static const double cardPadding = lg;

  /// Between small related items (a chip row, a label and its value).
  static const double itemGap = sm;

  /// A section's top spacing with the side margins: for sections whose
  /// content sits inside the screen margin.
  static const EdgeInsets sectionPadding = EdgeInsets.fromLTRB(
    screenMargin,
    sectionGap,
    screenMargin,
    0,
  );

  /// A section's top spacing only: for sections that scroll edge to edge and
  /// pad their own rows (cast, carousels).
  static const EdgeInsets sectionTopPadding = EdgeInsets.only(top: sectionGap);

  static const double radiusSm = 8;

  /// Posters, cards, tiles.
  static const double radiusMd = 12;

  /// Large cards, result sheets.
  static const double radiusLg = 16;

  /// Discover hero card.
  static const double radiusXl = 20;

  /// Buttons, chips.
  static const double radiusPill = 999;

  /// Dialogs and other floating cards.
  static const double radiusXxl = 24;

  /// Bottom sheets: rounded top corners, square bottom.
  static const BorderRadius bottomSheetRadius = BorderRadius.only(
    topLeft: Radius.circular(28),
    topRight: Radius.circular(28),
  );
}
