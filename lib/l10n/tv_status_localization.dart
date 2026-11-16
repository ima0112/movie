import '../core/domain/entities/discover_filter.dart';
import 'app_localizations.dart';

/// The single mapper from [DiscoverTvStatus] (H8's filter/toggle) to
/// display text — CLAUDE.md rule 15. Not used by E2 step 4's own
/// "Any | Finished" control: that one deliberately uses different words
/// for the same [DiscoverTvStatus.ended] value (`quizStatusFinished`).
extension DiscoverTvStatusLocalization on DiscoverTvStatus {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    DiscoverTvStatus.airing => l10n.tvStatusAiring,
    DiscoverTvStatus.ended => l10n.tvStatusEnded,
  };
}
