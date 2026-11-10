import '../entities/discover_filter.dart';
import '../entities/media_type.dart';
import '../repositories/media_repository.dart';

/// The `/discover` filter that approximates a Discover collection — what the
/// "See all" listing switches to when the user re-sorts it (a collection's own
/// endpoint, like `/movie/now_playing`, has a fixed order and can't be
/// sorted). Its *default* order still uses the collection's own endpoint, so
/// "See all" opens exactly like the carousel; only another sort goes through
/// this filter. `null` for a collection that has no catalog equivalent
/// (Watch later is the user's own list).
///
/// [type] is the segment (`null` = All). Pure domain: no network, no clock.
DiscoverFilter? carouselSectionFilter(
  CarouselSection section, {
  required MediaType? type,
  required DateTime today,
}) {
  final base = DiscoverFilter(type: type);
  return switch (section) {
    CarouselSection.popularThisWeek ||
    CarouselSection.trending ||
    CarouselSection.popular => base,
    CarouselSection.topRated => base.copyWith(
      sortBy: DiscoverSortBy.rating,
      minVoteCount: 300,
    ),
    // Released in the last 45 days, up to today: what is in cinemas.
    CarouselSection.inTheaters => base.copyWith(
      type: () => MediaType.movie,
      releasedFrom: () => today.subtract(const Duration(days: 45)),
      releasedTo: () => today,
      minVoteCount: 10,
    ),
    CarouselSection.comingSoon || CarouselSection.upcoming => base.copyWith(
      releasedFrom: () => today.add(const Duration(days: 1)),
      releasedTo: () => today.add(const Duration(days: 90)),
      minVoteCount: 0,
    ),
    CarouselSection.airingNow => base.copyWith(
      type: () => MediaType.tvShow,
      tvStatus: () => DiscoverTvStatus.airing,
    ),
    CarouselSection.finishedShows => base.copyWith(
      type: () => MediaType.tvShow,
      tvStatus: () => DiscoverTvStatus.ended,
      sortBy: DiscoverSortBy.rating,
      minVoteCount: 500,
    ),
    CarouselSection.watchLater => null,
  };
}
