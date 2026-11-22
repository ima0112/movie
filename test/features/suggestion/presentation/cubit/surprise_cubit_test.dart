import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/repositories/surprise_session_repository.dart';
import 'package:movies/core/domain/entities/surprise_session.dart';
import 'package:movies/core/data/local/in_memory_surprise_session_repository.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/data/local/in_memory_surprise_history_repository.dart';
import 'package:movies/core/domain/entities/surprise_history_entry.dart';
import 'package:movies/core/domain/entities/taste_profile.dart';
import 'package:movies/core/domain/repositories/surprise_history_repository.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/core/domain/repositories/taste_profile_repository.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/features/match_engine/domain/participant_answers.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';
import 'package:movies/features/match_engine/domain/surprise_batch.dart';
import 'package:movies/features/suggestion/presentation/cubit/surprise_cubit.dart';
import 'package:movies/features/suggestion/presentation/cubit/surprise_state.dart';
import 'package:movies/features/taste_profile/domain/taste_profile_builder.dart';

import '../../surprise_test_data.dart';

final _emptyVibeCatalog = VibeCatalog(const []);

/// Usable by default (`TasteProfile.isUsableForSuggestions`) — a bare
/// `Genre` is enough, and what it actually is doesn't matter to any of
/// these tests (the empty `_emptyVibeCatalog` means no vibe ever maps
/// back to it anyway).
TasteProfile _profile({bool usable = true}) {
  return TasteProfile(
    likedGenres: usable ? {const Genre(id: 'drama')} : const {},
    vetoedGenres: const {},
    likedVibes: const {},
    yearFrom: 2000,
    updatedAt: DateTime(2024),
  );
}

class _FakeTasteProfileRepository implements TasteProfileRepository {
  _FakeTasteProfileRepository(this.profile);

  final TasteProfile? profile;

  @override
  Stream<TasteProfile?> watch() => Stream.value(profile);

  @override
  Future<Result<void>> save(TasteProfile profile) async => const Success(null);

  @override
  Future<Result<void>> delete() async => const Success(null);
}

class _FakeUserLibraryRepository implements UserLibraryRepository {
  _FakeUserLibraryRepository([this.entries = const []]);

  final List<UserMediaEntry> entries;

  @override
  Stream<List<UserMediaEntry>> watch({LibraryTab? tab, MediaType? type}) =>
      Stream.value(entries);

  @override
  Stream<UserMediaEntry?> watchEntry(MediaKey key) => Stream.value(null);

  @override
  Future<Result<void>> upsert(UserMediaEntry entry) async =>
      const Success(null);

  @override
  Future<Result<void>> updateCatalogSnapshot(
    MediaKey key, {
    required String title,
    required List<Genre> genres,
    String? posterUrl,
    double? voteAverage,
    int? year,
    int? runtimeMinutes,
    int? episodeCount,
    int? episodeRuntimeMinutes,
  }) async => const Success(null);

  @override
  Future<Result<void>> remove(MediaKey key) async => const Success(null);

  @override
  Future<Result<void>> clearAll() async => const Success(null);

  @override
  Future<Result<List<MediaKey>>> watchedKeys(
    MediaType type, {
    int limit = 500,
  }) async => const Success([]);

  @override
  Future<Result<List<UserMediaEntry>>> all() async => Success(entries);
}

/// A library that remembers what is written to it (the deck tests look at it).
class _MapLibrary extends _FakeUserLibraryRepository {
  _MapLibrary([List<UserMediaEntry> initial = const []]) {
    for (final e in initial) {
      _map[e.key] = e;
    }
  }

  final Map<MediaKey, UserMediaEntry> _map = {};
  int upserts = 0;
  bool failWrites = false;

  UserMediaEntry? operator [](MediaKey key) => _map[key];

  @override
  Stream<UserMediaEntry?> watchEntry(MediaKey key) => Stream.value(_map[key]);

  @override
  Future<Result<List<UserMediaEntry>>> all() async =>
      Success(_map.values.toList());

  @override
  Future<Result<void>> remove(MediaKey key) async {
    _map.remove(key);
    return const Success(null);
  }

  @override
  Future<Result<void>> upsert(UserMediaEntry entry) async {
    upserts++;
    if (failWrites) return Failure(FailureReason.storage);
    _map[entry.key] = entry;
    return const Success(null);
  }
}

SurpriseCubit _cubit({
  required FakeSurpriseEngine engine,
  TasteProfile? profile,
  List<UserMediaEntry> libraryEntries = const [],
  SurpriseHistoryRepository? history,
  SurpriseSessionRepository? sessions,
  DateTime Function()? clock,
  String Function()? region,
  UserLibraryRepository? library,
}) {
  return SurpriseCubit(
    engine,
    TasteProfileBuilder(_emptyVibeCatalog),
    _FakeTasteProfileRepository(profile),
    library ?? _FakeUserLibraryRepository(libraryEntries),
    history: history,
    sessions: sessions,
    clock: clock,
    region: region,
  );
}

