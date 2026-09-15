import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/drift_user_profile_repository.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/user_profile.dart';
import 'package:movies/core/persistence/app_database.dart';

/// A fresh repository over an in-memory database — see
/// `drift_user_library_repository_test.dart`'s own version of this
/// helper for why (never touches disk or `path_provider`).
DriftUserProfileRepository _repository() {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  return DriftUserProfileRepository(db);
}

void main() {
  group('DriftUserProfileRepository', () {
    test('watch() emits null before any profile is saved', () async {
      final repository = _repository();

      expect(await repository.watch().first, isNull);
    });

    test('save followed by watch emits the saved profile', () async {
      final repository = _repository();
      const profile = UserProfile(
        displayName: 'Daniel',
        initialColor: 0xFFF2B441,
      );

      final expectation = expectLater(
        repository.watch(),
        emitsInOrder([null, profile]),
      );
      await Future<void>.delayed(Duration.zero);

      final result = await repository.save(profile);
      await expectation;

      expect(result, isA<Success<void>>());
    });

    test('a new watch() subscriber immediately sees an already-saved '
        'profile, not just future changes', () async {
      final repository = _repository();
      const profile = UserProfile(
        displayName: 'Daniel',
        initialColor: 0xFFF2B441,
      );
      await repository.save(profile);

      expect(await repository.watch().first, profile);
    });

    test(
      'saving again overwrites the single row rather than adding one',
      () async {
        final repository = _repository();
        await repository.save(
          const UserProfile(displayName: 'Daniel', initialColor: 0xFFF2B441),
        );

        await repository.save(
          const UserProfile(displayName: 'Dani', initialColor: 0xFF5A3A10),
        );

        final current = await repository.watch().first;
        expect(current!.displayName, 'Dani');
        expect(current.initialColor, 0xFF5A3A10);
      },
    );
  });
}
