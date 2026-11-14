import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/drift_user_library_repository.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/core/persistence/app_database.dart';

const _key = MediaKey(type: MediaType.movie, tmdbId: 1);
const _base = UserMediaEntry(key: _key, title: 'Dune');

DriftUserLibraryRepository _drift() {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  return DriftUserLibraryRepository(db);
}

Future<UserMediaEntry> _stored(UserLibraryRepository repo) async =>
    (await repo.watchEntry(_key).first)!;

/// The same contract, for both implementations.
void _contract(String name, UserLibraryRepository Function() create) {
  group(name, () {
    test('joining a list stamps its date; the other list has none', () async {
      final repo = create();
      final before = DateTime.now().subtract(const Duration(seconds: 1));

      await repo.upsert(_base.copyWith(isFavorite: true));
      final entry = await _stored(repo);

      expect(entry.favoritedAt!.isAfter(before), isTrue);
      expect(entry.watchLaterAt, isNull);
    });

    test('staying in a list keeps its date; leaving clears it', () async {
      final repo = create();
      await repo.upsert(_base.copyWith(isWatchLater: true));
      final first = (await _stored(repo)).watchLaterAt!;

      await Future<void>.delayed(const Duration(milliseconds: 5));
      await repo.upsert((await _stored(repo)).copyWith(isFavorite: true));
      expect((await _stored(repo)).watchLaterAt, first);

      await repo.upsert((await _stored(repo)).copyWith(isWatchLater: false));
      expect((await _stored(repo)).watchLaterAt, isNull);
    });

    test('an entry saved before dates existed stays without one', () async {
      final repo = create();
      // A favorite with no date, as an old row reads.
      await repo.upsert(_base.copyWith(isFavorite: true));
      final stamped = await _stored(repo);

      await repo.upsert(stamped.copyWith(title: 'Dune: Part Two'));

      expect((await _stored(repo)).favoritedAt, stamped.favoritedAt);
    });

    test(
      'an undo (re-saving the removed entry) brings its date back',
      () async {
        final repo = create();
        await repo.upsert(_base.copyWith(isFavorite: true));
        final removed = await _stored(repo);

        await repo.remove(_key);
        await repo.upsert(removed);

        expect((await _stored(repo)).favoritedAt, removed.favoritedAt);
      },
    );

    test('marking watched drops the watch-later date, keeps the favorite '
        'one', () async {
      final repo = create();
      await repo.upsert(_base.copyWith(isFavorite: true, isWatchLater: true));
      final entry = await _stored(repo);

      await repo.upsert(entry.markWatched());
      final watched = await _stored(repo);

      expect(watched.watchLaterAt, isNull);
      expect(watched.favoritedAt, entry.favoritedAt);
    });
  });
}

void main() {
  _contract('InMemoryUserLibraryRepository', InMemoryUserLibraryRepository.new);
  _contract('DriftUserLibraryRepository', _drift);
}
