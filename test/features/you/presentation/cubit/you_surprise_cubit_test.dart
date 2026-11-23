import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_surprise_history_repository.dart';
import 'package:movies/core/data/local/in_memory_surprise_session_repository.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/surprise_history_entry.dart';
import 'package:movies/core/domain/entities/surprise_session.dart';
import 'package:movies/core/domain/stats/surprise_summary.dart';
import 'package:movies/features/you/presentation/cubit/you_surprise_cubit.dart';

SurpriseSession _session(String id) => SurpriseSession(
  sessionId: id,
  startedAt: DateTime(2026, 11, 20),
  mediaType: MediaType.movie,
  source: SurpriseSessionSource.quiz,
  yearFrom: 2000,
);

void main() {
  test('null until read, then the summary, following both records', () async {
    final sessions = InMemorySurpriseSessionRepository();
    final history = InMemorySurpriseHistoryRepository();
    final cubit = YouSurpriseCubit(sessions, history);
    addTearDown(cubit.close);
    expect(cubit.state, isNull);

    await pumpEventQueue();
    expect(cubit.state, const SurpriseSummary(sessions: 0, picks: 0));

    await sessions.recordBatch(_session('a'));
    await pumpEventQueue();
    expect(cubit.state, const SurpriseSummary(sessions: 1, picks: 0));

    await history.recordShown([
      SurpriseHistoryEntry(
        key: const MediaKey(type: MediaType.movie, tmdbId: 1),
        sessionId: 'a',
        shownAt: DateTime(2026, 11, 20),
        batch: 1,
        genres: const [],
      ),
    ]);
    await history.setOutcome(
      sessionId: 'a',
      key: const MediaKey(type: MediaType.movie, tmdbId: 1),
      outcome: SurpriseOutcome.chosen,
    );
    await pumpEventQueue();
    expect(cubit.state, const SurpriseSummary(sessions: 1, picks: 1));

    await sessions.clear();
    await history.clear();
    await pumpEventQueue();
    expect(cubit.state, const SurpriseSummary(sessions: 0, picks: 0));
  });
}
