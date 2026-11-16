import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/tmdb/tmdb_discover_params.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/discover_preset.dart';
import 'package:movies/core/domain/entities/media_type.dart';

void main() {
  final now = DateTime(2026, 11, 13, 15, 30);

  group('DiscoverPreset.forType', () {
    test('movies get Coming soon and In theaters; shows Finished and Airing '
        'now; All none', () {
      expect(DiscoverPreset.forType(MediaType.movie), [
        DiscoverPreset.comingSoon,
        DiscoverPreset.inTheaters,
      ]);
      expect(DiscoverPreset.forType(MediaType.tvShow), [
        DiscoverPreset.finished,
        DiscoverPreset.airingNow,
      ]);
      expect(DiscoverPreset.forType(null), isEmpty);
    });
  });

  group('withPreset / presetAt', () {
    test('each preset is recognized after being applied', () {
      for (final preset in DiscoverPreset.values) {
        final filter = const DiscoverFilter().withPreset(preset, now: now);
        expect(filter.presetAt(now), preset, reason: '$preset');
      }
    });

    test('Coming soon: tomorrow to 90 days ahead, no vote floor', () {
      final filter = const DiscoverFilter(
        type: MediaType.movie,
      ).withPreset(DiscoverPreset.comingSoon, now: now);

      expect(filter.releasedFrom, DateTime(2026, 11, 14));
      expect(filter.releasedTo, DateTime(2027, 2, 11));
      expect(filter.minVoteCount, 0);
    });

    test('In theaters: the last 45 days', () {
      final filter = const DiscoverFilter(
        type: MediaType.movie,
      ).withPreset(DiscoverPreset.inTheaters, now: now);

      expect(filter.releasedFrom, DateTime(2026, 9, 29));
      expect(filter.releasedTo, DateTime(2026, 11, 13));
    });

    test('Finished and Airing now use the TV status', () {
      final base = const DiscoverFilter(type: MediaType.tvShow);
      expect(
        base.withPreset(DiscoverPreset.finished, now: now).tvStatus,
        DiscoverTvStatus.ended,
      );
      expect(
        base.withPreset(DiscoverPreset.airingNow, now: now).tvStatus,
        DiscoverTvStatus.airing,
      );
    });

    test(
      'picking another preset, or none, replaces the old one completely',
      () {
        final coming = const DiscoverFilter(
          type: MediaType.movie,
        ).withPreset(DiscoverPreset.comingSoon, now: now);

        final cleared = coming.withPreset(null);
        expect(cleared, const DiscoverFilter(type: MediaType.movie));
        expect(cleared.preset, isNull);

        final theaters = coming.withPreset(DiscoverPreset.inTheaters, now: now);
        expect(theaters.presetAt(now), DiscoverPreset.inTheaters);
        expect(theaters.minVoteCount, 10);
      },
    );

    test('a window saved on another day is no longer a preset', () {
      final filter = const DiscoverFilter(
        type: MediaType.movie,
      ).withPreset(DiscoverPreset.comingSoon, now: now);

      expect(filter.presetAt(now.add(const Duration(days: 3))), isNull);
    });
  });

  group('rating range and original language', () {
    test('map to vote_average.gte/lte and with_original_language', () {
      final params = discoverQueryParams(
        const DiscoverFilter(
          minVoteAverage: 5,
          maxVoteAverage: 8.5,
          originalLanguage: 'ko',
        ),
        type: MediaType.movie,
      );

      expect(params['vote_average.gte'], 5);
      expect(params['vote_average.lte'], 8.5);
      expect(params['with_original_language'], 'ko');
    });

    test('are left out when unset', () {
      final params = discoverQueryParams(
        const DiscoverFilter(),
        type: MediaType.movie,
      );

      expect(params.containsKey('vote_average.lte'), isFalse);
      expect(params.containsKey('with_original_language'), isFalse);
    });

    test('count as filters; equality and copyWith include them', () {
      const filter = DiscoverFilter(maxVoteAverage: 8, originalLanguage: 'ja');
      expect(filter.activeFilterCount, 2);
      expect(filter == const DiscoverFilter(), isFalse);
      expect(
        filter.copyWith(
          maxVoteAverage: () => null,
          originalLanguage: () => null,
        ),
        const DiscoverFilter(),
      );
    });
  });

  group('withSort', () {
    test('Top rated asks for 300 votes, so a 9.9 from a handful of people '
        'never leads; any other order goes back to the default floor', () {
      final rated = const DiscoverFilter().withSort(DiscoverSortBy.rating);
      expect(rated.sortBy, DiscoverSortBy.rating);
      expect(rated.minVoteCount, 300);

      final back = rated.withSort(DiscoverSortBy.releaseDateAsc);
      expect(back.minVoteCount, const DiscoverFilter().minVoteCount);
      expect(
        const DiscoverFilter().withSort(DiscoverSortBy.popularity),
        const DiscoverFilter(),
      );
    });

    test('a release-window preset keeps its own floor', () {
      final coming = const DiscoverFilter(
        type: MediaType.movie,
      ).withPreset(DiscoverPreset.comingSoon, now: DateTime(2026, 11, 13));

      // `now` is the day the preset was applied: the window is recognized by
      // its dates, so a test must not depend on today's date.
      expect(
        coming
            .withSort(DiscoverSortBy.rating, now: DateTime(2026, 11, 13))
            .minVoteCount,
        0,
      );
    });

    test('Oldest first maps to the ascending date sort, for both kinds', () {
      expect(
        discoverQueryParams(
          const DiscoverFilter(sortBy: DiscoverSortBy.releaseDateAsc),
          type: MediaType.movie,
        )['sort_by'],
        'primary_release_date.asc',
      );
      expect(
        discoverQueryParams(
          const DiscoverFilter(sortBy: DiscoverSortBy.releaseDateAsc),
          type: MediaType.tvShow,
        )['sort_by'],
        'first_air_date.asc',
      );
    });
  });
}
