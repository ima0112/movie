import 'package:flutter/widgets.dart';

import '../../core/theme/app_icons.dart';
import '../../features/match_engine/domain/vibe.dart';

/// Resolves [Vibe.icon] (an `AppIcons` constant *name*, e.g.
/// `"vibeFeelGood"` — a plain `String` since `vibe.dart` stays
/// Flutter-free) to the real icon. Falls back to [AppIcons.dice] if a
/// name doesn't match — shouldn't happen with `assets/vibes.json` as
/// shipped, but a silently wrong icon would be worse than a generic one.
IconData vibeIconFor(Vibe vibe) => _vibeIcons[vibe.icon] ?? AppIcons.dice;

const Map<String, IconData> _vibeIcons = {
  'vibeFeelGood': AppIcons.vibeFeelGood,
  'vibeIndie': AppIcons.vibeIndie,
  'vibeMonster': AppIcons.vibeMonster,
  'vibeDetective': AppIcons.vibeDetective,
  'vibeClassic': AppIcons.vibeClassic,
  'vibeSuperhero': AppIcons.vibeSuperhero,
  'vibeTearjerker': AppIcons.vibeTearjerker,
  'vibeSports': AppIcons.vibeSports,
  'vibeDate': AppIcons.vibeDate,
  'vibeFuture': AppIcons.vibeFuture,
  'vibeExplosive': AppIcons.vibeExplosive,
  'vibeGritty': AppIcons.vibeGritty,
  'vibeTrueStory': AppIcons.vibeTrueStory,
  'vibeGangster': AppIcons.vibeGangster,
  'vibeMusical': AppIcons.vibeMusical,
  'vibeFantasy': AppIcons.vibeFantasy,
};
