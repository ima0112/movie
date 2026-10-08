import '../core/domain/entities/discover_filter.dart';
import 'app_localizations.dart';

/// The single mapper from [DiscoverTvStatus] (H8's filter/toggle) to
/// display text — CLAUDE.md rule 15. Not used by E2 step 4's own
/// "Finished | Either" toggle: that one deliberately uses different
/// words for the same [DiscoverTvStatus.ended] value (see
/// `quizFinishedToggleFinished`'s own ARB description) and is localized
/// locally in `quiz_final_step.dart` instead.
extension DiscoverTvStatusLocalization on DiscoverTvStatus {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    DiscoverTvStatus.airing => l10n.tvStatusAiring,
    DiscoverTvStatus.ended => l10n.tvStatusEnded,
  };
}
