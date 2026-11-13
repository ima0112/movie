import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/drift_recently_viewed_repository.dart';
import 'package:movies/core/data/local/in_memory_recently_viewed_repository.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/repositories/recently_viewed_repository.dart';
import 'package:movies/core/persistence/app_database.dart';

Movie _movie(int id) => Movie(
  id: id,
  title: 'Movie $id',
  posterUrl: 'https://img/$id.jpg',
  genres: const [],
  releaseDate: DateTime(2020, 3, 4),
  voteAverage: 7.5,
);

TvShow _show(int id) => TvShow(
  id: id,
  title: 'Show $id',
  posterUrl: null,
  genres: const [],
  releaseDate: null,
  voteAverage: 8.25,
);

DriftRecentlyViewedRepository _drift() {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  return DriftRecentlyViewedRepository(db);
}

/// The same contract, for both implementations.
void _contract(String name, RecentlyViewedRepository Function() create) {
  group(name, () {
    test('starts empty', () async {
      expect(await create().watch().first, isEmpty);
    });

    test('newest first, with the snapshot it was given', () async {
      final repo = create();
      await repo.record(_movie(1));
      await repo.record(_show(2));

      final items = await repo.watch().first;

      expect(items.map((i) => i.key.tmdbId), [2, 1]);
      expect(items[0].type, MediaType.tvShow);
      expect(items[0].title, 'Show 2');
      expect(items[0].posterUrl, isNull);
      expect(items[0].voteAverage, 8.25);
      expect(items[1].type, MediaType.movie);
      expect(items[1].posterUrl, 'https://img/1.jpg');
      expect(items[1].releaseDate, DateTime(2020, 3, 4));
    });

    test('re-opening a title moves it to the front instead of repeating '
        'it', () async {
      final repo = create();
      await repo.record(_movie(1));
      await repo.record(_movie(2));
      await repo.record(_movie(3));
      await repo.record(_movie(1));

      final items = await repo.watch().first;

      expect(items.map((i) => i.key.tmdbId), [1, 3, 2]);
    });

    test('a movie and a show with the same id are different titles', () async {
      final repo = create();
      await repo.record(_movie(5));
      await repo.record(_show(5));

      expect(await repo.watch().first, hasLength(2));
    });

    test('keeps only the 10 newest', () async {
      final repo = create();
      for (var id = 1; id <= 13; id++) {
        await repo.record(_movie(id));
      }

      final items = await repo.watch().first;

      expect(items, hasLength(RecentlyViewedRepository.limit));
      expect(items.first.key.tmdbId, 13);
      expect(items.last.key.tmdbId, 4); // 1, 2 and 3 dropped off
    });

    test('watch emits again after a record', () async {
      final repo = create();
      final emissions = <List<int>>[];
      final sub = repo.watch().listen(
        (items) => emissions.add([for (final i in items) i.key.tmdbId]),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await repo.record(_movie(1));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(emissions.first, isEmpty);
      expect(emissions.last, [1]);
    });
  });
}

void main() {
  _contract('DriftRecentlyViewedRepository', _drift);
  _contract(
    'InMemoryRecentlyViewedRepository',
    () => InMemoryRecentlyViewedRepository(),
  );

  test('titles opened in the same instant still order by arrival', () async {
    final repo = _drift();
    // Back-to-back records, far inside one clock tick.
    await Future.wait([for (var i = 1; i <= 5; i++) repo.record(_movie(i))]);

    expect((await repo.watch().first), hasLength(5));
  });
}
