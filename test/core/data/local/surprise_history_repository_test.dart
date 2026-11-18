import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/drift_surprise_history_repository.dart';
import 'package:movies/core/data/local/in_memory_surprise_history_repository.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/surprise_history_entry.dart';
import 'package:movies/core/domain/repositories/surprise_history_repository.dart';
import 'package:movies/core/persistence/app_database.dart';

MediaKey _movie(int id) => MediaKey(type: MediaType.movie, tmdbId: id);
MediaKey _show(int id) => MediaKey(type: MediaType.tvShow, tmdbId: id);

SurpriseHistoryEntry _entry(
  MediaKey key,
  String session,
  DateTime at, [
  SurpriseOutcome outcome = SurpriseOutcome.shown,
]) => SurpriseHistoryEntry(
  key: key,
  sessionId: session,
  shownAt: at,
  outcome: outcome,
);

DriftSurpriseHistoryRepository _drift() {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  return DriftSurpriseHistoryRepository(db);
}

Future<T> _ok<T>(Future<Result<T>> result) async {
  final r = await result;
  expect(r, isA<Success<T>>());
  return (r as Success<T>).value;
}

/// The same contract, for both implementations.
void _contract(String name, SurpriseHistoryRepository Function() create) {
  group(name, () {
    final t0 = DateTime(2026, 11, 1);
    final t1 = DateTime(2026, 11, 10);
    final t2 = DateTime(2026, 11, 16);

    test('starts empty', () async {
      final repo = create();

      expect(await _ok(repo.all()), isEmpty);
      expect(await _ok(repo.shownKeys(MediaType.movie)), isEmpty);
    });

    test('records what was shown, newest first', () async {
      final repo = create();
      await repo.recordShown([_entry(_movie(1), 's1', t0)]);
      await repo.recordShown([_entry(_movie(2), 's2', t2)]);
      await repo.recordShown([_entry(_movie(3), 's1', t1)]);

      final all = await _ok(repo.all());

      expect(all.map((e) => e.key.tmdbId), [2, 3, 1]);
      expect(all.every((e) => e.outcome == SurpriseOutcome.shown), isTrue);
    });

    test(
      'a title shown again in the same session keeps its first row',
      () async {
        final repo = create();
        await repo.recordShown([_entry(_movie(1), 's1', t0)]);
        await repo.recordShown([_entry(_movie(1), 's1', t2)]);

        final all = await _ok(repo.all());

        expect(all, hasLength(1));
        expect(all.single.shownAt, t0);
      },
    );

    test('the same title in another session is its own row', () async {
      final repo = create();
      await repo.recordShown([
        _entry(_movie(1), 's1', t0),
        _entry(_movie(1), 's2', t2),
      ]);

      expect(await _ok(repo.all()), hasLength(2));
    });

    test('shownKeys: by type, by session, and since a date', () async {
      final repo = create();
      await repo.recordShown([
        _entry(_movie(1), 's1', t0),
        _entry(_movie(2), 's1', t1),
        _entry(_movie(3), 's2', t2),
        _entry(_show(9), 's1', t2),
      ]);

      expect(await _ok(repo.shownKeys(MediaType.movie)), {
        _movie(1),
        _movie(2),
        _movie(3),
      });
      expect(await _ok(repo.shownKeys(MediaType.tvShow)), {_show(9)});
      expect(await _ok(repo.shownKeys(MediaType.movie, sessionId: 's1')), {
        _movie(1),
        _movie(2),
      });
      expect(await _ok(repo.shownKeys(MediaType.movie, since: t1)), {
        _movie(2),
        _movie(3),
      });
      expect(
        await _ok(repo.shownKeys(MediaType.movie, sessionId: 's1', since: t1)),
        {_movie(2)},
      );
    });

    test('setOutcome changes only that title in that session', () async {
      final repo = create();
      await repo.recordShown([
        _entry(_movie(1), 's1', t0),
        _entry(_movie(2), 's1', t0),
        _entry(_movie(1), 's2', t1),
      ]);

      await repo.setOutcome(
        sessionId: 's1',
        key: _movie(1),
        outcome: SurpriseOutcome.chosen,
      );

      final byRow = {
        for (final e in await _ok(repo.all()))
          '${e.sessionId}/${e.key.tmdbId}': e.outcome,
      };
      expect(byRow['s1/1'], SurpriseOutcome.chosen);
      expect(byRow['s1/2'], SurpriseOutcome.shown);
      expect(byRow['s2/1'], SurpriseOutcome.shown);
    });

    test('setOutcome on a title never shown is a no-op', () async {
      final repo = create();

      await repo.setOutcome(
        sessionId: 's1',
        key: _movie(1),
        outcome: SurpriseOutcome.saved,
      );

      expect(await _ok(repo.all()), isEmpty);
    });

    test('clear forgets everything', () async {
      final repo = create();
      await repo.recordShown([
        _entry(_movie(1), 's1', t0),
        _entry(_show(2), 's1', t1),
      ]);

      await repo.clear();

      expect(await _ok(repo.all()), isEmpty);
      expect(await _ok(repo.shownKeys(MediaType.movie)), isEmpty);
    });
  });
}

void main() {
  _contract('DriftSurpriseHistoryRepository', _drift);
  _contract(
    'InMemorySurpriseHistoryRepository',
    InMemorySurpriseHistoryRepository.new,
  );
}
