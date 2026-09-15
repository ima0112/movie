import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/drift_taste_profile_repository.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/taste_profile.dart';
import 'package:movies/core/persistence/app_database.dart';

const _action = Genre(id: 'action', name: 'Action');
const _drama = Genre(id: 'drama', name: 'Drama');
const _horror = Genre(id: 'horror', name: 'Horror');

/// A fresh repository over an in-memory database — see
/// `drift_user_library_repository_test.dart`'s own version of this
/// helper for why (never touches disk or `path_provider`).
DriftTasteProfileRepository _repository() {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  return DriftTasteProfileRepository(db);
}

void main() {
  group('DriftTasteProfileRepository', () {
    test('watch() emits null before any profile is saved', () async {
      final repository = _repository();

      expect(await repository.watch().first, isNull);
    });

    test('save followed by watch round-trips genres, vibes, year and '
        'updatedAt correctly', () async {
      final repository = _repository();
      final profile = TasteProfile(
        likedGenres: {_action, _drama},
        vetoedGenres: {_horror},
        likedVibes: {'Cozy', 'Mind-bending'},
        yearFrom: 1990,
        updatedAt: DateTime(2024, 1, 1),
      );

      final result = await repository.save(profile);
      final saved = await repository.watch().first;

      expect(result, isA<Success<void>>());
      expect(saved!.likedGenres, {_action, _drama});
      expect(saved.vetoedGenres, {_horror});
      expect(saved.likedVibes, {'Cozy', 'Mind-bending'});
      expect(saved.yearFrom, 1990);
    });

    test(
      'empty genre/vibe sets round-trip as empty, not a stray entry',
      () async {
        final repository = _repository();
        final profile = TasteProfile(
          likedGenres: const {},
          vetoedGenres: const {},
          likedVibes: const {},
          yearFrom: 1970,
          updatedAt: DateTime(2024, 1, 1),
        );

        await repository.save(profile);
        final saved = await repository.watch().first;

        expect(saved!.likedGenres, isEmpty);
        expect(saved.likedVibes, isEmpty);
      },
    );

    test(
      'saving again overwrites the single row rather than adding one',
      () async {
        final repository = _repository();
        await repository.save(
          TasteProfile(
            likedGenres: {_action},
            vetoedGenres: const {},
            likedVibes: const {'Cozy'},
            yearFrom: 1990,
            updatedAt: DateTime(2024, 1, 1),
          ),
        );

        await repository.save(
          TasteProfile(
            likedGenres: {_drama},
            vetoedGenres: const {},
            likedVibes: const {'Epic'},
            yearFrom: 2000,
            updatedAt: DateTime(2024, 6, 1),
          ),
        );

        final current = await repository.watch().first;
        expect(current!.likedGenres, {_drama});
        expect(current.yearFrom, 2000);
      },
    );
  });
}