void main() {
  group('SurpriseCubit — Searching timing', () {
    test('stays in Searching for at least 1.8s even if the engine '
        'resolves instantly', () {
      fakeAsync((async) {
        final engine = FakeSurpriseEngine.returning(batchOf(1));
        final cubit = _cubit(engine: engine, profile: _profile());

        unawaited(cubit.chooseType(MediaType.movie));
        async.flushMicrotasks();
        expect(cubit.state, isA<ChooseSource>());

        unawaited(cubit.useMyTastes());
        async.flushMicrotasks();
        expect(cubit.state, isA<Searching>());

        async.elapse(
          SurpriseCubit.minSearchingDuration - const Duration(milliseconds: 1),
        );
        expect(
          cubit.state,
          isA<Searching>(),
          reason: 'still short of the 1.8s minimum',
        );

        async.elapse(const Duration(milliseconds: 1));
        expect(cubit.state, isA<SurpriseResult>());

        cubit.close();
      });
    });

    test('cancelSearch goes back to ChoosingType and the late result is '
        'thrown away', () {
      fakeAsync((async) {
        final engine = FakeSurpriseEngine.returning(batchOf(1));
        final cubit = _cubit(engine: engine, profile: _profile());

        unawaited(cubit.chooseType(MediaType.movie));
        async.flushMicrotasks();
        unawaited(cubit.useMyTastes());
        async.flushMicrotasks();
        expect(cubit.state, isA<Searching>());

        cubit.cancelSearch();
        expect(cubit.state, isA<ChoosingType>());

        async.elapse(SurpriseCubit.maxSearchingDuration);
        expect(cubit.state, isA<ChoosingType>());

        cubit.close();
      });
    });

    test('cancelSearch during "Ask for another 5" brings the same deck back '
        'and the late batch is thrown away', () {
      fakeAsync((async) {
        final engine = FakeSurpriseEngine(
          results: [Success(batchOf(5)), Success(batchOf(5, first: 5))],
        );
        final cubit = _cubit(engine: engine, profile: _profile());

        unawaited(cubit.chooseType(MediaType.movie));
        async.flushMicrotasks();
        unawaited(cubit.useMyTastes());
        async.elapse(SurpriseCubit.minSearchingDuration);
        async.flushMicrotasks();
        final deck = cubit.state as SurpriseResult;
        cubit.next();

        unawaited(cubit.reroll());
        expect(cubit.state, isA<Searching>());
        expect(cubit.cancelSearch(), isTrue);

        final back = cubit.state as SurpriseResult;
        expect(back.suggestions, same(deck.suggestions));
        expect(back.index, 1);

        async.elapse(SurpriseCubit.maxSearchingDuration);
        async.flushMicrotasks();
        expect(
          (cubit.state as SurpriseResult).suggestions,
          same(deck.suggestions),
        );

        cubit.close();
      });
    });

    test('emits SurpriseError after 8s if the engine never resolves', () {
      fakeAsync((async) {
        final engine = FakeSurpriseEngine(neverCompletes: true);
        final cubit = _cubit(engine: engine, profile: _profile());

        unawaited(cubit.chooseType(MediaType.movie));
        async.flushMicrotasks();
        unawaited(cubit.useMyTastes());
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 7, milliseconds: 999));
        expect(
          cubit.state,
          isA<Searching>(),
          reason: 'still short of the 8s maximum',
        );

        async.elapse(const Duration(milliseconds: 1));
        expect(cubit.state, isA<SurpriseError>());

        cubit.close();
      });
    });

    test('a slow (but not timed-out) engine still only waits for '
        'itself, not minSearchingDuration on top', () {
      fakeAsync((async) {
        final engine = FakeSurpriseEngine.returning(
          batchOf(1),
          delay: const Duration(seconds: 3),
        );
        final cubit = _cubit(engine: engine, profile: _profile());

        unawaited(cubit.chooseType(MediaType.movie));
        async.flushMicrotasks();
        unawaited(cubit.useMyTastes());
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 3));
        expect(cubit.state, isA<SurpriseResult>());

        cubit.close();
      });
    });
  });

  // (the deck group is further down)

  group('SurpriseCubit — the 3-case decision', () {
    test('a usable profile emits ChooseSource(source: profile), not a '
        'search — no Searching, no engine call yet', () {
      fakeAsync((async) {
        final engine = FakeSurpriseEngine.returning(batchOf(2));
        final cubit = _cubit(engine: engine, profile: _profile());

        unawaited(cubit.chooseType(MediaType.movie));
        async.flushMicrotasks();

        final state = cubit.state as ChooseSource;
        expect(state.mediaType, MediaType.movie);
        expect(state.source, SuggestionSource.profile);
        expect(engine.callCount, 0);

        cubit.close();
      });
    });

    test('no usable profile but 5+ library entries emits '
        'ChooseSource(source: inferredList)', () {
      fakeAsync((async) {
        final engine = FakeSurpriseEngine.returning(batchOf(2));
        final entries = List.generate(
          5,
          (i) => UserMediaEntry(
            title: 'Test',
            key: MediaKey(type: MediaType.movie, tmdbId: i),
            isFavorite: true,
          ),
        );
        final cubit = _cubit(engine: engine, libraryEntries: entries);

        unawaited(cubit.chooseType(MediaType.movie));
        async.flushMicrotasks();

        final state = cubit.state as ChooseSource;
        expect(state.source, SuggestionSource.inferredList);
        expect(engine.callCount, 0);

        cubit.close();
      });
    });

    test('a profile that exists but isn\'t usable is treated like no '
        'profile — falls through to inferredList when the library '
        'qualifies', () {
      fakeAsync((async) {
        final engine = FakeSurpriseEngine.returning(batchOf(2));
        final entries = List.generate(
          5,
          (i) => UserMediaEntry(
            title: 'Test',
            key: MediaKey(type: MediaType.movie, tmdbId: i),
            isFavorite: true,
          ),
        );
        final cubit = _cubit(
          engine: engine,
          profile: _profile(usable: false),
          libraryEntries: entries,
        );

        unawaited(cubit.chooseType(MediaType.movie));
        async.flushMicrotasks();

        expect(
          (cubit.state as ChooseSource).source,
          SuggestionSource.inferredList,
        );

        cubit.close();
      });
    });

    test('no usable profile and fewer than 5 entries emits NeedsQuiz '
        'directly, never reaching the engine', () {
      fakeAsync((async) {
        final engine = FakeSurpriseEngine.returning(batchOf(2));
        final cubit = _cubit(engine: engine);

        unawaited(cubit.chooseType(MediaType.tvShow));
        async.flushMicrotasks();

        expect(cubit.state, isA<NeedsQuiz>());
        expect((cubit.state as NeedsQuiz).mediaType, MediaType.tvShow);
        expect(engine.callCount, 0);

        cubit.close();
      });
    });

    test('useMyTastes() launches the search with ChooseSource\'s own '
        'mediaType/source, carried through to the result', () {
      fakeAsync((async) {
        final engine = FakeSurpriseEngine.returning(batchOf(2));
        final cubit = _cubit(engine: engine, profile: _profile());

        unawaited(cubit.chooseType(MediaType.movie));
        async.flushMicrotasks();
        unawaited(cubit.useMyTastes());
        async.flushMicrotasks();
        expect(cubit.state, isA<Searching>());

        async.elapse(SurpriseCubit.minSearchingDuration);
        final result = cubit.state as SurpriseResult;
        expect(result.source, SuggestionSource.profile);
        expect(engine.callCount, 1);

        cubit.close();
      });
    });

    test('useMyTastes() is a no-op outside of ChooseSource', () {
      final cubit = _cubit(engine: FakeSurpriseEngine());

      unawaited(cubit.useMyTastes());
      expect(cubit.state, isA<ChoosingType>());

      cubit.close();
    });

    test('answerQuizInstead() emits NeedsQuiz with ChooseSource\'s own '
        'mediaType, from ChooseSource', () {
      fakeAsync((async) {
        final engine = FakeSurpriseEngine();
        final cubit = _cubit(engine: engine, profile: _profile());

        unawaited(cubit.chooseType(MediaType.tvShow));
        async.flushMicrotasks();
        expect(cubit.state, isA<ChooseSource>());

        cubit.answerQuizInstead();

        expect(cubit.state, isA<NeedsQuiz>());
        expect((cubit.state as NeedsQuiz).mediaType, MediaType.tvShow);
        expect(engine.callCount, 0);

        cubit.close();
      });
    });

    test('answerQuizInstead() is a no-op outside of ChooseSource', () {
      final cubit = _cubit(engine: FakeSurpriseEngine());

      cubit.answerQuizInstead();
      expect(cubit.state, isA<ChoosingType>());

      cubit.close();
    });

    test('answerWith (the quiz\'s own onComplete) only acts from '
        'NeedsQuiz, and sources the result as "quiz" — whether '
        'NeedsQuiz came straight from chooseType or via '
        'answerQuizInstead', () {
      fakeAsync((async) {
        final engine = FakeSurpriseEngine.returning(batchOf(2));
        final cubit = _cubit(engine: engine);

        unawaited(cubit.chooseType(MediaType.movie));
        async.flushMicrotasks();
        expect(cubit.state, isA<NeedsQuiz>());

        unawaited(
          cubit.answerWith(
            const ParticipantAnswers(participantId: 'me', yearFrom: 2000),
          ),
        );
        async.elapse(SurpriseCubit.minSearchingDuration);

        final result = cubit.state as SurpriseResult;
        expect(result.source, SuggestionSource.quiz);

        cubit.close();
      });
    });
  });

  group('SurpriseCubit — retry()', () {
    test('re-runs the exact same search that just failed', () {
      fakeAsync((async) {
        final failingEngine = FakeSurpriseEngine(neverCompletes: true);
        final cubit = _cubit(engine: failingEngine, profile: _profile());

        unawaited(cubit.chooseType(MediaType.movie));
        async.flushMicrotasks();
        unawaited(cubit.useMyTastes());
        async.elapse(SurpriseCubit.maxSearchingDuration);
        expect(cubit.state, isA<SurpriseError>());

        // retry() can't swap the engine mid-flight on the same cubit,
        // so this confirms it actually re-invokes the search path (a
        // second Searching -> same timeout) rather than, say, silently
        // no-op'ing.
        unawaited(cubit.retry());
        async.flushMicrotasks();
        expect(cubit.state, isA<Searching>());
        async.elapse(SurpriseCubit.maxSearchingDuration);
        expect(cubit.state, isA<SurpriseError>());

        cubit.close();
      });
    });

    test('is a no-op if nothing has been searched for yet', () {
      final cubit = _cubit(engine: FakeSurpriseEngine());

      unawaited(cubit.retry());
      expect(cubit.state, isA<ChoosingType>());

      cubit.close();
    });
  });

  group('SurpriseCubit — sessions, history and the engine request', () {
    final now = DateTime(2026, 11, 16, 12);

    /// Drives a search to its result: type chosen, tastes used, time passed.
    void runSearch(SurpriseCubit cubit, FakeAsync async) {
      unawaited(cubit.chooseType(MediaType.movie));
      async.flushMicrotasks();
      unawaited(cubit.useMyTastes());
      async.elapse(SurpriseCubit.minSearchingDuration);
    }

    test(
      'the request carries the type, a session, the region and the taste',
      () {
        fakeAsync((async) {
          final engine = FakeSurpriseEngine.returning(batchOf(5));
          final cubit = _cubit(
            engine: engine,
            profile: _profile(),
            region: () => 'ES',
          );

          runSearch(cubit, async);

          final request = engine.requests.single;
          expect(request.type, MediaType.movie);
          expect(request.region, 'ES');
          expect(request.sessionId, isNotEmpty);
          expect(request.count, 5);
          // The profile's liked genre counts as taste.
          expect(
            request.genreAffinity[const Genre(id: 'drama')],
            greaterThan(0),
          );
          cubit.close();
        });
      },
    );

    test('what a batch showed is recorded, and "Search again" asks for a new '
        'batch of the same session without it', () {
      fakeAsync((async) {
        final history = InMemorySurpriseHistoryRepository();
        final engine = FakeSurpriseEngine(
          results: [Success(batchOf(5)), Success(batchOf(5, first: 5))],
        );
        final cubit = _cubit(
          engine: engine,
          profile: _profile(),
          history: history,
          clock: () => now,
        );

        runSearch(cubit, async);
        async.flushMicrotasks();
        expect(cubit.state, isA<SurpriseResult>());

        // The deck is circular: past the fifth it is the first again. Then ask
        // for a new batch.
        for (var i = 0; i < 5; i++) {
          cubit.next();
        }
        expect((cubit.state as SurpriseResult).index, 0);
        unawaited(cubit.reroll());
        async.elapse(SurpriseCubit.minSearchingDuration);
        async.flushMicrotasks();

        expect(engine.requests, hasLength(2));
        expect(engine.requests[1].sessionId, engine.requests[0].sessionId);
        expect(engine.requests[1].seed, isNot(engine.requests[0].seed));
        expect(engine.requests[1].excludeKeys, {
          for (var i = 0; i < 5; i++)
            MediaKey(type: MediaType.movie, tmdbId: i),
        });
        expect(cubit.state, isA<SurpriseResult>());
        cubit.close();
      });
    });

    test('the session\'s answers are recorded once, with the source and what '
        'each batch needed relaxing', () {
      fakeAsync((async) {
        final sessions = InMemorySurpriseSessionRepository();
        final engine = FakeSurpriseEngine(
          results: [
            Success(batchOf(5)),
            Success(
              SurpriseBatch(
                sessionId: 's',
                suggestions: batchOf(5, first: 5).suggestions,
                relaxations: const [SurpriseRelaxation.dropVibes],
              ),
            ),
          ],
        );
        final cubit = _cubit(
          engine: engine,
          profile: _profile(),
          sessions: sessions,
          clock: () => now,
        );

        runSearch(cubit, async);
        async.flushMicrotasks();
        for (var i = 0; i < 5; i++) {
          cubit.next();
        }
        unawaited(cubit.reroll());
        async.elapse(SurpriseCubit.minSearchingDuration);
        async.flushMicrotasks();

        late List<SurpriseSession> recorded;
        sessions.all().then(
          (r) => recorded = (r as Success<List<SurpriseSession>>).value,
        );
        async.flushMicrotasks();
        expect(recorded, hasLength(1));
        expect(recorded.single.sessionId, engine.requests.first.sessionId);
        expect(recorded.single.source, SurpriseSessionSource.profile);
        expect(recorded.single.mediaType, MediaType.movie);
        expect(recorded.single.relaxations, {'dropVibes'});
        cubit.close();
      });
    });

    test('a fresh ask is a new session; titles shown in the last 30 days are '
        'skipped, older ones are not', () {
      fakeAsync((async) {
        final history = InMemorySurpriseHistoryRepository();
        unawaited(
          history.recordShown([
            SurpriseHistoryEntry(
              key: const MediaKey(type: MediaType.movie, tmdbId: 100),
              sessionId: 'old',
              shownAt: now.subtract(const Duration(days: 10)),
            ),
            SurpriseHistoryEntry(
              key: const MediaKey(type: MediaType.movie, tmdbId: 200),
              sessionId: 'older',
              shownAt: now.subtract(const Duration(days: 45)),
            ),
          ]),
        );
        final engine = FakeSurpriseEngine.returning(batchOf(5));
        final cubit = _cubit(
          engine: engine,
          profile: _profile(),
          history: history,
          clock: () => now,
        );

        runSearch(cubit, async);

        final excluded = engine.requests.single.excludeKeys;
        expect(
          excluded,
          contains(const MediaKey(type: MediaType.movie, tmdbId: 100)),
        );
        expect(
          excluded,
          isNot(contains(const MediaKey(type: MediaType.movie, tmdbId: 200))),
        );
        cubit.close();
      });
    });

    test('passing a card is never a rejection; a saved or opened one is '
        'recorded as such', () {
      fakeAsync((async) {
        final history = InMemorySurpriseHistoryRepository();
        final engine = FakeSurpriseEngine.returning(batchOf(5));
        final cubit = _cubit(
          engine: engine,
          profile: _profile(),
          history: history,
          clock: () => now,
        );
        runSearch(cubit, async);
        async.flushMicrotasks();

        cubit.recordOutcome(SurpriseOutcome.saved); // title 0 saved
        cubit.next(); // …and passed: nothing is recorded for passing
        async.flushMicrotasks();
        cubit.cardFlipped(); // title 1 turned over to read its back
        async.flushMicrotasks();

        late List<SurpriseHistoryEntry> all;
        unawaited(
          history.all().then(
            (r) => all = (r as Success<List<SurpriseHistoryEntry>>).value,
          ),
        );
        async.flushMicrotasks();
        final byId = {for (final e in all) e.key.tmdbId: e.outcome};
        expect(byId[0], SurpriseOutcome.saved); // passing doesn't undo it
        expect(byId[1], SurpriseOutcome.revisited);
        expect(byId[2], SurpriseOutcome.viewed); // shown, nothing more
        cubit.close();
      });
    });

    test('an engine failure is an error', () {
      fakeAsync((async) {
        final engine = FakeSurpriseEngine(
          results: [Failure(FailureReason.network)],
        );
        final cubit = _cubit(engine: engine, profile: _profile());

        runSearch(cubit, async);

        expect(cubit.state, isA<SurpriseError>());
        cubit.close();
      });
    });

    test('nothing found on a first search is an error; over a deck, "other 5" '
        'finding nothing keeps the deck with a notice', () {
      fakeAsync((async) {
        final first = FakeSurpriseEngine.returning(batchOf(0));
        final a = _cubit(engine: first, profile: _profile());
        runSearch(a, async);
        expect(a.state, isA<SurpriseError>());
        a.close();

        final engine = FakeSurpriseEngine(
          results: [Success(batchOf(5)), Success(batchOf(0))],
        );
        final b = _cubit(engine: engine, profile: _profile());
        runSearch(b, async);
        async.flushMicrotasks();
        b.next();
        unawaited(b.reroll());
        async.elapse(SurpriseCubit.minSearchingDuration);

        final deck = b.state as SurpriseResult;
        expect(deck.index, 1, reason: 'the deck is as it was left');
        expect(deck.notice, SurpriseNotice.noMoreSurprises);
        b.close();
      });
    });

    test(
      'each card is recorded with its batch number and genres; "Search '
      'again" marks the batch before as rerolled when nothing was picked',
      () {
        fakeAsync((async) {
          final history = InMemorySurpriseHistoryRepository();
          final engine = FakeSurpriseEngine(
            results: [Success(batchOf(5)), Success(batchOf(5, first: 5))],
          );
          final cubit = _cubit(
            engine: engine,
            profile: _profile(),
            history: history,
            clock: () => now,
          );
          runSearch(cubit, async);
          async.flushMicrotasks();

          for (var i = 0; i < 4; i++) {
            cubit.next(); // passing: neutral — each card seen once
          }
          unawaited(cubit.reroll());
          async.elapse(SurpriseCubit.minSearchingDuration);
          async.flushMicrotasks();

          late List<SurpriseHistoryEntry> all;
          unawaited(
            history.all().then(
              (r) => all = (r as Success<List<SurpriseHistoryEntry>>).value,
            ),
          );
          async.flushMicrotasks();
          final byId = {for (final e in all) e.key.tmdbId: e};
          expect(all, hasLength(10));
          expect(byId[0]!.batch, 1);
          expect(byId[0]!.outcome, SurpriseOutcome.rerolled);
          expect(byId[5]!.batch, 2);
          expect(byId[5]!.outcome, SurpriseOutcome.viewed); // current batch
          cubit.close();
        });
      },
    );

    test('a batch with something saved is not marked as rerolled', () {
      fakeAsync((async) {
        final history = InMemorySurpriseHistoryRepository();
        final engine = FakeSurpriseEngine(
          results: [Success(batchOf(5)), Success(batchOf(5, first: 5))],
        );
        final cubit = _cubit(
          engine: engine,
          profile: _profile(),
          history: history,
          clock: () => now,
        );
        runSearch(cubit, async);
        async.flushMicrotasks();

        cubit.recordOutcome(SurpriseOutcome.saved);
        async.flushMicrotasks();
        for (var i = 0; i < 5; i++) {
          cubit.next();
        }
        unawaited(cubit.reroll());
        async.elapse(SurpriseCubit.minSearchingDuration);
        async.flushMicrotasks();

        late List<SurpriseHistoryEntry> all;
        unawaited(
          history.all().then(
            (r) => all = (r as Success<List<SurpriseHistoryEntry>>).value,
          ),
        );
        async.flushMicrotasks();
        final byId = {for (final e in all) e.key.tmdbId: e.outcome};
        expect(byId[0], SurpriseOutcome.saved);
        expect(byId[1], SurpriseOutcome.viewed);
        cubit.close();
      });
    });

    test('what the history says about taste reaches the engine: a genre '
        'chosen before counts, and a pick in this session counts at once', () {
      fakeAsync((async) {
        final history = InMemorySurpriseHistoryRepository();
        unawaited(
          history.recordShown([
            SurpriseHistoryEntry(
              key: const MediaKey(type: MediaType.movie, tmdbId: 900),
              sessionId: 'old',
              shownAt: now.subtract(const Duration(days: 3)),
              genres: const [Genre(id: 'crime')],
              outcome: SurpriseOutcome.chosen,
            ),
          ]),
        );
        final engine = FakeSurpriseEngine(
          results: [
            Success(batchOfGenre(5, 'horror')),
            Success(batchOf(5, first: 5)),
          ],
        );
        final cubit = _cubit(
          engine: engine,
          profile: _profile(), // likes drama (+3)
          history: history,
          clock: () => now,
        );

        runSearch(cubit, async);
        async.flushMicrotasks();

        final first = engine.requests.first.genreAffinity;
        expect(first[const Genre(id: 'crime')], greaterThan(0)); // from history
        expect(first[const Genre(id: 'drama')], 3); // from the profile
        expect(first[const Genre(id: 'horror')], isNull);

        // A horror card is saved now: the next batch already knows.
        cubit.recordOutcome(SurpriseOutcome.saved);
        async.flushMicrotasks();
        for (var i = 0; i < 5; i++) {
          cubit.next();
        }
        unawaited(cubit.reroll());
        async.elapse(SurpriseCubit.minSearchingDuration);
        async.flushMicrotasks();

        final second = engine.requests.last.genreAffinity;
        expect(second[const Genre(id: 'horror')], 4);
        expect(second[const Genre(id: 'crime')], greaterThan(0));
        cubit.close();
      });
    });
  });

  group('SurpriseCubit — picking a type again', () {
    test('a new pick passes through ChoosingType, so E1 routes again', () {
      fakeAsync((async) {
        final cubit = _cubit(engine: FakeSurpriseEngine());
        final seen = <Type>[];
        final sub = cubit.stream.listen((s) => seen.add(s.runtimeType));

        unawaited(cubit.chooseType(MediaType.movie));
        async.flushMicrotasks();
        expect(cubit.state, isA<NeedsQuiz>());

        // Back from the quiz, the user picks again.
        unawaited(cubit.chooseType(MediaType.tvShow));
        async.flushMicrotasks();

        expect(seen, [NeedsQuiz, ChoosingType, NeedsQuiz]);
        unawaited(sub.cancel());
        cubit.close();
      });
    });
  });

  group('SurpriseCubit — the deck', () {
    final now = DateTime(2026, 11, 16, 12);
    MediaKey key(int id) => MediaKey(type: MediaType.movie, tmdbId: id);

    /// Opens a deck of [size] cards (titles 0…size-1).
    SurpriseCubit openDeck(
      FakeAsync async, {
      int size = 5,
      UserLibraryRepository? library,
      SurpriseHistoryRepository? history,
      FakeSurpriseEngine? engine,
    }) {
      final cubit = _cubit(
        engine: engine ?? FakeSurpriseEngine.returning(batchOf(size)),
        profile: _profile(),
        library: library,
        history: history,
        clock: () => now,
      );
      unawaited(cubit.chooseType(MediaType.movie));
      async.flushMicrotasks();
      unawaited(cubit.useMyTastes());
      async.elapse(SurpriseCubit.minSearchingDuration);
      async.flushMicrotasks();
      expect(cubit.state, isA<SurpriseResult>());
      return cubit;
    }

    SurpriseResult deck(SurpriseCubit c) => c.state as SurpriseResult;

    Map<int, SurpriseOutcome> outcomes(
      FakeAsync async,
      InMemorySurpriseHistoryRepository history,
    ) {
      late List<SurpriseHistoryEntry> all;
      unawaited(
        history.all().then(
          (r) => all = (r as Success<List<SurpriseHistoryEntry>>).value,
        ),
      );
      async.flushMicrotasks();
      return {for (final e in all) e.key.tmdbId: e.outcome};
    }

    test('it is circular: past the last card comes the first, and the engine '
        'was only asked once', () {
      fakeAsync((async) {
        final engine = FakeSurpriseEngine.returning(batchOf(5));
        final cubit = openDeck(async, engine: engine);

        final seen = <int>[deck(cubit).index];
        for (var i = 0; i < 6; i++) {
          cubit.next();
          seen.add(deck(cubit).index);
        }

        expect(seen, [0, 1, 2, 3, 4, 0, 1]);
        expect(engine.callCount, 1);
        cubit.close();
      });
    });

    test('with one card there is nowhere to go; with two it still cycles', () {
      fakeAsync((async) {
        final one = openDeck(async, size: 1);
        one.next();
        one.jumpTo(0);
        expect(deck(one).index, 0);
        one.close();

        final two = openDeck(async, size: 2);
        two.next();
        expect(deck(two).index, 1);
        two.next();
        expect(deck(two).index, 0);
        two.close();
      });
    });

    test('jumpTo brings a card to the top; a bad or current index does '
        'nothing', () {
      fakeAsync((async) {
        final cubit = openDeck(async);

        cubit.jumpTo(3);
        expect(deck(cubit).index, 3);
        cubit.jumpTo(3);
        cubit.jumpTo(-1);
        cubit.jumpTo(5);
        expect(deck(cubit).index, 3);
        cubit.close();
      });
    });

    test('toggleSaved: out → in → out, the deck shows it at once and the '
        'library follows; a favorite is kept when it leaves Watch later', () {
      fakeAsync((async) {
        final library = _MapLibrary([
          UserMediaEntry(key: key(0), title: 'Movie 0', isFavorite: true),
        ]);
        final cubit = openDeck(async, library: library);

        unawaited(cubit.toggleSaved(key(0)));
        async.flushMicrotasks();
        expect(deck(cubit).isSaved(0), isTrue);
        expect(deck(cubit).index, 0); // saving never passes
        expect(library[key(0)]!.isWatchLater, isTrue);

        unawaited(cubit.toggleSaved(key(0)));
        async.flushMicrotasks();
        expect(deck(cubit).isSaved(0), isFalse);
        expect(library[key(0)]!.isWatchLater, isFalse);
        expect(library[key(0)]!.isFavorite, isTrue);
        cubit.close();
      });
    });

    test('toggleSaved out of Watch later deletes an entry left in no list', () {
      fakeAsync((async) {
        final library = _MapLibrary();
        final cubit = openDeck(async, library: library);

        unawaited(cubit.toggleSaved(key(1)));
        async.flushMicrotasks();
        unawaited(cubit.toggleSaved(key(1)));
        async.flushMicrotasks();

        expect(library[key(1)], isNull);
        expect(deck(cubit).isSaved(1), isFalse);
        cubit.close();
      });
    });

    test('save() stays on the card, is one-way and idempotent', () {
      fakeAsync((async) {
        final library = _MapLibrary();
        final cubit = openDeck(async, library: library);

        unawaited(cubit.save());
        unawaited(cubit.save());
        async.flushMicrotasks();

        expect(deck(cubit).index, 0);
        expect(deck(cubit).isSaved(0), isTrue);
        expect(library.upserts, 1);
        cubit.close();
      });
    });

    test('saving keeps what the library already knows about the title (a '
        'favorite, a rating)', () {
      fakeAsync((async) {
        final library = _MapLibrary([
          UserMediaEntry(
            key: key(0),
            title: 'Movie 0',
            isFavorite: true,
            rating: 5,
          ),
        ]);
        final cubit = openDeck(async, library: library);

        unawaited(cubit.save());
        async.flushMicrotasks();

        final entry = library[key(0)]!;
        expect(entry.isWatchLater, isTrue);
        expect(entry.isFavorite, isTrue);
        expect(entry.rating, 5);
        cubit.close();
      });
    });

    test('cards already in Watch later show as saved from the start', () {
      fakeAsync((async) {
        final library = _MapLibrary([
          UserMediaEntry(key: key(2), title: 'Movie 2', isWatchLater: true),
          UserMediaEntry(key: key(3), title: 'Movie 3', isFavorite: true),
        ]);
        final cubit = openDeck(async, library: library);

        expect(deck(cubit).savedKeys, {key(2)});
        cubit.close();
      });
    });

    test('a failed write takes the saved mark back', () {
      fakeAsync((async) {
        final library = _MapLibrary()..failWrites = true;
        final cubit = openDeck(async, library: library);

        unawaited(cubit.save());
        async.flushMicrotasks();

        expect(deck(cubit).savedKeys, isEmpty);
        cubit.close();
      });
    });

    test('choose: the card goes into Watch later by itself, is recorded as '
        'chosen, and the game ends — once, even on a double call', () {
      fakeAsync((async) {
        final library = _MapLibrary();
        final history = InMemorySurpriseHistoryRepository();
        final cubit = openDeck(async, library: library, history: history);
        cubit.jumpTo(2);

        unawaited(cubit.choose());
        unawaited(cubit.choose());
        async.flushMicrotasks();

        final chosen = cubit.state as SurpriseChosen;
        expect(chosen.index, 2);
        expect(chosen.chosen.item.id, 2);
        expect(chosen.savedKeys, contains(key(2)));
        expect(library[key(2)]!.isWatchLater, isTrue);
        expect(library.upserts, 1);
        expect(outcomes(async, history)[2], SurpriseOutcome.chosen);
        cubit.close();
      });
    });

    test('choosing a card already saved does not write again', () {
      fakeAsync((async) {
        final library = _MapLibrary();
        final cubit = openDeck(async, library: library);
        unawaited(cubit.save());
        async.flushMicrotasks();

        unawaited(cubit.choose());
        async.flushMicrotasks();

        expect(cubit.state, isA<SurpriseChosen>());
        expect(library.upserts, 1);
        cubit.close();
      });
    });

    test('"other 5": a new deck of the same session; the batch before is '
        'marked rerolled when nothing in it was picked', () {
      fakeAsync((async) {
        final history = InMemorySurpriseHistoryRepository();
        final engine = FakeSurpriseEngine(
          results: [Success(batchOf(5)), Success(batchOf(5, first: 5))],
        );
        final cubit = openDeck(async, history: history, engine: engine);
        cubit.next();

        unawaited(cubit.reroll());
        async.flushMicrotasks();
        expect(cubit.state, isA<Searching>());
        async.elapse(SurpriseCubit.minSearchingDuration);
        async.flushMicrotasks();

        expect(deck(cubit).index, 0);
        expect(deck(cubit).suggestions.first.item.id, 5);
        expect(engine.requests[1].sessionId, engine.requests[0].sessionId);
        expect(outcomes(async, history)[0], SurpriseOutcome.rerolled);
        cubit.close();
      });
    });

    test('"other 5" that cannot reach TMDB: the deck comes back as it was, '
        'with an offline notice, and nothing is marked rerolled', () {
      fakeAsync((async) {
        final history = InMemorySurpriseHistoryRepository();
        final engine = FakeSurpriseEngine(
          results: [Success(batchOf(5)), Failure(FailureReason.network)],
        );
        final cubit = openDeck(async, history: history, engine: engine);
        cubit.next();
        cubit.next();

        unawaited(cubit.reroll());
        async.elapse(SurpriseCubit.minSearchingDuration);
        async.flushMicrotasks();

        expect(cubit.state, isA<SurpriseResult>());
        expect(deck(cubit).index, 2);
        expect(deck(cubit).suggestions.first.item.id, 0);
        expect(deck(cubit).notice, SurpriseNotice.offline);
        expect(outcomes(async, history)[0], SurpriseOutcome.viewed);
        cubit.close();
      });
    });

    test('noticeShown clears the notice', () {
      fakeAsync((async) {
        final engine = FakeSurpriseEngine(
          results: [Success(batchOf(5)), Failure(FailureReason.network)],
        );
        final cubit = openDeck(async, engine: engine);
        unawaited(cubit.reroll());
        async.elapse(SurpriseCubit.minSearchingDuration);
        async.flushMicrotasks();
        expect(deck(cubit).notice, SurpriseNotice.offline);

        cubit.noticeShown();

        expect(deck(cubit).notice, SurpriseNotice.none);
        cubit.close();
      });
    });

    test('a batch that needed the search widened says so, once', () {
      fakeAsync((async) {
        final cubit = openDeck(
          async,
          engine: FakeSurpriseEngine.returning(
            batchOf(5, relaxations: const [SurpriseRelaxation.widenYears]),
          ),
        );

        expect(deck(cubit).notice, SurpriseNotice.widenedSearch);
        cubit.noticeShown();
        expect(deck(cubit).notice, SurpriseNotice.none);
        cubit.close();
      });
    });

    test('a card that stays on top for 3 s counts as revisited — but not if '
        'the deck moves on first or the user leaves', () {
      fakeAsync((async) {
        final history = InMemorySurpriseHistoryRepository();
        final cubit = openDeck(async, history: history);

        async.elapse(const Duration(seconds: 2));
        cubit.next(); // card 0 left before 3 s
        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        var o = outcomes(async, history);
        expect(o[0], SurpriseOutcome.viewed);
        expect(o[1], SurpriseOutcome.revisited, reason: 'lingered on 3 s');

        cubit.next();
        cubit.closeDeck(); // leaves: the timer is stopped
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        o = outcomes(async, history);
        expect(o[2], SurpriseOutcome.viewed);
        cubit.close();
      });
    });

    test('a card that comes back (the deck cycles, or a thumbnail) counts as '
        'revisited at once', () {
      fakeAsync((async) {
        final history = InMemorySurpriseHistoryRepository();
        final cubit = openDeck(async, history: history);

        cubit.next();
        cubit.next();
        expect(outcomes(async, history)[1], SurpriseOutcome.viewed);

        cubit.jumpTo(1); // back to a card already seen
        async.flushMicrotasks();

        expect(outcomes(async, history)[1], SurpriseOutcome.revisited);
        expect(outcomes(async, history)[3], SurpriseOutcome.viewed);
        cubit.close();
      });
    });
  });
}
