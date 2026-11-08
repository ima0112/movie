import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/drift_onboarding_repository.dart';
import 'package:movies/core/data/local/drift_taste_profile_repository.dart';
import 'package:movies/core/data/local/drift_user_library_repository.dart';
import 'package:movies/core/data/local/drift_user_profile_repository.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/taste_profile.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/core/domain/entities/user_profile.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/core/persistence/app_database.dart';

const _dune = MediaKey(type: MediaType.movie, tmdbId: 1);
const _theBear = MediaKey(type: MediaType.tvShow, tmdbId: 101);
const _action = Genre(id: 'action', name: 'Action');
const _drama = Genre(id: 'drama', name: 'Drama');

/// A fresh repository over an in-memory database — never touches disk or
/// `path_provider`, so this runs the same everywhere `flutter test` does.
/// `addTearDown` closes it once the test finishes either way.
DriftUserLibraryRepository _repository() {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  return DriftUserLibraryRepository(db);
}

void main() {
  group('DriftUserLibraryRepository', () {
    test('upsert followed by watchEntry emits the correct value', () async {
      final repository = _repository();
      const entry = UserMediaEntry(
        title: 'Test Title',
        key: _dune,
        isFavorite: true,
      );

      // Subscribing before the upsert lets `emitsInOrder` see both the
      // initial `null` (nothing saved yet) and the post-upsert value —
      // drift's `.watch()` re-queries and emits on every write on its
      // own, no manual stream plumbing needed. Same race as
      // `InMemoryUserLibraryRepository`'s own version of this test
      // though: the stream's first (pre-upsert) query needs a turn of
      // the event loop before it actually runs, or `upsert` races
      // straight past the initial `null`.
      final expectation = expectLater(
        repository.watchEntry(_dune),
        emitsInOrder([null, entry]),
      );
      await Future<void>.delayed(Duration.zero);

      final result = await repository.upsert(entry);
      await expectation;

      expect(result, isA<Success<void>>());
    });

    test('a new watchEntry subscriber immediately sees an already-saved '
        'entry, not just future changes', () async {
      final repository = _repository();
      const entry = UserMediaEntry(
        title: 'Test Title',
        key: _dune,
        isFavorite: true,
      );
      await repository.upsert(entry);

      final first = await repository.watchEntry(_dune).first;

      expect(first, entry);
    });

    test(
      'marking as watched clears isWatchLater on the emitted entry',
      () async {
        final repository = _repository();
        const inWatchLater = UserMediaEntry(
          title: 'Test Title',
          key: _dune,
          isWatchLater: true,
        );
        await repository.upsert(inWatchLater);
        expect(
          (await repository.watchEntry(_dune).first)!.isWatchLater,
          isTrue,
        );

        final watched = inWatchLater.markWatched(rating: 5);
        await repository.upsert(watched);

        final updated = await repository.watchEntry(_dune).first;
        expect(updated!.isWatchLater, isFalse);
        expect(updated.isWatched, isTrue);
        expect(updated.rating, 5);
      },
    );

    test('watch() filters by tab and type', () async {
      final repository = _repository();
      await repository.upsert(
        const UserMediaEntry(title: 'Test Title', key: _dune, isFavorite: true),
      );
      await repository.upsert(
        const UserMediaEntry(
          title: 'Test Title',
          key: _theBear,
          isWatchLater: true,
        ),
      );

      final favorites = await repository.watch(tab: LibraryTab.favorites).first;
      expect(favorites.map((e) => e.key), [_dune]);

      final movies = await repository.watch(type: MediaType.movie).first;
      expect(movies.map((e) => e.key), [_dune]);

      final all = await repository.watch().first;
      expect(all, hasLength(2));
    });

    test('remove deletes the entry', () async {
      final repository = _repository();
      await repository.upsert(
        const UserMediaEntry(title: 'Test Title', key: _dune),
      );

      final result = await repository.remove(_dune);

      expect(result, isA<Success<void>>());
      expect(await repository.watchEntry(_dune).first, isNull);
    });

    test('watchedKeys returns only watched items of the given type, most '
        'recent first', () async {
      final repository = _repository();
      await repository.upsert(
        UserMediaEntry(
          title: 'Test Title',
          key: _dune,
          watchedAt: DateTime(2024, 1, 1),
        ),
      );
      await repository.upsert(
        UserMediaEntry(
          title: 'Test Title',
          key: const MediaKey(type: MediaType.movie, tmdbId: 2),
          watchedAt: DateTime(2024, 6, 1),
        ),
      );
      await repository.upsert(
        UserMediaEntry(
          title: 'Test Title',
          key: _theBear,
          watchedAt: DateTime(2024, 3, 1),
        ),
      );

      final result = await repository.watchedKeys(MediaType.movie);

      final keys = (result as Success<List<MediaKey>>).value;
      expect(keys, [const MediaKey(type: MediaType.movie, tmdbId: 2), _dune]);
    });

    test('all returns every stored entry', () async {
      final repository = _repository();
      await repository.upsert(
        const UserMediaEntry(title: 'Test Title', key: _dune),
      );
      await repository.upsert(
        const UserMediaEntry(title: 'Test Title', key: _theBear),
      );

      final result = await repository.all();

      expect((result as Success<List<UserMediaEntry>>).value, hasLength(2));
    });

    test('upsert persists and watchEntry returns the duration snapshot '
        '(runtimeMinutes for a movie, episodeCount/episodeRuntimeMinutes '
        'for a TV show)', () async {
      final repository = _repository();
      await repository.upsert(
        UserMediaEntry(
          title: 'Test Title',
          key: _dune,
          watchedAt: DateTime(2024, 1, 1),
          runtimeMinutes: 166,
        ),
      );
      await repository.upsert(
        UserMediaEntry(
          title: 'Test Title',
          key: _theBear,
          watchedAt: DateTime(2024, 1, 1),
          episodeCount: 62,
          episodeRuntimeMinutes: 24,
        ),
      );

      final movie = await repository.watchEntry(_dune).first;
      final show = await repository.watchEntry(_theBear).first;

      expect(movie!.runtimeMinutes, 166);
      expect(show!.episodeCount, 62);
      expect(show.episodeRuntimeMinutes, 24);
    });

    test('an entry saved with no duration fields at all (as every entry was '
        'before this column existed) reads back with them null, not an '
        'error', () async {
      final repository = _repository();
      // No runtimeMinutes/episodeCount/episodeRuntimeMinutes passed —
      // exactly what every pre-migration watched entry looks like.
      await repository.upsert(
        UserMediaEntry(
          title: 'Test Title',
          key: _dune,
          watchedAt: DateTime(2024, 1, 1),
        ),
      );

      final entry = await repository.watchEntry(_dune).first;

      expect(entry!.runtimeMinutes, isNull);
      expect(entry.episodeCount, isNull);
      expect(entry.episodeRuntimeMinutes, isNull);
    });

    test('upsert persists and watchEntry returns genres, in order', () async {
      final repository = _repository();

      await repository.upsert(
        const UserMediaEntry(
          title: 'Test Title',
          key: _dune,
          isFavorite: true,
          genres: [_action, _drama],
        ),
      );

      final entry = await repository.watchEntry(_dune).first;

      expect(entry!.genres, [_action, _drama]);
    });

    test('an entry saved with no genres reads back as an empty list, not '
        'null or an error', () async {
      final repository = _repository();
      await repository.upsert(
        const UserMediaEntry(title: 'Test Title', key: _dune),
      );

      final entry = await repository.watchEntry(_dune).first;

      expect(entry!.genres, isEmpty);
    });

    group('clearAll', () {
      test('removes every entry', () async {
        final repository = _repository();
        await repository.upsert(
          const UserMediaEntry(title: 'Dune', key: _dune, isFavorite: true),
        );
        await repository.upsert(
          const UserMediaEntry(
            title: 'The Bear',
            key: _theBear,
            isWatchLater: true,
          ),
        );

        final result = await repository.clearAll();

        expect(result, isA<Success<void>>());
        expect((await repository.all() as Success).value, isEmpty);
      });

      test(
        '"Delete My List" touches nothing else — the user profile, the '
        'taste profile, and the onboarding flag all survive untouched',
        () async {
          final db = AppDatabase.forTesting(NativeDatabase.memory());
          addTearDown(db.close);

          await DriftUserProfileRepository(db).save(
            const UserProfile(displayName: 'Daniel', initialColor: 0xFFF2B441),
          );
          await DriftTasteProfileRepository(db).save(
            TasteProfile(
              likedGenres: {_action},
              vetoedGenres: const {},
              likedVibes: const {'Cozy'},
              yearFrom: 1990,
              updatedAt: DateTime(2024, 1, 1),
            ),
          );
          await DriftOnboardingRepository(db).markCompleted();
          final library = DriftUserLibraryRepository(db);
          await library.upsert(const UserMediaEntry(title: 'Dune', key: _dune));

          final result = await library.clearAll();

          expect(result, isA<Success<void>>());
          expect((await library.all() as Success).value, isEmpty);
          expect(
            (await DriftUserProfileRepository(db).watch().first)?.displayName,
            'Daniel',
          );
          expect(
            (await DriftTasteProfileRepository(db).watch().first)?.likedGenres,
            {_action},
          );
          final onboarding = DriftOnboardingRepository(db);
          await onboarding.load();
          expect(onboarding.isCompleted, isTrue);
        },
      );
    });
  });
}
