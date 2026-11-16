import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/drift_taste_profile_repository.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/taste_profile.dart';
import 'package:movies/core/persistence/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

TasteProfile _base() => TasteProfile(
  likedGenres: {const Genre(id: 'drama')},
  vetoedGenres: const {},
  likedVibes: const {},
  yearFrom: 1990,
  updatedAt: DateTime(2026),
);

DriftTasteProfileRepository _repo() {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  return DriftTasteProfileRepository(db);
}

void main() {
  group('the type, eras and platforms round-trip through drift', () {
    test('all three set', () async {
      final repo = _repo();
      final profile = _base().copyWith(
        yearTo: 2020,
        preferredType: MediaType.tvShow,
        platformIds: {8, 337},
      );

      await repo.save(profile);
      final saved = (await repo.watch().first)!;

      expect(saved.yearTo, 2020);
      expect(saved.preferredType, MediaType.tvShow);
      expect(saved.platformIds, {8, 337});
    });

    test('left at their defaults: no upper bound, both types, no '
        'platforms', () async {
      final repo = _repo();

      await repo.save(_base());
      final saved = (await repo.watch().first)!;

      expect(saved.yearTo, isNull);
      expect(saved.preferredType, isNull);
      expect(saved.platformIds, isEmpty);
    });

    test('clearing them writes them back to null / empty', () async {
      final repo = _repo();
      await repo.save(
        _base().copyWith(
          yearTo: 2020,
          preferredType: MediaType.movie,
          platformIds: {8},
        ),
      );

      await repo.save(
        _base().copyWith(
          clearYearTo: true,
          clearPreferredType: true,
          platformIds: const {},
        ),
      );
      final saved = (await repo.watch().first)!;

      expect(saved.yearTo, isNull);
      expect(saved.preferredType, isNull);
      expect(saved.platformIds, isEmpty);
    });
  });

  test('upgrading from schema v9 adds the three columns and keeps the saved '
      'profile', () async {
    final raw = sqlite3.sqlite3.openInMemory();
    raw.execute(
      'CREATE TABLE taste_profile_table ('
      'id INTEGER NOT NULL DEFAULT 0, liked_genres TEXT NOT NULL, '
      'vetoed_genres TEXT NOT NULL, liked_vibes TEXT NOT NULL, '
      'year_from INTEGER NOT NULL, updated_at INTEGER NOT NULL, '
      'PRIMARY KEY (id));',
    );
    raw.execute(
      "INSERT INTO taste_profile_table VALUES (0, 'drama', '', 'cozy', 1990, 0);",
    );
    raw.execute('PRAGMA user_version = 9;');
    final db = AppDatabase.forTesting(NativeDatabase.opened(raw));
    addTearDown(db.close);

    final saved = (await DriftTasteProfileRepository(db).watch().first)!;

    expect(saved.likedGenres, {const Genre(id: 'drama')});
    expect(saved.yearFrom, 1990);
    expect(saved.yearTo, isNull);
    expect(saved.preferredType, isNull);
    expect(saved.platformIds, isEmpty);
  });

  group('TasteProfile', () {
    test('copyWith replaces only what it is given and the new fields take '
        'part in equality', () {
      final a = _base().copyWith(
        yearTo: 2000,
        platformIds: {1},
        updatedAt: DateTime(2026),
      );

      expect(a.likedGenres, _base().likedGenres);
      expect(a, a.copyWith(updatedAt: DateTime(2026)));
      expect(a == a.copyWith(yearTo: 2001, updatedAt: DateTime(2026)), false);
      expect(
        a == a.copyWith(platformIds: {2}, updatedAt: DateTime(2026)),
        false,
      );
      expect(
        a ==
            a.copyWith(
              preferredType: MediaType.movie,
              updatedAt: DateTime(2026),
            ),
        false,
      );
    });
  });
}
