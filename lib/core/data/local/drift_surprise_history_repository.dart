import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/genre.dart';
import '../../domain/entities/media_key.dart';
import '../../domain/entities/media_type.dart';
import '../../domain/entities/result.dart';
import '../../domain/entities/surprise_history_entry.dart';
import '../../domain/repositories/surprise_history_repository.dart';
import '../../persistence/app_database.dart';

/// Persistent [SurpriseHistoryRepository]: SQLite (drift) through the app's
/// one [AppDatabase].
@LazySingleton(as: SurpriseHistoryRepository)
class DriftSurpriseHistoryRepository implements SurpriseHistoryRepository {
  DriftSurpriseHistoryRepository(this._db);

  final AppDatabase _db;

  @override
  Future<Result<void>> recordShown(List<SurpriseHistoryEntry> entries) async {
    try {
      await _db.batch((batch) {
        for (final entry in entries) {
          batch.insert(
            _db.surpriseHistoryTable,
            SurpriseHistoryTableCompanion.insert(
              mediaType: entry.key.type,
              tmdbId: entry.key.tmdbId,
              sessionId: entry.sessionId,
              shownAt: entry.shownAt,
              outcome: entry.outcome,
              batch: Value(entry.batch),
              genres: Value(entry.genres.map((g) => g.id).join(',')),
            ),
            // A title shown again in the same session keeps its first row.
            mode: InsertMode.insertOrIgnore,
          );
        }
      });
      return const Success(null);
    } catch (_) {
      return Failure(FailureReason.storage);
    }
  }

  @override
  Future<Result<void>> setOutcome({
    required String sessionId,
    required MediaKey key,
    required SurpriseOutcome outcome,
  }) async {
    try {
      final match = _db.select(_db.surpriseHistoryTable)
        ..where(
          (row) =>
              row.sessionId.equals(sessionId) &
              row.mediaType.equalsValue(key.type) &
              row.tmdbId.equals(key.tmdbId),
        );
      final row = await match.getSingleOrNull();
      // Never replace a stronger outcome with a weaker one.
      if (row == null || !outcome.canReplace(row.outcome)) {
        return const Success(null);
      }
      await (_db.update(_db.surpriseHistoryTable)..where(
            (r) =>
                r.sessionId.equals(sessionId) &
                r.mediaType.equalsValue(key.type) &
                r.tmdbId.equals(key.tmdbId),
          ))
          .write(SurpriseHistoryTableCompanion(outcome: Value(outcome)));
      return const Success(null);
    } catch (_) {
      return Failure(FailureReason.storage);
    }
  }

  @override
  Future<Result<void>> markBatchRerolled({
    required String sessionId,
    required int batch,
  }) async {
    try {
      final inBatch = _db.select(_db.surpriseHistoryTable)
        ..where((r) => r.sessionId.equals(sessionId) & r.batch.equals(batch));
      final rows = await inBatch.get();
      if (rows.any((r) => r.outcome.isPick)) return const Success(null);
      await (_db.update(_db.surpriseHistoryTable)..where(
            (r) =>
                r.sessionId.equals(sessionId) &
                r.batch.equals(batch) &
                r.outcome.equalsValue(SurpriseOutcome.viewed),
          ))
          .write(
            const SurpriseHistoryTableCompanion(
              outcome: Value(SurpriseOutcome.rerolled),
            ),
          );
      return const Success(null);
    } catch (_) {
      return Failure(FailureReason.storage);
    }
  }

  @override
  Future<Result<Set<MediaKey>>> shownKeys(
    MediaType type, {
    String? sessionId,
    DateTime? since,
  }) async {
    try {
      final query = _db.select(_db.surpriseHistoryTable)
        ..where((row) {
          var condition = row.mediaType.equalsValue(type);
          if (sessionId != null) {
            condition = condition & row.sessionId.equals(sessionId);
          }
          if (since != null) {
            condition = condition & row.shownAt.isBiggerOrEqualValue(since);
          }
          return condition;
        });
      final rows = await query.get();
      return Success({
        for (final row in rows)
          MediaKey(type: row.mediaType, tmdbId: row.tmdbId),
      });
    } catch (_) {
      return Failure(FailureReason.storage);
    }
  }

  @override
  Future<Result<List<SurpriseHistoryEntry>>> all() async {
    try {
      final rows = await (_db.select(
        _db.surpriseHistoryTable,
      )..orderBy([(row) => OrderingTerm.desc(row.shownAt)])).get();
      return Success([for (final row in rows) _toEntry(row)]);
    } catch (_) {
      return Failure(FailureReason.storage);
    }
  }

  @override
  Stream<List<SurpriseHistoryEntry>> watchAll() =>
      (_db.select(_db.surpriseHistoryTable)
            ..orderBy([(row) => OrderingTerm.desc(row.shownAt)]))
          .watch()
          .map((rows) => [for (final row in rows) _toEntry(row)]);

  static SurpriseHistoryEntry _toEntry(SurpriseHistoryRow row) =>
      SurpriseHistoryEntry(
        key: MediaKey(type: row.mediaType, tmdbId: row.tmdbId),
        sessionId: row.sessionId,
        shownAt: row.shownAt,
        batch: row.batch,
        genres: [
          for (final id in row.genres.split(','))
            if (id.isNotEmpty) Genre(id: id),
        ],
        outcome: row.outcome,
      );

  @override
  Future<Result<void>> clear() async {
    try {
      // The sessions' answers go with what they showed.
      await _db.delete(_db.surpriseHistoryTable).go();
      await _db.delete(_db.surpriseSessionTable).go();
      return const Success(null);
    } catch (_) {
      return Failure(FailureReason.storage);
    }
  }
}
