import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
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

SurpriseCubit _cubit({
  required FakeSurpriseEngine engine,
  TasteProfile? profile,
  List<UserMediaEntry> libraryEntries = const [],
  SurpriseHistoryRepository? history,
  DateTime Function()? clock,
  String Function()? region,
}) {
  return SurpriseCubit(
    engine,
    TasteProfileBuilder(_emptyVibeCatalog),
    _FakeTasteProfileRepository(profile),
    _FakeUserLibraryRepository(libraryEntries),
    history: history,
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

  group('SurpriseCubit — another() rotation', () {
    test('rotates through the whole pool, calling the engine only '
        'once, then emits Exhausted on the 6th call', () {
      fakeAsync((async) {
        final engine = FakeSurpriseEngine.returning(batchOf(5));
        final cubit = _cubit(engine: engine, profile: _profile());

        unawaited(cubit.chooseType(MediaType.movie));
        async.flushMicrotasks();
        unawaited(cubit.useMyTastes());
        async.elapse(SurpriseCubit.minSearchingDuration);

        final firstResult = cubit.state as SurpriseResult;
        expect(firstResult.index, 0);

        for (var i = 1; i < 5; i++) {
          cubit.another();
          expect((cubit.state as SurpriseResult).index, i);
        }

        // All 5 shown — the next call exhausts the pool.
        cubit.another();
        expect(cubit.state, isA<Exhausted>());

        // Only the initial chooseType() call ever reached the engine.
        expect(engine.callCount, 1);

        cubit.close();
      });
    });

    test('another() is a no-op outside of SurpriseResult', () {
      final engine = FakeSurpriseEngine();
      final cubit = _cubit(engine: engine);

      cubit.another();
      expect(cubit.state, isA<ChoosingType>());

      cubit.close();
    });
  });

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

        // Walk past the fifth: Exhausted, then ask again.
        for (var i = 0; i < 5; i++) {
          cubit.another();
        }
        expect(cubit.state, isA<Exhausted>());
        unawaited(cubit.retry());
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

    test('"Another suggestion" marks the one left behind as discarded; a '
        'saved or opened one is recorded as such', () {
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
        cubit.another(); // …and left behind: discarded overrides
        async.flushMicrotasks();
        cubit.recordOutcome(SurpriseOutcome.seen); // title 1 opened
        async.flushMicrotasks();

        late List<SurpriseHistoryEntry> all;
        unawaited(
          history.all().then(
            (r) => all = (r as Success<List<SurpriseHistoryEntry>>).value,
          ),
        );
        async.flushMicrotasks();
        final byId = {for (final e in all) e.key.tmdbId: e.outcome};
        expect(byId[0], SurpriseOutcome.discarded);
        expect(byId[1], SurpriseOutcome.seen);
        expect(byId[2], SurpriseOutcome.shown);
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

    test('nothing found on a first search is an error; after earlier batches '
        'it is "that\'s all for now"', () {
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
        for (var i = 0; i < 5; i++) {
          b.another();
        }
        unawaited(b.retry());
        async.elapse(SurpriseCubit.minSearchingDuration);
        expect(b.state, isA<Exhausted>());
        b.close();
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
}
