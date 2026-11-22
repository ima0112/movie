import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/surprise_history_entry.dart';
import 'package:movies/core/domain/entities/surprise_session.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/core/domain/stats/stats_period.dart';
import 'package:movies/core/domain/stats/surprise_insights.dart';
import 'package:movies/core/domain/stats/surprise_insights_calculator.dart';

const _action = Genre(id: 'action');
const _drama = Genre(id: 'drama');
const _western = Genre(id: 'western');
const _anime = Genre(id: 'animation');

final _now = DateTime(2026, 11, 18); // a Wednesday

MediaKey _m(int id) => MediaKey(type: MediaType.movie, tmdbId: id);
MediaKey _s(int id) => MediaKey(type: MediaType.tvShow, tmdbId: id);

SurpriseSession _session(
  String id,
  DateTime at, {
  SurpriseSessionSource source = SurpriseSessionSource.quiz,
  Set<String> collections = const {},
  Set<String> vibes = const {},
  Set<String> relaxations = const {},
}) => SurpriseSession(
  sessionId: id,
  startedAt: at,
  mediaType: MediaType.movie,
  source: source,
  yearFrom: 1950,
  collectionIds: collections,
  vibeIds: vibes,
  relaxations: relaxations,
);

SurpriseHistoryEntry _h(
  MediaKey key,
  String session,
  DateTime at, {
  SurpriseOutcome outcome = SurpriseOutcome.viewed,
  int batch = 1,
  List<Genre> genres = const [],
}) => SurpriseHistoryEntry(
  key: key,
  sessionId: session,
  shownAt: at,
  outcome: outcome,
  batch: batch,
  genres: genres,
);

UserMediaEntry _lib(
  MediaKey key,
  String title, {
  bool watched = false,
  bool later = false,
  bool favorite = false,
  int? rating,
  List<Genre> genres = const [],
}) => UserMediaEntry(
  key: key,
  title: title,
  isFavorite: favorite,
  isWatchLater: later,
  watchedAt: watched || rating != null ? DateTime(2026, 11, 10) : null,
  rating: rating,
  genres: genres,
);

SurpriseInsights _calc({
  List<SurpriseHistoryEntry> history = const [],
  List<SurpriseSession> sessions = const [],
  List<UserMediaEntry> library = const [],
  StatsPeriod period = StatsPeriod.allTime,
}) => calculateSurpriseInsights(
  history: history,
  sessions: sessions,
  library: library,
  period: period,
  now: _now,
);

