import '../../../core/domain/entities/discover_filter.dart';
import '../../../core/domain/entities/media_type.dart';
import '../../../core/domain/repositories/media_repository.dart';

/// The orders a "See all" listing can be re-sorted into (the short list):
/// the section's own, then four TMDB sorts.
enum ListingSort {
  /// The order the section previewed (its own filter's sort, or the
  /// collection's own endpoint). The listing opens in it.
  byDefault,
  popularity,
  rating,
  mostVoted,
  newest;

  /// The TMDB sort behind this one; `null` for [byDefault].
  DiscoverSortBy? get discoverSort => switch (this) {
    ListingSort.byDefault => null,
    ListingSort.popularity => DiscoverSortBy.popularity,
    ListingSort.rating => DiscoverSortBy.rating,
    ListingSort.mostVoted => DiscoverSortBy.voteCount,
    ListingSort.newest => DiscoverSortBy.releaseDate,
  };
}

/// Where a "See all" listing gets its titles from.
sealed class ListingSource {
  const ListingSource();

  /// The sorts that make sense for this listing. A window of unreleased
  /// titles has no votes to rate or count, so those two are left out.
  List<ListingSort> get sorts;
}

/// B2's sections: a `/discover` filter (the section's own, narrowed by the
/// genre and platform picked). Re-sorting only changes `sortBy`; every other
/// part of the filter (date windows, minimum votes…) stays.
final class FilterListing extends ListingSource {
  const FilterListing(this.filter, {required this.today});

  final DiscoverFilter filter;

  /// To tell whether the filter's window is still in the future.
  final DateTime today;

  bool get _unreleased {
    final from = filter.releasedFrom;
    return from != null && from.isAfter(today);
  }

  @override
  List<ListingSort> get sorts => _unreleased
      ? const [
          ListingSort.byDefault,
          ListingSort.popularity,
          ListingSort.newest,
        ]
      : ListingSort.values;
}

/// B1's collections: opens with the collection's own endpoint (exactly what the
/// carousel previewed); another sort switches to the equivalent `/discover`.
final class CollectionListing extends ListingSource {
  const CollectionListing(this.section, {required this.type});

  final CarouselSection section;

  /// The segment (`null` = All).
  final MediaType? type;

  @override
  List<ListingSort> get sorts =>
      section == CarouselSection.comingSoon ||
          section == CarouselSection.upcoming
      ? const [
          ListingSort.byDefault,
          ListingSort.popularity,
          ListingSort.newest,
        ]
      : ListingSort.values;
}
