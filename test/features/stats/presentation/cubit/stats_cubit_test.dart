import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
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
    expect(cubit.state.stats.moviesWatched, 1);

    await library.clearAll();
    await pumpEventQueue();

    expect(cubit.state.stats.moviesWatched, 0);
    expect(cubit.state.stats.movieHours, 0);
  });
}
