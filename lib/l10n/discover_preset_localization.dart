import '../core/domain/entities/discover_preset.dart';
import 'app_localizations.dart';

/// [DiscoverPreset]'s display label — the extra choices of H8's "Sort by"
/// row and C1's matching chip. CLAUDE.md rule 15.
extension DiscoverPresetLocalization on DiscoverPreset {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    DiscoverPreset.comingSoon => l10n.filterSheetPresetComingSoon,
    DiscoverPreset.inTheaters => l10n.filterSheetPresetInTheaters,
    DiscoverPreset.finished => l10n.filterSheetPresetFinished,
    DiscoverPreset.airingNow => l10n.filterSheetPresetAiringNow,
  };
}
