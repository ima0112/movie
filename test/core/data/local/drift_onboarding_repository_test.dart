import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/drift_onboarding_repository.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/persistence/app_database.dart';

/// A fresh repository over an in-memory database — see
/// `drift_user_library_repository_test.dart`'s own version of this
/// helper for why (never touches disk or `path_provider`).
DriftOnboardingRepository _repository() {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  return DriftOnboardingRepository(db);
}

void main() {
  group('DriftOnboardingRepository', () {
    test('isCompleted starts false, before load() ever runs', () {
      final repository = _repository();

      expect(repository.isCompleted, isFalse);
    });

    test(
      'load() leaves isCompleted false when nothing was ever saved',
      () async {
        final repository = _repository();

        await repository.load();

        expect(repository.isCompleted, isFalse);
      },
    );

    test('markCompleted() flips isCompleted immediately, with no load() '
        'needed', () async {
      final repository = _repository();

      final result = await repository.markCompleted();

      expect(result, isA<Success<void>>());
      expect(repository.isCompleted, isTrue);
    });

    test('load() picks up a previously marked-completed flag from a '
        'fresh instance over the same database', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      await DriftOnboardingRepository(db).markCompleted();

      final reloaded = DriftOnboardingRepository(db);
      expect(reloaded.isCompleted, isFalse); // before load()
      await reloaded.load();

      expect(reloaded.isCompleted, isTrue);
    });

    test('markCompleted() is idempotent — calling it twice stays a '
        'single row', () async {
      final repository = _repository();

      await repository.markCompleted();
      final result = await repository.markCompleted();

      expect(result, isA<Success<void>>());
      expect(repository.isCompleted, isTrue);
    });
  });
}