void main() {
  final nov = DateTime(2026, 11, 3);
  final oct = DateTime(2026, 10, 12);
  final lastYear = DateTime(2025, 6, 1);

  test('nothing at all: empty, no blocks, but a habit shell', () {
    final r = _calc();
    expect(r.isEmpty, isTrue);
    expect(r.hitRate, isNull);
    expect(r.afterChoosing, isNull);
    expect(r.asked, isNull);
    expect(r.genres, isEmpty);
    expect(r.habit.byMonth, hasLength(12));
    expect(r.habit.byWeekday, everyElement(0));
  });

  group('1. does it work for me', () {
    test('sessions, how many ended in a choice, a save only, and in which '
        'batch they were decided', () {
      final r = _calc(
        sessions: [
          _session('a', nov),
          _session('b', nov),
          _session('c', nov),
          _session('d', nov),
        ],
        history: [
          _h(_m(1), 'a', nov, outcome: SurpriseOutcome.chosen, batch: 1),
          _h(_m(2), 'b', nov, outcome: SurpriseOutcome.chosen, batch: 3),
          _h(_m(3), 'b', nov, batch: 1),
          _h(_m(4), 'c', nov, outcome: SurpriseOutcome.saved),
          _h(_m(5), 'd', nov, outcome: SurpriseOutcome.rerolled),
        ],
      );
      final h = r.hitRate!;
      expect(h.sessions, 4);
      expect(h.chosenSessions, 2);
      expect(h.savedOnlySessions, 1);
      expect(h.rate, 0.5);
      expect(h.chosenInFirstBatch, 1);
      expect(h.averageBatchesToChoose, 2);
      expect(h.batchesToChoose, {1: 1, 2: 0, 3: 1});
    });

    test('a batch past the third counts in the last bucket', () {
      final r = _calc(
        sessions: [_session('a', nov)],
        history: [
          _h(_m(1), 'a', nov, outcome: SurpriseOutcome.chosen, batch: 6),
        ],
      );
      expect(r.hitRate!.batchesToChoose[3], 1);
      expect(r.hitRate!.averageBatchesToChoose, 6);
    });

    test('periods: a session belongs to the period of its start', () {
      final sessions = [
        _session('now', nov),
        _session('old', oct),
        _session('ancient', lastYear),
      ];
      expect(_calc(sessions: sessions).hitRate!.sessions, 3);
      expect(
        _calc(
          sessions: sessions,
          period: StatsPeriod.thisYear,
        ).hitRate!.sessions,
        2,
      );
      expect(
        _calc(
          sessions: sessions,
          period: StatsPeriod.thisMonth,
        ).hitRate!.sessions,
        1,
      );
    });
  });

  group('2. what happened to what I chose', () {
    test('watched, still waiting, rated: counts, the mean and the best', () {
      final r = _calc(
        sessions: [_session('a', nov), _session('b', nov)],
        history: [
          _h(_m(1), 'a', nov, outcome: SurpriseOutcome.chosen),
          _h(_m(2), 'a', nov, outcome: SurpriseOutcome.chosen),
          _h(_s(3), 'b', nov, outcome: SurpriseOutcome.chosen),
          _h(_m(4), 'b', nov, outcome: SurpriseOutcome.chosen),
        ],
        library: [
          _lib(_m(1), 'Alpha', rating: 5),
          _lib(_m(2), 'Beta', rating: 3),
          _lib(_s(3), 'Gamma', later: true),
          // 4 was never saved: it counts as chosen, nothing more
        ],
      );
      final a = r.afterChoosing!;
      expect(a.chosen, 4);
      expect(a.watched, 2);
      expect(a.stillInWatchLater, 1);
      expect(a.rated, 2);
      expect(a.averageRating, 4);
      expect(a.watchedRate, 0.5);
      expect(a.best.map((t) => t.title), ['Alpha', 'Beta']);
    });

    test('the same title chosen in two sessions counts once', () {
      final r = _calc(
        sessions: [_session('a', nov), _session('b', oct)],
        history: [
          _h(_m(1), 'a', nov, outcome: SurpriseOutcome.chosen),
          _h(_m(1), 'b', oct, outcome: SurpriseOutcome.chosen),
        ],
        library: [_lib(_m(1), 'Alpha', rating: 4)],
      );
      expect(r.afterChoosing!.chosen, 1);
    });

    test('nothing chosen: no block', () {
      final r = _calc(
        sessions: [_session('a', nov)],
        history: [_h(_m(1), 'a', nov)],
      );
      expect(r.afterChoosing, isNull);
    });
  });

  group('3. discoveries', () {
    test('a chosen genre the user never watched or favorited on their own; '
        'rated ones first', () {
      final r = _calc(
        sessions: [_session('a', nov)],
        history: [
          _h(
            _m(1),
            'a',
            nov,
            outcome: SurpriseOutcome.chosen,
            genres: [_action, _western],
          ),
          _h(
            _m(2),
            'a',
            nov,
            outcome: SurpriseOutcome.chosen,
            genres: [_drama],
          ),
          _h(
            _m(3),
            'a',
            nov,
            outcome: SurpriseOutcome.chosen,
            genres: [_anime],
          ),
        ],
        library: [
          _lib(_m(10), 'Usual', watched: true, genres: [_action, _drama]),
          _lib(_m(1), 'Cowboy', rating: 5, genres: [_action, _western]),
          _lib(_m(2), 'Plain', later: true, genres: [_drama]),
          _lib(_m(3), 'Cartoon', later: true, genres: [_anime]),
        ],
      );
      expect(r.discoveries.map((d) => d.title), ['Cowboy', 'Cartoon']);
      expect(r.discoveries.first.newGenres, [_western]);
      expect(r.discoveries.first.rating, 5);
      expect(r.discoveries.last.rating, isNull);
    });

    test(
      'what Surprise me itself handed over does not make a genre "usual"',
      () {
        // The only watched title with the genre is the chosen one itself.
        final r = _calc(
          sessions: [_session('a', nov)],
          history: [
            _h(
              _m(1),
              'a',
              nov,
              outcome: SurpriseOutcome.chosen,
              genres: [_western],
            ),
          ],
          library: [
            _lib(_m(1), 'Cowboy', rating: 4, genres: [_western]),
            _lib(_m(10), 'Usual', watched: true, genres: [_drama]),
          ],
        );
        expect(r.discoveries.single.title, 'Cowboy');
      },
    );

    test('no history of one\'s own: nothing to compare with, none', () {
      final r = _calc(
        sessions: [_session('a', nov)],
        history: [
          _h(
            _m(1),
            'a',
            nov,
            outcome: SurpriseOutcome.chosen,
            genres: [_western],
          ),
        ],
        library: [
          _lib(_m(1), 'Cowboy', rating: 4, genres: [_western]),
        ],
      );
      expect(r.discoveries, isEmpty);
    });

    test('at most three', () {
      final r = _calc(
        sessions: [_session('a', nov)],
        history: [
          for (var i = 1; i <= 5; i++)
            _h(
              _m(i),
              'a',
              nov,
              outcome: SurpriseOutcome.chosen,
              genres: [_western],
            ),
        ],
        library: [
          _lib(_m(10), 'Usual', watched: true, genres: [_drama]),
          for (var i = 1; i <= 5; i++) _lib(_m(i), 'T$i', later: true),
        ],
      );
      expect(r.discoveries, hasLength(3));
    });
  });

  group('4. genres and type', () {
    test('by chosen, then shown; movies against shows', () {
      final r = _calc(
        sessions: [_session('a', nov)],
        history: [
          _h(
            _m(1),
            'a',
            nov,
            outcome: SurpriseOutcome.chosen,
            genres: [_action, _drama],
          ),
          _h(
            _s(2),
            'a',
            nov,
            outcome: SurpriseOutcome.chosen,
            genres: [_drama],
          ),
          _h(_m(3), 'a', nov, genres: [_action]),
          _h(_m(4), 'a', nov, genres: [_action]),
        ],
      );
      expect(r.genres.map((g) => (g.genre, g.chosen, g.shown)).toList(), [
        (_drama, 2, 2),
        (_action, 1, 3),
      ]);
      expect(r.typeSplit.movies, 1);
      expect(r.typeSplit.shows, 1);
      expect(r.typeSplit.total, 2);
    });
  });

  group('5. what I ask for', () {
    test('collections and vibes: asked, and how often a choice followed, '
        'most asked first', () {
      final r = _calc(
        sessions: [
          _session('a', nov, collections: {'anime'}, vibes: {'revenge'}),
          _session(
            'b',
            nov,
            collections: {'anime'},
            vibes: {'revenge', 'heist'},
          ),
          _session('c', nov, collections: {'soaps'}),
        ],
        history: [
          _h(_m(1), 'a', nov, outcome: SurpriseOutcome.chosen),
          _h(_m(2), 'b', nov),
        ],
      );
      final asked = r.asked!;
      expect(
        asked.collections.map((c) => (c.id, c.sessions, c.chosenSessions)),
        [('anime', 2, 1), ('soaps', 1, 0)],
      );
      expect(asked.collections.first.rate, 0.5);
      expect(asked.vibes.first.id, 'revenge');
      expect(asked.vibes.first.sessions, 2);
    });

    test('the quiz against "use my tastes", with their choices; sessions '
        'that needed relaxing and which steps', () {
      final r = _calc(
        sessions: [
          _session(
            'a',
            nov,
            source: SurpriseSessionSource.quiz,
            relaxations: {'dropVibes', 'lowerVoteCount'},
          ),
          _session('b', nov, source: SurpriseSessionSource.profile),
          _session(
            'c',
            nov,
            source: SurpriseSessionSource.inferredList,
            relaxations: {'dropVibes'},
          ),
        ],
        history: [
          _h(_m(1), 'a', nov, outcome: SurpriseOutcome.chosen),
          _h(_m(2), 'c', nov, outcome: SurpriseOutcome.chosen),
        ],
      );
      final asked = r.asked!;
      expect(asked.viaQuiz, 1);
      expect(asked.viaTastes, 2);
      expect(asked.chosenViaQuiz, 1);
      expect(asked.chosenViaTastes, 1);
      expect(asked.relaxedSessions, 2);
      expect(asked.relaxations, [('dropVibes', 2), ('lowerVoteCount', 1)]);
    });
  });

  group('6. habit', () {
    test('sessions by month (12, oldest first) and weekday', () {
      final r = _calc(
        sessions: [
          _session('a', DateTime(2026, 11, 18)), // Wednesday
          _session('b', DateTime(2026, 11, 4)), // Wednesday
          _session('c', DateTime(2026, 10, 5)), // Monday
        ],
      );
      expect(r.habit.byMonth.first.$1, DateTime(2025, 12));
      expect(r.habit.byMonth.last, (DateTime(2026, 11), 2));
      expect(r.habit.byMonth[10], (DateTime(2026, 10), 1));
      expect(r.habit.byWeekday, [1, 0, 2, 0, 0, 0, 0]);
    });

    test('weekly streak: this week or last; best ever; of the whole history '
        'whatever the period', () {
      final r = _calc(
        period: StatsPeriod.thisMonth,
        sessions: [
          _session('a', DateTime(2026, 11, 17)), // this week
          _session('b', DateTime(2026, 11, 10)), // last week
          _session('c', DateTime(2026, 11, 3)), // the one before
          _session('d', DateTime(2026, 9, 1)), // a gap, then
          _session('e', DateTime(2026, 8, 25)),
          _session('f', DateTime(2026, 8, 18)),
          _session('g', DateTime(2026, 8, 11)),
        ],
      );
      expect(r.habit.weeklyStreak, 3);
      expect(r.habit.bestWeeklyStreak, 4);
    });

    test('a streak survives until the week is over', () {
      final r = _calc(sessions: [_session('a', DateTime(2026, 11, 10))]);
      expect(r.habit.weeklyStreak, 1);
      final none = _calc(sessions: [_session('a', DateTime(2026, 10, 1))]);
      expect(none.habit.weeklyStreak, 0);
    });
  });

  test('a card whose session was never recorded still counts, by its own '
      'date', () {
    final r = _calc(
      history: [
        _h(_m(1), 'orphan', nov, genres: [_drama]),
      ],
      period: StatsPeriod.thisMonth,
    );
    expect(r.genres.single.genre, _drama);
    expect(r.hitRate, isNull); // no session, no hit rate
  });
}
