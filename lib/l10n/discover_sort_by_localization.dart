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
    DiscoverSortBy.releaseDateAsc => l10n.filterSheetSortOldest,
    DiscoverSortBy.title => l10n.discoverSortTitle,
    DiscoverSortBy.voteCount => l10n.discoverSortVotes,
  };
}

/// The three orders H8 and C1's sort control offer, in their longer wording
/// ("Popular", "Top rated", "Release date"); other values fall back to
/// [localizedLabel].
extension DiscoverSortBySheetLabel on DiscoverSortBy {
  String sheetLabel(AppLocalizations l10n) => switch (this) {
    DiscoverSortBy.popularity => l10n.filterSheetSortPopular,
    DiscoverSortBy.rating => l10n.filterSheetSortTopRated,
    DiscoverSortBy.releaseDate => l10n.filterSheetSortNewest,
    DiscoverSortBy.releaseDateAsc => l10n.filterSheetSortOldest,
    _ => localizedLabel(l10n),
  };
}
