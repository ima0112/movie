import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

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
      await (_db.update(_db.surpriseHistoryTable)..where(
            (row) =>
                row.sessionId.equals(sessionId) &
                row.mediaType.equalsValue(key.type) &
                row.tmdbId.equals(key.tmdbId),
          ))
          .write(SurpriseHistoryTableCompanion(outcome: Value(outcome)));
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
      return Success([
        for (final row in rows)
          SurpriseHistoryEntry(
            key: MediaKey(type: row.mediaType, tmdbId: row.tmdbId),
            sessionId: row.sessionId,
            shownAt: row.shownAt,
            outcome: row.outcome,
          ),
      ]);
    } catch (_) {
      return Failure(FailureReason.storage);
    }
  }

  @override
  Future<Result<void>> clear() async {
    try {
      await _db.delete(_db.surpriseHistoryTable).go();
      return const Success(null);
    } catch (_) {
      return Failure(FailureReason.storage);
    }
  }
}
