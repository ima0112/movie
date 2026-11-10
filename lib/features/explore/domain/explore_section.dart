import '../../../core/domain/entities/discover_filter.dart';
import '../../../core/domain/entities/genre.dart';
import '../../../core/domain/entities/media_type.dart';

/// B2's body sections at rest (`docs/SCREENS.md` B2), in on-screen order.
enum ExploreSection { topToday, topRated, newReleases, hiddenGems }

/// The window "New releases" looks back over.
const Duration newReleasesWindow = Duration(days: 60);

/// The `discover` filter behind [section], narrowed by the pills the user has
/// picked ([genre], [providerId]) and the segment ([type]; `null` = All).
/// "See all" on a section opens C1 with this same filter, so what C1 lists is
/// exactly what the carousel previewed.
///
/// - **Top today** — most popular right now (TMDB's popularity is a rolling,
///   daily figure).
/// - **Top rated** — best average among titles with plenty of votes.
/// - **New releases** — released within [newReleasesWindow] up to [today],
///   most popular first; few votes are fine for something just out.
/// - **Hidden gems** — well rated (7.3+) but not widely voted (150–1500
///   votes), best first.
///
/// Pure domain code: no Flutter, no network.
DiscoverFilter exploreSectionFilter(
  ExploreSection section, {
  required DateTime today,
  MediaType? type,
  Genre? genre,
  int? providerId,
}) {
  final base = DiscoverFilter(
    type: type,
    withGenres: genre == null ? const {} : {genre},
    withWatchProviders: providerId == null ? const {} : {providerId},
  );
  return switch (section) {
    ExploreSection.topToday => base,
    ExploreSection.topRated => base.copyWith(
      sortBy: DiscoverSortBy.rating,
      minVoteCount: 300,
    ),
    ExploreSection.newReleases => base.copyWith(
      releasedFrom: () => today.subtract(newReleasesWindow),
      releasedTo: () => today,
      minVoteCount: 10,
    ),
    ExploreSection.hiddenGems => base.copyWith(
      sortBy: DiscoverSortBy.rating,
      minVoteAverage: () => 7.3,
      minVoteCount: 150,
      maxVoteCount: () => 1500,
    ),
  };
}
