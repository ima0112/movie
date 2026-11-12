import '../core/domain/entities/discover_filter.dart';
import 'app_localizations.dart';

/// The single mapper from [DiscoverSortBy] to its display label —
/// CLAUDE.md rule 15. Previously duplicated as an identical literal map
/// in both `discover_sort_chips.dart` and
/// `filtered_list_count_line.dart`; both now call this instead.
extension DiscoverSortByLocalization on DiscoverSortBy {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    DiscoverSortBy.popularity => l10n.discoverSortPopularity,
    DiscoverSortBy.rating => l10n.discoverSortRating,
    DiscoverSortBy.releaseDate => l10n.discoverSortDate,
    DiscoverSortBy.title => l10n.discoverSortTitle,
    DiscoverSortBy.voteCount => l10n.discoverSortVotes,
  };
}
