import 'package:flutter/widgets.dart';
import 'package:remixicon/remixicon.dart';

/// Icon tokens for PakoTV.
///
/// Source of truth: `docs/DESIGN_SYSTEM.md`, section 4 ("Iconografía").
/// Every icon comes from `remixicon`, the `_line` variant by default and
/// `_fill` for active states — never mix with Material's `Icons.*` or
/// `CupertinoIcons.*`. Pako's icon (the Match FAB) is a custom SVG, not
/// RemixIcons, so it is not part of this class (see `docs/DECISIONS.md`
/// section 9).
class AppIcons {
  const AppIcons._();

  static const IconData search = RemixIcons.search_line;
  static const IconData searchFill = RemixIcons.search_fill;
  static const IconData filter = RemixIcons.equalizer_2_line;
  static const IconData history = RemixIcons.history_line;
  static const IconData sort = RemixIcons.arrow_up_down_line;

  static const IconData favorite = RemixIcons.heart_line;
  static const IconData favoriteFill = RemixIcons.heart_fill;

  static const IconData watchLater = RemixIcons.bookmark_line;
  static const IconData watchLaterFill = RemixIcons.bookmark_fill;

  static const IconData watched = RemixIcons.eye_line;
  static const IconData watchedFill = RemixIcons.eye_fill;

  static const IconData play = RemixIcons.play_line;
  static const IconData share = RemixIcons.share_line;
  static const IconData back = RemixIcons.arrow_left_line;
  static const IconData close = RemixIcons.close_line;
  static const IconData home = RemixIcons.home_line;
  static const IconData homeFill = RemixIcons.home_fill;

  static const IconData compass = RemixIcons.compass_line;
  static const IconData compassFill = RemixIcons.compass_fill;

  static const IconData list = RemixIcons.bookmark_line;
  static const IconData listFill = RemixIcons.bookmark_fill;

  static const IconData user = RemixIcons.user_line;
  static const IconData userFill = RemixIcons.user_fill;
  static const IconData cloudOff = RemixIcons.cloud_off_line;
  static const IconData wifiOff = RemixIcons.signal_wifi_off_line;
  static const IconData calendar = RemixIcons.calendar_line;
  static const IconData delete = RemixIcons.delete_bin_line;
  static const IconData edit = RemixIcons.edit_2_line;
  static const IconData settings = RemixIcons.settings_line;
  static const IconData stats = RemixIcons.bar_chart_line;
  static const IconData qrCode = RemixIcons.qr_code_line;
  static const IconData copy = RemixIcons.file_copy_line;
  static const IconData retry = RemixIcons.refresh_line;
  static const IconData check = RemixIcons.check_line;
  static const IconData chevronRight = RemixIcons.arrow_right_s_line;
  static const IconData globe = RemixIcons.global_line;
  static const IconData chevronDown = RemixIcons.arrow_down_s_line;
  static const IconData info = RemixIcons.information_line;
  static const IconData hourglass = RemixIcons.hourglass_line;
  static const IconData group = RemixIcons.team_line;

  /// The Match button's sparkle (replaces Pako's face there).
  static const IconData match = RemixIcons.sparkling_2_fill;
  static const IconData dice = RemixIcons.dice_5_line;
  static const IconData useMyTastes = RemixIcons.user_add_line;

  static const IconData more = RemixIcons.more_2_fill;
  static const IconData star = RemixIcons.star_line;
  static const IconData starFill = RemixIcons.star_fill;

  // Vibe catalog (16, docs/DECISIONS.md section 5) — one plain icon
  // each, no `_fill` counterpart: `QuizTile` (the grid these render in,
  // onboarding/quiz/C5) recolors a single outline icon for its selected
  // state rather than swapping the glyph itself.
  static const IconData vibeFeelGood = RemixIcons.sun_line;
  static const IconData vibeIndie = RemixIcons.seedling_line;
  static const IconData vibeMonster = RemixIcons.ghost_line;
  static const IconData vibeDetective = RemixIcons.search_eye_line;
  static const IconData vibeClassic = RemixIcons.medal_line;
  static const IconData vibeSuperhero = RemixIcons.shield_flash_line;
  static const IconData vibeTearjerker = RemixIcons.heart_pulse_line;
  static const IconData vibeSports = RemixIcons.football_line;
  static const IconData vibeDate = RemixIcons.hand_heart_line;
  static const IconData vibeFuture = RemixIcons.rocket_line;
  static const IconData vibeExplosive = RemixIcons.fire_line;
  static const IconData vibeGritty = RemixIcons.knife_line;
  static const IconData vibeTrueStory = RemixIcons.newspaper_line;
  static const IconData vibeGangster = RemixIcons.money_dollar_circle_line;
  static const IconData vibeMusical = RemixIcons.music_line;
  static const IconData vibeFantasy = RemixIcons.sparkling_line;

  // Genre catalog (16, GenreCatalog — core/domain/entities/
  // genre_catalog.dart) — same one-plain-icon convention as the vibes
  // above, for the same reason (QuizTile recolors, never swaps glyphs).
  static const IconData genreAction = RemixIcons.boxing_line;
  static const IconData genreAdventure = RemixIcons.map_line;
  static const IconData genreAnimation = RemixIcons.palette_line;
  static const IconData genreComedy = RemixIcons.emotion_laugh_line;
  static const IconData genreCrime = RemixIcons.police_badge_line;
  static const IconData genreDocumentary = RemixIcons.camera_line;
  static const IconData genreDrama = RemixIcons.emotion_line;
  static const IconData genreFamily = RemixIcons.parent_line;
  static const IconData genreFantasy = RemixIcons.magic_line;
  static const IconData genreHistory = RemixIcons.ancient_pavilion_line;
  static const IconData genreHorror = RemixIcons.ghost_line;
  static const IconData genreMusic = RemixIcons.music_2_line;
  static const IconData genreMystery = RemixIcons.question_line;
  static const IconData genreRomance = RemixIcons.hearts_line;
  static const IconData genreSciFi = RemixIcons.aliens_line;
  static const IconData genreThriller = RemixIcons.timer_flash_line;

  /// E2's "Max seasons" stepper (`docs/DESIGN_SYSTEM.md` section 5's own
  /// "9. Stepper (seasons) and toggle").
  static const IconData stepperIncrement = RemixIcons.add_circle_line;
  static const IconData stepperDecrement = RemixIcons.indeterminate_circle_line;

  /// E1's own "two large cards 'A movie' / 'A TV show', each with an
  /// icon".
  static const IconData movie = RemixIcons.movie_line;
  static const IconData tvShow = RemixIcons.tv_line;
}
