import '../features/section_listing/domain/listing_source.dart';
import 'app_localizations.dart';

/// The single mapper from [ListingSort] to its label — CLAUDE.md rule 15.
/// Reuses `DiscoverSortBy`'s own words for the TMDB sorts.
extension ListingSortLocalization on ListingSort {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    ListingSort.byDefault => l10n.sectionListingSortDefault,
    ListingSort.popularity => l10n.discoverSortPopularity,
    ListingSort.rating => l10n.discoverSortRating,
    ListingSort.mostVoted => l10n.discoverSortVotes,
    ListingSort.newest => l10n.sectionListingSortNewest,
  };
}
