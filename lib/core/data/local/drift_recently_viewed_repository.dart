import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/media_item.dart';
import '../../domain/entities/media_type.dart';
import '../../domain/entities/result.dart';
import '../../domain/repositories/recently_viewed_repository.dart';
import '../../persistence/app_database.dart';

/// Persistent [RecentlyViewedRepository]: SQLite (drift) through the app's one
/// [AppDatabase], like every other drift repository here.
///
/// `@LazySingleton`: the detail screens write it and Home reads it, so they
/// must share one instance (and the one connection).
@LazySingleton(as: RecentlyViewedRepository)
class DriftRecentlyViewedRepository implements RecentlyViewedRepository {
  DriftRecentlyViewedRepository(this._db);

  final AppDatabase _db;

  int _lastMicros = 0;

  /// Strictly later than every stamp this instance has handed out, even when
  /// the clock doesn't tick between two calls.
  int _nextMicros() {
    final now = DateTime.now().microsecondsSinceEpoch;
    _lastMicros = now > _lastMicros ? now : _lastMicros + 1;
    return _lastMicros;
  }

  @override
  Stream<List<MediaItem>> watch() {
    final query = _db.select(_db.recentlyViewedTable)
      ..orderBy([(row) => OrderingTerm.desc(row.viewedAtMicros)])
      ..limit(RecentlyViewedRepository.limit);
    return query.watch().map((rows) => rows.map(_toItem).toList());
  }

  @override
  Future<Result<void>> record(MediaItem item) async {
    try {
      await _db
          .into(_db.recentlyViewedTable)
          .insertOnConflictUpdate(
            RecentlyViewedTableCompanion.insert(
              mediaType: item.type,
              tmdbId: item.id,
              title: item.title,
              posterUrl: Value(item.posterUrl),
              voteAverage: item.voteAverage,
              releaseDate: Value(item.releaseDate),
              viewedAtMicros: _nextMicros(),
            ),
          );
      await _trim();
      return const Success(null);
    } catch (_) {
      return Failure(FailureReason.storage);
    }
  }

  /// Keeps only the newest [RecentlyViewedRepository.limit] rows, so the table
  /// never grows past what Home shows.
  Future<void> _trim() async {
    final all = await (_db.select(
      _db.recentlyViewedTable,
    )..orderBy([(row) => OrderingTerm.desc(row.viewedAtMicros)])).get();
    for (final stale in all.skip(RecentlyViewedRepository.limit)) {
      await (_db.delete(_db.recentlyViewedTable)..where(
            (row) =>
                row.mediaType.equalsValue(stale.mediaType) &
                row.tmdbId.equals(stale.tmdbId),
          ))
          .go();
    }
  }

  MediaItem _toItem(RecentlyViewedRow row) => switch (row.mediaType) {
    MediaType.movie => Movie(
      id: row.tmdbId,
      title: row.title,
      posterUrl: row.posterUrl,
      genres: const [],
      releaseDate: row.releaseDate,
      voteAverage: row.voteAverage,
    ),
    MediaType.tvShow => TvShow(
      id: row.tmdbId,
      title: row.title,
      posterUrl: row.posterUrl,
      genres: const [],
      releaseDate: row.releaseDate,
      voteAverage: row.voteAverage,
    ),
  };
}
