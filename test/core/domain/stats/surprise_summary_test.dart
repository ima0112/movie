import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/surprise_history_entry.dart';
import 'package:movies/core/domain/entities/surprise_session.dart';
import 'package:movies/core/domain/stats/library_stats.dart';
import 'package:movies/core/domain/stats/surprise_summary.dart';
import 'package:movies/features/you/presentation/widgets/you_stats_mode.dart';

SurpriseSession _session(String id) => SurpriseSession(
  sessionId: id,
  startedAt: DateTime(2026, 11, 20),
  mediaType: MediaType.movie,
  source: SurpriseSessionSource.profile,
  yearFrom: 2000,
);

SurpriseHistoryEntry _entry(int id, SurpriseOutcome outcome) =>
    SurpriseHistoryEntry(
      key: MediaKey(type: MediaType.movie, tmdbId: id),
      sessionId: 'a',
      shownAt: DateTime(2026, 11, 20),
      batch: 1,
      genres: const <Genre>[],
      outcome: outcome,
    );

LibraryStats _library(int watched) => LibraryStats(
  moviesWatched: watched,
  tvShowsWatched: 0,
  movieHours: 0,
  estimatedTvHours: 0,
  averageRating: null,
  topGenres: const [],
  mostWatchedYear: null,
  monthlyActivity: List.filled(12, 0),
);

void main() {
  group('calculateSurpriseSummary', () {
    test('no sessions: nothing', () {
      final s = calculateSurpriseSummary(sessions: const [], history: const []);
      expect(s.sessions, 0);
      expect(s.picks, 0);
      expect(s.hasActivity, isFalse);
    });

    test('one session with nothing chosen is activity: 1 session, 0 picks', () {
      final s = calculateSurpriseSummary(
        sessions: [_session('a')],
        history: [_entry(1, SurpriseOutcome.viewed)],
      );
      expect(s.sessions, 1);
      expect(s.picks, 0);
      expect(s.hasActivity, isTrue);
    });

    test('picks count the chosen cards only', () {
      final s = calculateSurpriseSummary(
        sessions: [_session('a'), _session('b')],
        history: [
          _entry(1, SurpriseOutcome.chosen),
          _entry(2, SurpriseOutcome.chosen),
          _entry(3, SurpriseOutcome.rerolled),
          _entry(4, SurpriseOutcome.viewed),
        ],
      );
      expect(s.sessions, 2);
      expect(s.picks, 2);
    });
  });

  group('youStatsMode', () {
    const some = SurpriseSummary(sessions: 2, picks: 1);
    const none = SurpriseSummary(sessions: 0, picks: 0);

    test('nothing known, or nothing there: hidden', () {
      expect(youStatsMode(library: null, surprise: null), YouStatsMode.hidden);
      expect(
        youStatsMode(library: _library(0), surprise: none),
        YouStatsMode.hidden,
      );
      // Not out of the woods while one source is unread, but no activity is
      // known either: still hidden, not a skeleton.
      expect(
        youStatsMode(library: _library(0), surprise: null),
        YouStatsMode.hidden,
      );
      expect(youStatsMode(library: null, surprise: none), YouStatsMode.hidden);
    });

    test('something watched: the library; with the other source still unread '
        'a skeleton', () {
      expect(
        youStatsMode(library: _library(3), surprise: none),
        YouStatsMode.library,
      );
      expect(
        youStatsMode(library: _library(3), surprise: null),
        YouStatsMode.loading,
      );
    });

    test(
      'only Surprise me: its summary; with the library unread a skeleton',
      () {
        expect(
          youStatsMode(library: _library(0), surprise: some),
          YouStatsMode.surprise,
        );
        expect(
          youStatsMode(library: null, surprise: some),
          YouStatsMode.loading,
        );
      },
    );

    test('both', () {
      expect(
        youStatsMode(library: _library(3), surprise: some),
        YouStatsMode.both,
      );
    });
  });
}
