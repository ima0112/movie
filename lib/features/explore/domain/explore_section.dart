import '../../../core/domain/entities/discover_filter.dart';
import '../../../core/domain/entities/media_type.dart';

/// B2's body sections at rest (`docs/SCREENS.md` B2), in on-screen order.
enum ExploreSection {
  topToday,
  popular,
  topRated,
  newReleases,
  comingSoon,
  hiddenGems,
}

/// The window "New releases" looks back over.
const Duration newReleasesWindow = Duration(days: 60);

/// The window "Coming soon" looks ahead over, starting tomorrow.
const Duration comingSoonWindow = Duration(days: 90);

/// The `discover` filter behind [section], narrowed by the platform the user
/// picked ([providerId]) and the segment ([type]; `null` = All).
/// "See all" on a section opens C1 with this same filter, so what C1 lists is
/// exactly what the carousel previewed.
///
/// - **Top today** — most popular right now (TMDB's popularity is a rolling,
///   daily figure).
/// - **Popular** — the most voted of all time (the classics), unlike *Top
///   today*, which follows TMDB's rolling current interest.
/// - **Top rated** — best average among titles with plenty of votes.
/// - **New releases** — released within [newReleasesWindow] up to [today],
///   most popular first; few votes are fine for something just out.
/// - **Coming soon** — releasing from tomorrow up to [comingSoonWindow] ahead,
///   most popular first.
/// - **Hidden gems** — well rated (7.3+) but not widely voted (150–1500
///   votes), best first.
///
/// Pure domain code: no Flutter, no network.
DiscoverFilter exploreSectionFilter(
  ExploreSection section, {
  required DateTime today,
  MediaType? type,
  int? providerId,
}) {
  final base = DiscoverFilter(
    type: type,
    withWatchProviders: providerId == null ? const {} : {providerId},
  );
  return switch (section) {
    ExploreSection.topToday => base,
    ExploreSection.popular => base.copyWith(
      sortBy: DiscoverSortBy.voteCount,
      minVoteCount: 1000,
    ),
    ExploreSection.topRated => base.copyWith(
      sortBy: DiscoverSortBy.rating,
      minVoteCount: 300,
    ),
    ExploreSection.newReleases => base.copyWith(
      releasedFrom: () => today.subtract(newReleasesWindow),
      releasedTo: () => today,
      minVoteCount: 10,
    ),
    ExploreSection.comingSoon => base.copyWith(
      releasedFrom: () => today.add(const Duration(days: 1)),
      releasedTo: () => today.add(comingSoonWindow),
      minVoteCount: 0,
    ),
    ExploreSection.hiddenGems => base.copyWith(
      sortBy: DiscoverSortBy.rating,
      minVoteAverage: () => 7.3,
      minVoteCount: 150,
      maxVoteCount: () => 1500,
    ),
  };
}
