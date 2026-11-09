import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/widgets.dart';

import 'app_colors.dart';

/// Text style tokens for PakoTV.
///
/// Source of truth: `docs/DESIGN_SYSTEM.md`, section 2 ("Tipografía").
/// Single family: Manrope, weights 400 (regular) and 600 (semibold — used
/// as the "500" of the mockups, since Manrope has no 500).
///
/// The document gives some sizes as a range (e.g. `h1` 26–28). Per team
/// decision, the lower bound of each range is the literal used here:
/// `h1`=26, `h2`=20, `h3`=15, `body`=14, `caption`=11, `micro`=9.
///
/// Every style defaults to [AppColors.ink] (primary text). Callers needing
/// [AppColors.inkMuted], [AppColors.inkDim], or [AppColors.onAccent]
/// should apply `.copyWith(color: ...)`.
class AppTextStyles {
  const AppTextStyles._();

  static const FontWeight _regular = FontWeight.w400;
  static const FontWeight _semibold = FontWeight.w600;

  /// Detail title (movie/show). 32 / 1.15, semibold.
  static final TextStyle display = GoogleFonts.manrope(
    fontSize: 32,
    height: 1.15,
    fontWeight: _semibold,
    color: AppColors.ink,
  );

  /// Flow headlines (onboarding, result, cover). 26 / 1.15, semibold.
  static final TextStyle h1 = GoogleFonts.manrope(
    fontSize: 26,
    height: 1.15,
    fontWeight: _semibold,
    color: AppColors.ink,
  );

  /// Section title, large card title. 20 / 1.2, semibold.
  static final TextStyle h2 = GoogleFonts.manrope(
    fontSize: 20,
    height: 1.2,
    fontWeight: _semibold,
    color: AppColors.ink,
  );

  /// Featured row title, name on a card. 15 / 1.25, semibold.
  static final TextStyle h3 = GoogleFonts.manrope(
    fontSize: 15,
    height: 1.25,
    fontWeight: _semibold,
    color: AppColors.ink,
  );

  /// Synopsis, card text. 14 / 1.5, regular.
  static final TextStyle body = GoogleFonts.manrope(
    fontSize: 14,
    height: 1.5,
    fontWeight: _regular,
    color: AppColors.ink,
  );

  /// Metadata, subtitles. 13 / 1.5, regular.
  static final TextStyle bodySm = GoogleFonts.manrope(
    fontSize: 13,
    height: 1.5,
    fontWeight: _regular,
    color: AppColors.ink,
  );

  /// Labels, footers, attribution. 11 / 1.4, regular.
  static final TextStyle caption = GoogleFonts.manrope(
    fontSize: 11,
    height: 1.4,
    fontWeight: _regular,
    color: AppColors.ink,
  );

  /// [body] in semibold: emphasised running text.
  static final TextStyle bodyStrong = body.copyWith(fontWeight: _semibold);

  /// [bodySm] in semibold: names, chip labels, button labels.
  static final TextStyle bodySmStrong = bodySm.copyWith(fontWeight: _semibold);

  /// [caption] in semibold: small badges and counters.
  static final TextStyle captionStrong = caption.copyWith(
    fontWeight: _semibold,
  );

  /// [h3] in regular weight: the unselected state of a selectable row.
  static final TextStyle h3Regular = h3.copyWith(fontWeight: _regular);

  /// Selected/unselected pair for segmented controls and tabs, so the
  /// weight swap lives here and not in each widget.
  static TextStyle bodySmToggle(bool selected) =>
      selected ? bodySmStrong : bodySm;
  static TextStyle captionToggle(bool selected) =>
      selected ? captionStrong : caption;
  static TextStyle h3Toggle(bool selected) => selected ? h3 : h3Regular;

  /// Small caps label above a block ("SYNOPSIS"): 11, semibold, tracked,
  /// muted. Callers pass the text already upper-cased.
  static final TextStyle overline = GoogleFonts.manrope(
    fontSize: 11,
    height: 1.4,
    letterSpacing: 1,
    fontWeight: _semibold,
    color: AppColors.inkMuted,
  );

  /// A text action in amber ("Read more", "See all"): 13, semibold.
  static final TextStyle action = GoogleFonts.manrope(
    fontSize: 13,
    height: 1.5,
    fontWeight: _semibold,
    color: AppColors.accent,
  );

  /// Text inside very small pills. 9 / 1.3, regular.
  static final TextStyle micro = GoogleFonts.manrope(
    fontSize: 9,
    height: 1.3,
    fontWeight: _regular,
    color: AppColors.ink,
  );
}
