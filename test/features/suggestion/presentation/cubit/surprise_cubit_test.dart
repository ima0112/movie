import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/taste_profile.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/core/domain/repositories/taste_profile_repository.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/features/match_engine/domain/match_engine.dart';
import 'package:movies/features/match_engine/domain/match_query.dart';
import 'package:movies/features/match_engine/domain/match_result.dart';
import 'package:movies/features/match_engine/domain/participant_answers.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';
import 'package:movies/features/suggestion/presentation/cubit/surprise_cubit.dart';
import 'package:movies/features/suggestion/presentation/cubit/surprise_state.dart';
import 'package:movies/features/taste_profile/domain/taste_profile_builder.dart';

final _emptyVibeCatalog = VibeCatalog(const []);

Movie _movie(int id) {
  return Movie(
    id: id,
    title: 'Movie $id',
    posterUrl: null,
    genres: const [],
    releaseDate: null,
    voteAverage: 8,
  );
}

MatchResult _resultWithPoolSize(int size) {
  final items = List.generate(size, _movie);
  return MatchResult(
    winner: items.first,
    alternatives: items.skip(1).toList(),
    satisfaction: const [],
    relaxationsApplied: const [],
  );
}

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

/// A [MatchEngine] whose [resolve] takes exactly [delay] to complete (or
/// never completes at all, for [neverCompletes]) — lets the timing tests
/// control the engine's own side of the race against
/// `SurpriseCubit`'s minimum/maximum durations precisely.
class _FakeMatchEngine implements MatchEngine {
  _FakeMatchEngine({
    this.delay = Duration.zero,
    this.result,
    this.neverCompletes = false,
  });

  final Duration delay;
  final MatchResult? result;
  final bool neverCompletes;
  int callCount = 0;

  @override
  Future<MatchResult?> resolve(
    MatchQuery query, {
    required MatchOptions options,
  }) async {
    callCount++;
    if (neverCompletes) {
      return Completer<MatchResult?>().future;
    }
    await Future<void>.delayed(delay);
    return result;
  }
}

SurpriseCubit _cubit({
  required _FakeMatchEngine engine,
  TasteProfile? profile,
  List<UserMediaEntry> libraryEntries = const [],
}) {
  return SurpriseCubit(
    engine,
    TasteProfileBuilder(_emptyVibeCatalog),
    _FakeTasteProfileRepository(profile),
    _FakeUserLibraryRepository(libraryEntries),
  );
}

void main() {
  group('SurpriseCubit — Searching timing', () {
    test('stays in Searching for at least 1.2s even if the engine '
        'resolves instantly', () {
      fakeAsync((async) {
        final engine = _FakeMatchEngine(result: _resultWithPoolSize(1));
        final cubit = _cubit(engine: engine, profile: _profile());

        unawaited(cubit.chooseType(MediaType.movie));
        async.flushMicrotasks();
        expect(cubit.state, isA<ChooseSource>());

        unawaited(cubit.useMyTastes());
        async.flushMicrotasks();
        expect(cubit.state, isA<Searching>());

        async.elapse(const Duration(milliseconds: 1199));
        expect(
          cubit.state,
          isA<Searching>(),
          reason: 'still short of the 1.2s minimum',
        );

        async.elapse(const Duration(milliseconds: 1));
        expect(cubit.state, isA<SurpriseResult>());

        cubit.close();
      });
    });

    test('emits SurpriseError after 8s if the engine never resolves', () {
      fakeAsync((async) {
        final engine = _FakeMatchEngine(neverCompletes: true);
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
        final engine = _FakeMatchEngine(
          delay: const Duration(seconds: 3),
          result: _resultWithPoolSize(1),
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
        final engine = _FakeMatchEngine(result: _resultWithPoolSize(5));
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
      final engine = _FakeMatchEngine();
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
        final engine = _FakeMatchEngine(result: _resultWithPoolSize(2));
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
        final engine = _FakeMatchEngine(result: _resultWithPoolSize(2));
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
        final engine = _FakeMatchEngine(result: _resultWithPoolSize(2));
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
        final engine = _FakeMatchEngine(result: _resultWithPoolSize(2));
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
        final engine = _FakeMatchEngine(result: _resultWithPoolSize(2));
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
      final cubit = _cubit(engine: _FakeMatchEngine());

      unawaited(cubit.useMyTastes());
      expect(cubit.state, isA<ChoosingType>());

      cubit.close();
    });

    test('answerQuizInstead() emits NeedsQuiz with ChooseSource\'s own '
        'mediaType, from ChooseSource', () {
      fakeAsync((async) {
        final engine = _FakeMatchEngine();
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
      final cubit = _cubit(engine: _FakeMatchEngine());

      cubit.answerQuizInstead();
      expect(cubit.state, isA<ChoosingType>());

      cubit.close();
    });

    test('answerWith (the quiz\'s own onComplete) only acts from '
        'NeedsQuiz, and sources the result as "quiz" — whether '
        'NeedsQuiz came straight from chooseType or via '
        'answerQuizInstead', () {
      fakeAsync((async) {
        final engine = _FakeMatchEngine(result: _resultWithPoolSize(2));
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
        final failingEngine = _FakeMatchEngine(neverCompletes: true);
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
      final cubit = _cubit(engine: _FakeMatchEngine());

      unawaited(cubit.retry());
      expect(cubit.state, isA<ChoosingType>());

      cubit.close();
    });
  });
}
