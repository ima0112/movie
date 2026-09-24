import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/persistence/app_database.dart';
import 'package:movies/features/explore/data/drift_search_history_repository.dart';

/// A fresh repository over an in-memory database — see
/// `drift_user_library_repository_test.dart`'s own version of this
/// helper for why (never touches disk or `path_provider`).
DriftSearchHistoryRepository _repository() {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  return DriftSearchHistoryRepository(db);
}

void main() {
  group('DriftSearchHistoryRepository', () {
    test('watch() emits an empty list before anything is recorded', () async {
      final repository = _repository();

      expect(await repository.watch().first, isEmpty);
    });

    test('record() adds a query, most recent first', () async {
      final repository = _repository();

      await repository.record('dune');
      await repository.record('oppenheimer');

      expect(await repository.watch().first, ['oppenheimer', 'dune']);
    });

    test('re-recording an existing query moves it to the front instead '
        'of duplicating it', () async {
      final repository = _repository();
      await repository.record('dune');
      await repository.record('oppenheimer');

      await repository.record('dune');

      expect(await repository.watch().first, ['dune', 'oppenheimer']);
    });

    test('a blank query is a no-op', () async {
      final repository = _repository();

      final result = await repository.record('   ');

      expect(result, isA<Success<void>>());
      expect(await repository.watch().first, isEmpty);
    });

    test('caps at 10, dropping the oldest', () async {
      final repository = _repository();
      for (var i = 0; i < 12; i++) {
        await repository.record('query$i');
      }

      final history = await repository.watch().first;

      expect(history, hasLength(10));
      expect(history.first, 'query11');
      expect(history.contains('query0'), isFalse);
      expect(history.contains('query1'), isFalse);
    });

    test('remove() deletes a single entry', () async {
      final repository = _repository();
      await repository.record('dune');
      await repository.record('oppenheimer');

      await repository.remove('dune');

      expect(await repository.watch().first, ['oppenheimer']);
    });

    test('clear() removes everything', () async {
      final repository = _repository();
      await repository.record('dune');
      await repository.record('oppenheimer');

      await repository.clear();

      expect(await repository.watch().first, isEmpty);
    });
  });
}
