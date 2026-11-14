import '../../../core/domain/entities/genre.dart';
import '../../../core/domain/entities/media_segment.dart';
import '../../../core/domain/entities/streaming_service.dart';
import 'listing_source.dart';

/// What each poster of a "See all" grid carries. It follows the sort (see
/// [listingStyleFor]): each order brings its own dressing, so re-sorting visibly
/// changes the grid, not only its order.
enum ListingStyle {
  /// Just the poster.
  plain,

  /// A small outlined rank (1, 2, 3…) in the bottom-left corner.
  ranked,

  /// An amber-star rating badge (top-left).
  rating,

  /// The release date and year (bottom-left).
  dated,

  /// Just the release year (bottom-left).
  year,

  /// The title over the poster's lower part.
  titled,

  /// The results-list tile: the "TV" tag (top-left), the rating (bottom-left),
  /// and the title with the release year **under** the poster — the same
  /// ficha as the filtered results (C1), so shows are told apart and each
  /// title is named. Hidden gems' own dressing.
  detailed,
}

/// The dressing for a listing in [sort], given the one its section's carousel
/// uses ([base]): the section's own order keeps [base]; every other sort has
/// its own — Popularity the rank, Rating the rating badge, Most voted the
/// title, Newest first the year (the full date where the section already shows
/// dates).
ListingStyle listingStyleFor(ListingSort sort, ListingStyle base) =>
    switch (sort) {
      ListingSort.byDefault => base,
      ListingSort.popularity => ListingStyle.ranked,
      ListingSort.rating => ListingStyle.rating,
      ListingSort.mostVoted => ListingStyle.titled,
      ListingSort.newest =>
        base == ListingStyle.dated ? ListingStyle.dated : ListingStyle.year,
    };

/// What the screen the user came from had set: shown as the pill under the
/// title. Explore also narrows by genre and platform; Home only by the
/// segment (All / Movies / TV Shows).
class ListingContext {
  const ListingContext.home(this.segment)
    : genre = null,
      platform = null,
      showsFilters = false;

  const ListingContext.explore({
    required this.segment,
    this.genre,
    this.platform,
  }) : showsFilters = true;

  final MediaSegment segment;
  final Genre? genre;
  final StreamingService? platform;

  /// Whether the genre / platform parts are shown at all (Explore only).
  final bool showsFilters;

  /// Whether each poster shows the platform it streams on: from Explore, when
  /// no platform narrowed the list (whatever the genre) — with a platform
  /// picked every title is on it, so a logo would say nothing.
  bool get showsPlatformLogos => showsFilters && platform == null;
}
