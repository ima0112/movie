import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/features/stats/domain/library_stats_calculator.dart';

const _action = Genre(id: 'action', name: 'Action');
const _drama = Genre(id: 'drama', name: 'Drama');
const _comedy = Genre(id: 'comedy', name: 'Comedy');

MediaKey _movie(int id) => MediaKey(type: MediaType.movie, tmdbId: id);
MediaKey _tvShow(int id) => MediaKey(type: MediaType.tvShow, tmdbId: id);

void main() {
  group('calculateLibraryStats — hours', () {
    test('sums movie runtimeMinutes and TV episodeCount*episodeRuntimeMinutes '
        'separately, over watched entries of each type', () {
      final entries = [
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(1),
          watchedAt: DateTime(2024, 1, 1),
          runtimeMinutes: 120,
        ),
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(2),
          watchedAt: DateTime(2024, 1, 1),
          runtimeMinutes: 90,
        ),
        UserMediaEntry(
          title: 'Test Title',
          key: _tvShow(1),
          watchedAt: DateTime(2024, 1, 1),
          episodeCount: 10,
          episodeRuntimeMinutes: 30,
        ),
      ];

      final stats = calculateLibraryStats(entries);

      expect(stats.movieHours, (120 + 90) / 60);
      expect(stats.estimatedTvHours, (10 * 30) / 60);
    });

    test(
      'a TV show with an episode count but no known per-episode runtime '
      'falls back to 45 min/episode (matches TvShowDetail.estimatedHours)',
      () {
        final entries = [
          UserMediaEntry(
            title: 'Test Title',
            key: _tvShow(1),
            watchedAt: DateTime(2024, 1, 1),
            episodeCount: 8,
            episodeRuntimeMinutes: null,
          ),
        ];

        final stats = calculateLibraryStats(entries);

        expect(stats.estimatedTvHours, (8 * 45) / 60);
      },
    );

    test('entries with no duration fields at all contribute 0 hours, not an '
        'error — movies and TV shows both', () {
      final entries = [
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(1),
          watchedAt: DateTime(2024, 1, 1),
        ),
        UserMediaEntry(
          title: 'Test Title',
          key: _tvShow(1),
          watchedAt: DateTime(2024, 1, 1),
        ),
      ];

      final stats = calculateLibraryStats(entries);

      expect(stats.movieHours, 0);
      expect(stats.estimatedTvHours, 0);
    });

    test('unwatched entries never contribute, even with duration data', () {
      final entries = [
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(1),
          isFavorite: true,
          runtimeMinutes: 200,
        ),
      ];

      final stats = calculateLibraryStats(entries);

      expect(stats.movieHours, 0);
      expect(stats.moviesWatched, 0);
    });
  });

  group('calculateLibraryStats — moviesWatched / tvShowsWatched', () {
    test('counts only watched entries of each type', () {
      final entries = [
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(1),
          watchedAt: DateTime(2024, 1, 1),
        ),
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(2),
          isFavorite: true,
        ), // not watched
        UserMediaEntry(
          title: 'Test Title',
          key: _tvShow(1),
          watchedAt: DateTime(2024, 1, 1),
        ),
        UserMediaEntry(
          title: 'Test Title',
          key: _tvShow(2),
          watchedAt: DateTime(2024, 1, 1),
        ),
      ];

      final stats = calculateLibraryStats(entries);

      expect(stats.moviesWatched, 1);
      expect(stats.tvShowsWatched, 2);
    });
  });

  group('calculateLibraryStats — filterType', () {
    test('a type filter scopes every field to that type only', () {
      final entries = [
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(1),
          watchedAt: DateTime(2024, 1, 1),
          runtimeMinutes: 120,
        ),
        UserMediaEntry(
          title: 'Test Title',
          key: _tvShow(1),
          watchedAt: DateTime(2024, 1, 1),
          episodeCount: 10,
          episodeRuntimeMinutes: 30,
        ),
      ];

      final movieStats = calculateLibraryStats(
        entries,
        filterType: MediaType.movie,
      );

      expect(movieStats.moviesWatched, 1);
      expect(movieStats.movieHours, 2);
      expect(movieStats.tvShowsWatched, 0);
      expect(movieStats.estimatedTvHours, 0);
    });
  });

  group('calculateLibraryStats — averageRating', () {
    test('averages only ratings that exist, ignoring unrated entries', () {
      final entries = [
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(1),
          watchedAt: DateTime(2024, 1, 1),
          rating: 4,
        ),
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(2),
          watchedAt: DateTime(2024, 1, 1),
          rating: 2,
        ),
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(3),
          watchedAt: DateTime(2024, 1, 1),
        ), // no rating
      ];

      final stats = calculateLibraryStats(entries);

      expect(stats.averageRating, 3);
    });

    test('is null, not NaN or 0, when nothing is watched', () {
      final stats = calculateLibraryStats(const []);

      expect(stats.averageRating, isNull);
    });
  });

  group('calculateLibraryStats — mostWatchedYear', () {
    test('picks the year with the most watched entries', () {
      final entries = [
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(1),
          watchedAt: DateTime(2023, 5, 1),
        ),
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(2),
          watchedAt: DateTime(2024, 1, 1),
        ),
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(3),
          watchedAt: DateTime(2024, 6, 1),
        ),
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(4),
          watchedAt: DateTime(2024, 11, 1),
        ),
      ];

      final stats = calculateLibraryStats(entries);

      expect(stats.mostWatchedYear, 2024);
    });

    test('a tie between years is broken by the more recent one', () {
      final entries = [
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(1),
          watchedAt: DateTime(2022, 1, 1),
        ),
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(2),
          watchedAt: DateTime(2022, 6, 1),
        ),
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(3),
          watchedAt: DateTime(2024, 1, 1),
        ),
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(4),
          watchedAt: DateTime(2024, 6, 1),
        ),
      ];

      final stats = calculateLibraryStats(entries);

      expect(stats.mostWatchedYear, 2024);
    });

    test('is null when nothing is watched', () {
      final stats = calculateLibraryStats(const []);

      expect(stats.mostWatchedYear, isNull);
    });
  });

  group('calculateLibraryStats — monthlyActivity', () {
    test('buckets entries into the trailing 12 months, oldest first', () {
      final now = DateTime(2024, 6, 15);
      final entries = [
        // Current month.
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(1),
          watchedAt: DateTime(2024, 6, 1),
        ),
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(2),
          watchedAt: DateTime(2024, 6, 10),
        ),
        // 11 months ago — the oldest month still in the window.
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(3),
          watchedAt: DateTime(2023, 7, 1),
        ),
        // Outside the 12-month window entirely.
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(4),
          watchedAt: DateTime(2023, 1, 1),
        ),
      ];

      final stats = calculateLibraryStats(entries, now: now);

      expect(stats.monthlyActivity, hasLength(12));
      expect(stats.monthlyActivity.first, 1); // 2023-07, oldest slot.
      expect(stats.monthlyActivity.last, 2); // 2024-06, current month.
      expect(
        stats.monthlyActivity.reduce((a, b) => a + b),
        3, // The 2023-01 entry falls outside the window.
      );
    });
  });

  group('topGenres', () {
    test('ranks by count, most-watched first', () {
      final ranked = topGenres({_action: 5, _drama: 2, _comedy: 8});

      expect(ranked, [(_comedy, 8), (_action, 5), (_drama, 2)]);
    });

    test('breaks a count tie alphabetically by name, deterministically', () {
      final ranked = topGenres({_drama: 3, _action: 3, _comedy: 1});

      // Action before Drama (same count, "Action" < "Drama"), Comedy last.
      expect(ranked, [(_action, 3), (_drama, 3), (_comedy, 1)]);
    });

    test('caps at limit (5 by default, matching C4\'s "list of 5")', () {
      final counts = {
        for (var i = 0; i < 8; i++) Genre(id: 'g$i', name: 'Genre $i'): i,
      };

      final ranked = topGenres(counts);

      expect(ranked, hasLength(5));
    });

    test('an empty map ranks to an empty list, not an error', () {
      expect(topGenres(const {}), isEmpty);
    });
  });

  group('calculateLibraryStats — topGenres', () {
    test("counts each watched entry's genres once each and ranks them, "
        'most-watched first', () {
      final entries = [
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(1),
          watchedAt: DateTime(2024, 1, 1),
          genres: const [_action, _drama],
        ),
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(2),
          watchedAt: DateTime(2024, 1, 1),
          genres: const [_action],
        ),
        UserMediaEntry(
          title: 'Test Title',
          key: _tvShow(1),
          watchedAt: DateTime(2024, 1, 1),
          genres: const [_comedy],
        ),
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(3),
          watchedAt: DateTime(2024, 1, 1),
          genres: const [_action, _comedy],
        ),
      ];
      // Action: 3 (movies 1, 2, 3) · Comedy: 2 (tvShow 1, movie 3) ·
      // Drama: 1 (movie 1).

      final stats = calculateLibraryStats(entries);

      expect(stats.topGenres, [(_action, 3), (_comedy, 2), (_drama, 1)]);
    });

    test("an unwatched entry's genres never count", () {
      final entries = [
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(1),
          isFavorite: true,
          genres: const [_action],
        ),
      ];

      final stats = calculateLibraryStats(entries);

      expect(stats.topGenres, isEmpty);
    });

    test('an entry with no genres at all (saved before that field existed) '
        "simply doesn't contribute, rather than breaking the ranking", () {
      final entries = [
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(1),
          watchedAt: DateTime(2024, 1, 1),
        ),
        UserMediaEntry(
          title: 'Test Title',
          key: _movie(2),
          watchedAt: DateTime(2024, 1, 1),
          genres: const [_drama],
        ),
      ];

      final stats = calculateLibraryStats(entries);

      expect(stats.topGenres, [(_drama, 1)]);
    });
  });
}
