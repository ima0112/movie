import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/features/explore/domain/explore_section.dart';

void main() {
  final today = DateTime(2026, 5, 4);
  const action = Genre(id: 'action');

  DiscoverFilter filter(
    ExploreSection s, {
    MediaType? type,
    Genre? genre,
    int? provider,
  }) => exploreSectionFilter(
    s,
    today: today,
    type: type,
    genre: genre,
    providerId: provider,
  );

  test('every section carries the segment, genre and platform picked', () {
    for (final section in ExploreSection.values) {
      final f = filter(
        section,
        type: MediaType.movie,
        genre: action,
        provider: 8,
      );
      expect(f.type, MediaType.movie, reason: '$section');
      expect(f.withGenres, {action}, reason: '$section');
      expect(f.withWatchProviders, {8}, reason: '$section');
    }
    final none = filter(ExploreSection.topToday);
    expect(none.type, isNull);
    expect(none.withGenres, isEmpty);
    expect(none.withWatchProviders, isEmpty);
  });

  test('top today is plain popularity', () {
    expect(filter(ExploreSection.topToday).sortBy, DiscoverSortBy.popularity);
  });

  test('top rated sorts by rating among well-voted titles', () {
    final f = filter(ExploreSection.topRated);
    expect(f.sortBy, DiscoverSortBy.rating);
    expect(f.minVoteCount, 300);
  });

  test('new releases: the last 60 days up to today, popular first', () {
    final f = filter(ExploreSection.newReleases);
    expect(f.releasedTo, today);
    expect(f.releasedFrom, DateTime(2026, 3, 5));
    expect(f.sortBy, DiscoverSortBy.popularity);
    expect(f.minVoteCount, lessThan(100)); // a fresh title has few votes
  });

  test('hidden gems: well rated, few votes, best first', () {
    final f = filter(ExploreSection.hiddenGems);
    expect(f.minVoteAverage, 7.3);
    expect(f.minVoteCount, 150);
    expect(f.maxVoteCount, 1500);
    expect(f.sortBy, DiscoverSortBy.rating);
  });
}
