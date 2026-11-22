import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/stats/stats_period.dart';
import 'package:movies/core/domain/entities/surprise_session.dart';
import 'package:movies/core/domain/entities/surprise_history_entry.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/data/local/in_memory_surprise_session_repository.dart';
import 'package:movies/core/data/local/in_memory_surprise_history_repository.dart';
import 'package:movies/core/data/local/drift_user_library_repository.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/core/persistence/app_database.dart';
import 'package:movies/features/stats/presentation/cubit/stats_cubit.dart';

/// Covers this branch's own manual-verification claim ("borrar la lista
/// y comprobar que Estadísticas... se vacía"): [StatsCubit] already
/// subscribes to `UserLibraryRepository.watch()` reactively, so
/// `clearAll()` (new in a previous branch, for "Delete My List") needs
/// no extra wiring here — this proves that's actually true, not just
/// assumed from the existing subscription.
void main() {
  test('clearAll() on UserLibraryRepository zeroes an already-open '
      'StatsCubit\'s stats, with no restart', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final library = DriftUserLibraryRepository(db);
    await library.upsert(
      UserMediaEntry(
        title: 'Dune: Part Two',
        key: const MediaKey(type: MediaType.movie, tmdbId: 1),
        watchedAt: DateTime(2024, 1, 1),
        runtimeMinutes: 166,
      ),
    );

    final cubit = StatsCubit(library);
    addTearDown(cubit.close);
    await pumpEventQueue();
    expect(cubit.state.insights.moviesWatched, 1);

    await library.clearAll();
    await pumpEventQueue();

    expect(cubit.state.insights.moviesWatched, 0);
    expect(cubit.state.insights.movieHours, 0);
  });

  test('reads the Surprise-me record once and keeps it per period', () async {
    final history = InMemorySurpriseHistoryRepository();
    final sessions = InMemorySurpriseSessionRepository();
    final now = DateTime(2026, 11, 18);
    await sessions.recordBatch(
      SurpriseSession(
        sessionId: 'new',
        startedAt: DateTime(2026, 11, 3),
        mediaType: MediaType.movie,
        source: SurpriseSessionSource.quiz,
        yearFrom: 1950,
      ),
    );
    await sessions.recordBatch(
      SurpriseSession(
        sessionId: 'old',
        startedAt: DateTime(2025, 2, 3),
        mediaType: MediaType.movie,
        source: SurpriseSessionSource.quiz,
        yearFrom: 1950,
      ),
    );
    await history.recordShown([
      SurpriseHistoryEntry(
        key: const MediaKey(type: MediaType.movie, tmdbId: 1),
        sessionId: 'new',
        shownAt: DateTime(2026, 11, 3),
        outcome: SurpriseOutcome.chosen,
      ),
    ]);
    final cubit = StatsCubit(
      InMemoryUserLibraryRepository(),
      history: history,
      sessions: sessions,
      clock: () => now,
    );
    addTearDown(cubit.close);
    expect(cubit.state.surprise.isEmpty, isTrue); // before it has read them

    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.surprise.hitRate!.sessions, 2);

    cubit.selectPeriod(StatsPeriod.thisMonth);
    expect(cubit.state.surprise.hitRate!.sessions, 1);
    expect(cubit.state.surprise.hitRate!.chosenSessions, 1);
  });
}
