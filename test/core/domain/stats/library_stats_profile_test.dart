import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/core/domain/stats/library_stats_calculator.dart';
import 'package:movies/core/domain/stats/viewer_label.dart';

const _scifi = Genre(id: 'sciFi');
const _drama = Genre(id: 'drama');
const _comedy = Genre(id: 'comedy');

// A Friday.
final _now = DateTime(2026, 11, 13, 12);

UserMediaEntry _watched(
  int id, {
  DateTime? at,
  MediaType type = MediaType.movie,
  int? rating,
  List<Genre> genres = const [],
  bool favorite = false,
  bool later = false,
}) => UserMediaEntry(
  key: MediaKey(type: type, tmdbId: id),
  title: 'T$id',
  watchedAt: at ?? DateTime(2026, 11, 10),
  rating: rating,
  genres: genres,
  isFavorite: favorite,
  isWatchLater: later,
);

void main() {
  group('genre shares', () {
    test('every genre tag counts: the shares of all genres add up to 100', () {
      final stats = calculateLibraryStats([
        _watched(1, genres: [_scifi, _drama]),
        _watched(2, genres: [_scifi]),
        _watched(3, genres: [_comedy]),
      ], now: _now);

      expect(stats.genreTotal, 4);
      expect(stats.genreShareOf(2), 50); // sci-fi
      expect(stats.genreShareOf(1), 25);
    });

    test('no genres counted: 0, not a division by zero', () {
      final stats = calculateLibraryStats([_watched(1)], now: _now);
      expect(stats.genreShareOf(3), 0);
    });
  });

  group('recentlyWatched', () {
    test('newest first, at most 6, watched titles only', () {
      final entries = [
        for (var i = 1; i <= 8; i++) _watched(i, at: DateTime(2026, 10, i)),
        const UserMediaEntry(
          key: MediaKey(type: MediaType.movie, tmdbId: 99),
          title: 'Not watched',
          isFavorite: true,
        ),
      ];

      final recent = calculateLibraryStats(entries, now: _now).recentlyWatched;

      expect(recent.map((e) => e.key.tmdbId), [8, 7, 6, 5, 4, 3]);
    });
  });

  group('weeklyStreak', () {
    // Weeks start on Monday: 2026-11-09 is the week of _now.
    test('counts consecutive weeks up to this one', () {
      final entries = [
        _watched(1, at: DateTime(2026, 11, 10)), // this week
        _watched(2, at: DateTime(2026, 11, 3)), // last week
        _watched(3, at: DateTime(2026, 10, 27)), // the one before
      ];
      expect(weeklyStreak(entries, _now), 3);
    });

    test('this week still empty: the streak holds from last week', () {
      final entries = [
        _watched(1, at: DateTime(2026, 11, 5)),
        _watched(2, at: DateTime(2026, 10, 29)),
      ];
      expect(weeklyStreak(entries, _now), 2);
    });

    test('a skipped week breaks it', () {
      final entries = [
        _watched(1, at: DateTime(2026, 11, 10)),
        _watched(2, at: DateTime(2026, 10, 27)), // two weeks back; gap between
      ];
      expect(weeklyStreak(entries, _now), 1);
    });

    test('nothing in this or last week: 0', () {
      expect(weeklyStreak([_watched(1, at: DateTime(2026, 9, 1))], _now), 0);
      expect(weeklyStreak(const [], _now), 0);
    });

    test('Sunday and the next Monday are different weeks', () {
      final entries = [
        _watched(1, at: DateTime(2026, 11, 8)), // Sunday, week of the 2nd
        _watched(2, at: DateTime(2026, 11, 9)), // Monday, week of the 9th
      ];
      expect(weeklyStreak(entries, _now), 2);
    });
  });

  group('library counts', () {
    test('favorites and watch later, with the type filter', () {
      final entries = [
        _watched(1, favorite: true),
        _watched(2, type: MediaType.tvShow, favorite: true),
        UserMediaEntry(
          key: const MediaKey(type: MediaType.movie, tmdbId: 3),
          title: 'Later',
          isWatchLater: true,
        ),
      ];

      final all = calculateLibraryStats(entries, now: _now);
      expect(all.favoritesCount, 2);
      expect(all.watchLaterCount, 1);

      final tv = calculateLibraryStats(
        entries,
        filterType: MediaType.tvShow,
        now: _now,
      );
      expect(tv.favoritesCount, 1);
      expect(tv.watchLaterCount, 0);
    });

    test('totals and the month figures', () {
      final stats = calculateLibraryStats([
        _watched(1, at: DateTime(2026, 11, 2)),
        _watched(2, at: DateTime(2026, 11, 5)),
        _watched(3, at: DateTime(2026, 10, 20)),
      ], now: _now);

      expect(stats.watchedCount, 3);
      expect(stats.watchedThisMonth, 2);
      expect(stats.watchedLastMonth, 1);
    });
  });

  group('viewerLabel', () {
    ViewerLabel? label(List<UserMediaEntry> entries) =>
        calculateLibraryStats(entries, now: _now).viewerLabel;

    test('nothing watched: no label', () {
      expect(label(const []), isNull);
    });

    test('under 5 titles: newcomer', () {
      expect(
        label([
          for (var i = 1; i <= 4; i++) _watched(i, genres: [_scifi]),
        ]),
        const ViewerLabel(ViewerKind.newcomer),
      );
    });

    test('mostly TV: series binger', () {
      expect(
        label([
          for (var i = 1; i <= 4; i++) _watched(i, type: MediaType.tvShow),
          _watched(5),
        ]),
        const ViewerLabel(ViewerKind.seriesBinger),
      );
    });

    test('low and high average rating', () {
      expect(
        label([for (var i = 1; i <= 5; i++) _watched(i, rating: 2)]),
        const ViewerLabel(ViewerKind.exigentCritic),
      );
      expect(
        label([for (var i = 1; i <= 5; i++) _watched(i, rating: 5)]),
        const ViewerLabel(ViewerKind.enthusiast),
      );
    });

    test('fewer than 5 ratings never make a critic', () {
      final entries = [
        for (var i = 1; i <= 4; i++) _watched(i, rating: 1),
        _watched(5),
      ];
      expect(label(entries)!.kind, isNot(ViewerKind.exigentCritic));
    });

    test('a genre with 30% or more of the tags: fan of that genre', () {
      expect(
        label([
          for (var i = 1; i <= 3; i++) _watched(i, genres: [_scifi]),
          _watched(4, genres: [_drama]),
          _watched(5, genres: [_comedy]),
        ]),
        const ViewerLabel(ViewerKind.genreFan, _scifi),
      );
    });

    test('mostly movies with no standout genre: cinephile; otherwise '
        'explorer', () {
      expect(
        label([for (var i = 1; i <= 5; i++) _watched(i)]),
        const ViewerLabel(ViewerKind.cinephile),
      );
      expect(
        label([
          for (var i = 1; i <= 3; i++) _watched(i),
          for (var i = 4; i <= 6; i++) _watched(i, type: MediaType.tvShow),
        ]),
        const ViewerLabel(ViewerKind.explorer),
      );
    });
  });
}
