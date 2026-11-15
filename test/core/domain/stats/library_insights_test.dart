import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/core/domain/stats/library_insights.dart';
import 'package:movies/core/domain/stats/library_insights_calculator.dart';
import 'package:movies/core/domain/stats/stats_period.dart';

// A Saturday in November 2026.
final _now = DateTime(2026, 11, 14, 12);

const _drama = Genre(id: 'drama');
const _scifi = Genre(id: 'sci-fi');

UserMediaEntry _w(
  int id, {
  required DateTime at,
  MediaType type = MediaType.movie,
  int? minutes,
  int? episodes,
  int? episodeMinutes,
  int? rating,
  double? vote,
  int? year,
  List<Genre> genres = const [],
}) => UserMediaEntry(
  key: MediaKey(type: type, tmdbId: id),
  title: 'T$id',
  watchedAt: at,
  runtimeMinutes: minutes,
  episodeCount: episodes,
  episodeRuntimeMinutes: episodeMinutes,
  rating: rating,
  voteAverage: vote,
  year: year,
  genres: genres,
);

LibraryInsights _i(
  List<UserMediaEntry> entries, {
  StatsPeriod period = StatsPeriod.allTime,
}) => calculateInsights(entries, period: period, now: _now);

void main() {
  group('periods', () {
    final entries = [
      _w(1, at: DateTime(2026, 11, 3)), // this month
      _w(2, at: DateTime(2026, 5, 1)), // this year, not this month
      _w(3, at: DateTime(2025, 12, 31)), // last year
      _w(4, at: DateTime(2025, 10, 5)), // last year
    ];

    test('all time counts everything', () {
      final i = _i(entries);
      expect(i.watchedCount, 4);
      expect(i.previousCount, isNull);
    });

    test('this year: only the current calendar year; compared with last '
        'year', () {
      final i = _i(entries, period: StatsPeriod.thisYear);
      expect(i.watchedCount, 2);
      expect(i.previousCount, 2);
    });

    test('this month: only the current month; compared with last month', () {
      final i = _i(entries, period: StatsPeriod.thisMonth);
      expect(i.watchedCount, 1);
      expect(i.previousCount, 0);
    });

    test('this month early in January compares with December of last '
        'year', () {
      final i = calculateInsights(
        [_w(1, at: DateTime(2025, 12, 20)), _w(2, at: DateTime(2026, 1, 3))],
        period: StatsPeriod.thisMonth,
        now: DateTime(2026, 1, 10),
      );
      expect(i.watchedCount, 1);
      expect(i.previousCount, 1);
    });

    test('the three periods are distinct sets', () {
      // In November "this year" is not "the last 12 months": May 2025 is in the
      // trailing window but not this year.
      final i = _i([
        _w(1, at: DateTime(2025, 12, 5)),
      ], period: StatsPeriod.thisYear);
      expect(i.watchedCount, 0);
    });
  });

  group('hours and types', () {
    test('movie hours, show hours (episodes × runtime, 45 min fallback), '
        'episodes', () {
      final i = _i([
        _w(1, at: DateTime(2026, 11, 1), minutes: 120),
        _w(2, at: DateTime(2026, 11, 1), minutes: 60),
        _w(
          3,
          at: DateTime(2026, 11, 1),
          type: MediaType.tvShow,
          episodes: 10,
          episodeMinutes: 30,
        ),
        _w(4, at: DateTime(2026, 11, 1), type: MediaType.tvShow, episodes: 4),
      ]);
      expect(i.moviesWatched, 2);
      expect(i.showsWatched, 2);
      expect(i.movieHours, 3);
      expect(i.tvHours, (300 + 180) / 60);
      expect(i.totalHours, 3 + 8);
      expect(i.episodesWatched, 14);
    });
  });

  group('activity series', () {
    test('all time: the 12 months ending now, oldest first', () {
      final i = _i([
        _w(1, at: DateTime(2026, 11, 2)),
        _w(2, at: DateTime(2026, 11, 9)),
        _w(3, at: DateTime(2025, 12, 1)),
        _w(4, at: DateTime(2025, 11, 30)), // 12 months back: out
      ]);
      expect(i.activity.unit, ActivityUnit.month);
      expect(i.activity.start, DateTime(2025, 12, 1));
      expect(i.activity.counts, hasLength(12));
      expect(i.activity.counts.first, 1);
      expect(i.activity.counts.last, 2);
    });

    test('this year: Jan to Dec of this year', () {
      final i = _i([
        _w(1, at: DateTime(2026, 1, 5)),
        _w(2, at: DateTime(2026, 11, 5)),
        _w(3, at: DateTime(2025, 11, 5)),
      ], period: StatsPeriod.thisYear);
      expect(i.activity.start, DateTime(2026, 1, 1));
      expect(i.activity.counts[0], 1);
      expect(i.activity.counts[10], 1);
      expect(i.activity.counts.fold<int>(0, (a, b) => a + b), 2);
    });

    test('this month: one bar per day of the month', () {
      final i = _i([
        _w(1, at: DateTime(2026, 11, 1)),
        _w(2, at: DateTime(2026, 11, 1)),
        _w(3, at: DateTime(2026, 11, 30)),
      ], period: StatsPeriod.thisMonth);
      expect(i.activity.unit, ActivityUnit.day);
      expect(i.activity.counts, hasLength(30));
      expect(i.activity.counts[0], 2);
      expect(i.activity.counts[29], 1);
    });
  });

  group('calendar', () {
    test('all time: from the Monday 25 weeks back to today', () {
      final i = _i(const []);
      expect(i.calendarEnd, DateTime(2026, 11, 14));
      expect(i.calendarStart.weekday, DateTime.monday);
      expect(
        i.calendarEnd.difference(i.calendarStart).inDays,
        7 * 25 + 5, // 25 weeks and the Monday..Saturday of this one
      );
    });

    test('this year / this month cover the whole span; days are counted '
        'date-only', () {
      final year = _i([
        _w(1, at: DateTime(2026, 3, 3, 9)),
        _w(2, at: DateTime(2026, 3, 3, 23)),
      ], period: StatsPeriod.thisYear);
      expect(year.calendarStart, DateTime(2026, 1, 1));
      expect(year.calendarEnd, DateTime(2026, 12, 31));
      expect(year.dayCounts[DateTime(2026, 3, 3)], 2);

      final month = _i(const [], period: StatsPeriod.thisMonth);
      expect(month.calendarStart, DateTime(2026, 11, 1));
      expect(month.calendarEnd, DateTime(2026, 11, 30));
    });
  });

  group('highlights', () {
    test('busiest month (ties to the more recent)', () {
      final i = _i([
        _w(1, at: DateTime(2026, 3, 1)),
        _w(2, at: DateTime(2026, 3, 9)),
        _w(3, at: DateTime(2026, 8, 1)),
        _w(4, at: DateTime(2026, 8, 2)),
        _w(5, at: DateTime(2026, 9, 1)),
      ]);
      expect(i.busiestMonth!.month, 8);
      expect(i.busiestMonth!.count, 2);
    });

    test('streaks are of the whole library, whatever the period', () {
      final entries = [
        _w(1, at: DateTime(2026, 11, 10)), // this week
        _w(2, at: DateTime(2026, 11, 3)),
        _w(3, at: DateTime(2026, 10, 27)),
        _w(4, at: DateTime(2026, 6, 1)),
        _w(5, at: DateTime(2026, 6, 8)),
        _w(6, at: DateTime(2026, 6, 15)),
        _w(7, at: DateTime(2026, 6, 22)),
      ];
      final month = _i(entries, period: StatsPeriod.thisMonth);
      expect(month.currentStreakWeeks, 3);
      expect(month.longestStreakWeeks, 4);
    });

    test('longest movie and longest show', () {
      final i = _i([
        _w(1, at: DateTime(2026, 11, 1), minutes: 100),
        _w(2, at: DateTime(2026, 11, 1), minutes: 180),
        _w(
          3,
          at: DateTime(2026, 11, 1),
          type: MediaType.tvShow,
          episodes: 8,
          episodeMinutes: 50,
        ),
        _w(4, at: DateTime(2026, 11, 1), type: MediaType.tvShow),
      ]);
      expect(i.longestMovie!.entry.key.tmdbId, 2);
      expect(i.longestMovie!.minutes, 180);
      expect(i.longestShow!.entry.key.tmdbId, 3);
      expect(i.longestShow!.minutes, 400);
    });

    test('nothing with a duration: no longest title', () {
      final i = _i([_w(1, at: DateTime(2026, 11, 1))]);
      expect(i.longestMovie, isNull);
      expect(i.longestShow, isNull);
    });

    test('best rated: the highest, the latest watched among ties', () {
      final i = _i([
        _w(1, at: DateTime(2026, 11, 1), rating: 5),
        _w(2, at: DateTime(2026, 11, 9), rating: 5),
        _w(3, at: DateTime(2026, 11, 12), rating: 4),
        _w(4, at: DateTime(2026, 11, 13)),
      ]);
      expect(i.bestRated!.key.tmdbId, 2);
      expect(_i([_w(1, at: DateTime(2026, 11, 1))]).bestRated, isNull);
    });

    test('the Watch later backlog: unwatched ones only, with the hours they '
        'add up to', () {
      final i = _i([
        UserMediaEntry(
          key: const MediaKey(type: MediaType.movie, tmdbId: 1),
          title: 'A',
          isWatchLater: true,
          runtimeMinutes: 120,
        ),
        UserMediaEntry(
          key: const MediaKey(type: MediaType.tvShow, tmdbId: 2),
          title: 'B',
          isWatchLater: true,
          episodeCount: 6,
          episodeRuntimeMinutes: 60,
        ),
        UserMediaEntry(
          key: const MediaKey(type: MediaType.movie, tmdbId: 3),
          title: 'C',
          isWatchLater: true,
        ),
        _w(
          4,
          at: DateTime(2026, 11, 1),
          minutes: 999,
        ).copyWith(isWatchLater: true),
      ]);
      expect(i.watchLaterCount, 3); // the watched one is not backlog
      expect(i.watchLaterHours, (120 + 360) / 60);
    });
  });

  group('ratings', () {
    test('histogram, average, TMDB average and the gap', () {
      final i = _i([
        _w(1, at: DateTime(2026, 11, 1), rating: 5, vote: 8), // 4.0
        _w(2, at: DateTime(2026, 11, 1), rating: 3, vote: 8), // 4.0
        _w(3, at: DateTime(2026, 11, 1), rating: 5), // no TMDB score
      ]);
      expect(i.ratingCounts, [0, 0, 1, 0, 2]);
      expect(i.averageRating, closeTo(13 / 3, 0.001));
      expect(i.tmdbAverage, 4.0);
      expect(i.ratingGap, 0); // +1 and -1
    });

    test('disagreements: at least a star apart, widest first, at most 3', () {
      final i = _i([
        _w(1, at: DateTime(2026, 11, 1), rating: 5, vote: 4), // +3
        _w(2, at: DateTime(2026, 11, 1), rating: 1, vote: 8), // -3
        _w(3, at: DateTime(2026, 11, 1), rating: 5, vote: 6), // +2
        _w(4, at: DateTime(2026, 11, 1), rating: 4, vote: 6), // +1
        _w(5, at: DateTime(2026, 11, 1), rating: 4, vote: 7.5), // +0.25: no
      ]);
      expect(i.disagreements, hasLength(3));
      expect(i.disagreements.first.difference.abs(), 3);
      expect(i.disagreements.map((d) => d.entry.key.tmdbId).toSet(), {1, 2, 3});
    });

    test('no ratings: empty histogram, null averages', () {
      final i = _i([_w(1, at: DateTime(2026, 11, 1))]);
      expect(i.ratingCounts, [0, 0, 0, 0, 0]);
      expect(i.averageRating, isNull);
      expect(i.tmdbAverage, isNull);
      expect(i.ratingGap, isNull);
      expect(i.disagreements, isEmpty);
    });
  });

  group('genres, decades, coverage', () {
    test('every genre ranked; the total is every tag counted', () {
      final i = _i([
        _w(1, at: DateTime(2026, 11, 1), genres: [_drama, _scifi]),
        _w(2, at: DateTime(2026, 11, 1), genres: [_drama]),
      ]);
      expect(i.genres, [(_drama, 2), (_scifi, 1)]);
      expect(i.genreTotal, 3);
    });

    test('titles by release decade, oldest first; no year, no decade', () {
      final i = _i([
        _w(1, at: DateTime(2026, 11, 1), year: 2014),
        _w(2, at: DateTime(2026, 11, 1), year: 2011),
        _w(3, at: DateTime(2026, 11, 1), year: 1999),
        _w(4, at: DateTime(2026, 11, 1)),
      ]);
      expect(i.decades, [(1990, 1), (2010, 2)]);
    });

    test('complete titles have genres, a year and a duration', () {
      final i = _i([
        _w(
          1,
          at: DateTime(2026, 11, 1),
          genres: [_drama],
          year: 2020,
          minutes: 90,
        ),
        _w(2, at: DateTime(2026, 11, 1), genres: [_drama], year: 2020),
        _w(3, at: DateTime(2026, 11, 1)),
      ]);
      expect(i.watchedCount, 3);
      expect(i.completeCount, 1);
    });

    test('the genre figures follow the period', () {
      final i = _i([
        _w(1, at: DateTime(2026, 11, 1), genres: [_drama]),
        _w(2, at: DateTime(2025, 1, 1), genres: [_scifi]),
      ], period: StatsPeriod.thisYear);
      expect(i.genres, [(_drama, 1)]);
    });
  });
}
