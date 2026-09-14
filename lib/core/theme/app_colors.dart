import 'package:flutter/widgets.dart';

/// Color tokens for PakoTV.
///
/// Source of truth: `docs/DESIGN_SYSTEM.md`, section 1 ("Color"). Never
/// hardcode a hex literal outside this file — reference these tokens
/// instead.
class AppColors {
  const AppColors._();

  /// Page background, dark mode (default).
  static const Color surface = Color(0xFF0B0B0D);

  /// Cards, fields, sheets, unselected chips.
  static const Color surfaceRaised = Color(0xFF161618);

  /// One level above [surfaceRaised] (cards inside sheets).
  static const Color surfaceRaised2 = Color(0xFF1E1E22);

  /// Thin separators between rows of the same group.
  static const Color line = Color(0xFF1E1E22);

  /// Borders for chips and secondary buttons.
  static const Color lineStrong = Color(0xFF2A2A2E);

  /// Primary text, active icons.
  static const Color ink = Color(0xFFF5F5F7);

  /// Secondary text, metadata, inactive icons.
  static const Color inkMuted = Color(0xFFA1A1A8);

  /// Tertiary text (attributions, footers).
  static const Color inkDim = Color(0xFF5F5E5A);

  /// The single accent color. See DESIGN_SYSTEM.md "Dónde va el acento"
  /// for the closed list of places this is allowed to appear.
  static const Color accent = Color(0xFFF2B441);

  /// Origin of the radial halo behind the accent. Never used as a text or
  /// icon color.
  static const Color accentDeep = Color(0xFF5A3A10);

  /// Text/icons on top of an [accent] background.
  static const Color onAccent = Color(0xFF1A1204);

  /// Perfect match, participant-ready check.
  static const Color success = Color(0xFF6FCF97);

  /// Destructive actions, errors.
  static const Color danger = Color(0xFFFF6B6B);

  /// Profile colors — user initial avatars and room avatars only. Not used
  /// in any other UI context.
  static const Color profileAmber = Color(0xFFF2B441);
  static const Color profileCoral = Color(0xFFFF6B6B);
  static const Color profileMint = Color(0xFF6FCF97);
  static const Color profileLilac = Color(0xFFA78BFA);

  /// All profile colors, in the order they should be assigned.
  static const List<Color> profileColors = [
    profileAmber,
    profileCoral,
    profileMint,
    profileLilac,
  ];
}
