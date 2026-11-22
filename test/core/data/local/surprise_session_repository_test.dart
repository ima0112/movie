import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/drift_surprise_history_repository.dart';
import 'package:movies/core/data/local/drift_surprise_session_repository.dart';
import 'package:movies/core/data/local/in_memory_surprise_session_repository.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/surprise_session.dart';
import 'package:movies/core/domain/repositories/surprise_session_repository.dart';
import 'package:movies/core/persistence/app_database.dart';

SurpriseSession _session(
  String id,
  DateTime at, {
  Set<String> relaxations = const {},
}) => SurpriseSession(
  sessionId: id,
  startedAt: at,
  mediaType: MediaType.tvShow,
  source: SurpriseSessionSource.quiz,
  yearFrom: 1990,
  yearTo: 2020,
  collectionIds: const {'turkish_series'},
  vibeIds: const {'revenge', 'survival'},
  excludedGenres: {const Genre(id: 'horror')},
  platformIds: const {8, 337},
  relaxations: relaxations,
);

Future<List<SurpriseSession>> _all(SurpriseSessionRepository repo) async =>
    ((await repo.all()) as Success<List<SurpriseSession>>).value;

/// The same contract, for both implementations.
void _contract(String name, SurpriseSessionRepository Function() create) {
  group(name, () {
    final t0 = DateTime(2026, 11, 1);
    final t1 = DateTime(2026, 11, 10);

    test('what a session asked for comes back as it was recorded', () async {
      final repo = create();
      await repo.recordBatch(_session('a', t0));
      final s = (await _all(repo)).single;

      expect(s.sessionId, 'a');
      expect(s.startedAt, t0);
      expect(s.mediaType, MediaType.tvShow);
      expect(s.source, SurpriseSessionSource.quiz);
      expect(s.collectionIds, {'turkish_series'});
      expect(s.vibeIds, {'revenge', 'survival'});
      expect(s.excludedGenres, {const Genre(id: 'horror')});
      expect(s.platformIds, {8, 337});
      expect(s.yearFrom, 1990);
      expect(s.yearTo, 2020);
      expect(s.relaxations, isEmpty);
    });

    test('a later batch of the same session keeps its answers and adds the '
        'relaxations it needed', () async {
      final repo = create();
      await repo.recordBatch(_session('a', t0));
      await repo.recordBatch(_session('a', t1, relaxations: {'dropVibes'}));
      await repo.recordBatch(
        _session('a', t1, relaxations: {'lowerVoteCount'}),
      );

      final all = await _all(repo);
      expect(all, hasLength(1));
      expect(all.single.startedAt, t0);
      expect(all.single.relaxations, {'dropVibes', 'lowerVoteCount'});
    });

    test('newest first, and clear forgets everything', () async {
      final repo = create();
      await repo.recordBatch(_session('old', t0));
      await repo.recordBatch(_session('new', t1));
      expect((await _all(repo)).map((s) => s.sessionId), ['new', 'old']);

      await repo.clear();
      expect(await _all(repo), isEmpty);
    });
  });
}

void main() {
  _contract('in memory', InMemorySurpriseSessionRepository.new);
  _contract('drift', () {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    return DriftSurpriseSessionRepository(db);
  });

  test('clearing the Surprise-me history also clears the sessions\' '
      'answers', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final sessions = DriftSurpriseSessionRepository(db);
    await sessions.recordBatch(_session('a', DateTime(2026, 11, 1)));

    await DriftSurpriseHistoryRepository(db).clear();

    expect(await _all(sessions), isEmpty);
  });
}
