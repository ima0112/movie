import '../features/match_engine/domain/vibe.dart';
import 'app_localizations.dart';

/// The single mapper from a [Vibe]'s stable [Vibe.id] to its display
/// name — CLAUDE.md rule 15: `domain`/`data` never contain user-facing
/// text, so [Vibe] carries only an [Vibe.id] and every screen that
/// shows one (including a vibe tile's own tooltip) calls
/// `vibe.localizedName(context.l10n)`.
///
/// Covers every `assets/vibes.json` id — **not actually compile-time
/// exhaustive**, despite `id` being driven off a fixed catalog: [Vibe
/// .id] is a plain `String` (`vibe.dart`), so this is a runtime string
/// switch. The `_ => throw ArgumentError(...)` below is what catches a
/// vibe added to the catalog without a matching case here — at the
/// first attempt to render its label, not at compile time. Keep every
/// `assets/vibes.json` id covered by hand.
extension VibeLocalization on Vibe {
  String localizedName(AppLocalizations l10n) => switch (id) {
    'feel_good' => l10n.vibeFeelGood,
    'indie' => l10n.vibeIndie,
    'monster' => l10n.vibeMonster,
    'classic' => l10n.vibeClassic,
    'superhero' => l10n.vibeSuperhero,
    'tearjerker' => l10n.vibeTearjerker,
    'sports' => l10n.vibeSports,
    'date' => l10n.vibeDateNight,
    'gritty' => l10n.vibeGritty,
    'true_story' => l10n.vibeTrueStory,
    'gangster' => l10n.vibeGangster,
    'musical' => l10n.vibeMusical,
    'time_travel' => l10n.vibeTimeTravel,
    'coming_of_age' => l10n.vibeComingOfAge,
    'dystopia' => l10n.vibeDystopia,
    'survival' => l10n.vibeSurvival,
    'revenge' => l10n.vibeRevenge,
    'martial_arts' => l10n.vibeMartialArts,
    'heist' => l10n.vibeHeist,
    _ => throw ArgumentError('Unknown vibe id: $id'),
  };
}
