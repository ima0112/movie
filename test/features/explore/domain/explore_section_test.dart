import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/features/explore/domain/explore_section.dart';

void main() {
  final today = DateTime(2026, 5, 4);

  DiscoverFilter filter(ExploreSection s, {MediaType? type, int? provider}) =>
      exploreSectionFilter(s, today: today, type: type, providerId: provider);

  test('every section carries the segment and the platform picked', () {
    for (final section in ExploreSection.values) {
      final f = filter(section, type: MediaType.movie, provider: 8);
      expect(f.type, MediaType.movie, reason: '$section');
      expect(f.withWatchProviders, {8}, reason: '$section');
    }
    final none = filter(ExploreSection.topToday);
    expect(none.type, isNull);
    expect(none.withWatchProviders, isEmpty);
  });

  test('top today is plain popularity', () {
    expect(filter(ExploreSection.topToday).sortBy, DiscoverSortBy.popularity);
  });

  test('popular is the most voted of all time', () {
    final f = filter(ExploreSection.popular);
    expect(f.sortBy, DiscoverSortBy.voteCount);
    expect(f.minVoteCount, 1000);
  });

  test('coming soon: from tomorrow to 90 days ahead, popular first', () {
    final f = filter(ExploreSection.comingSoon);
    expect(f.releasedFrom, DateTime(2026, 5, 5));
    expect(f.releasedTo, DateTime(2026, 8, 2));
    expect(f.sortBy, DiscoverSortBy.popularity);
    expect(f.minVoteCount, 0);
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
