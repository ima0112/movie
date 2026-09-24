import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../core/domain/entities/result.dart';
import '../../../core/persistence/app_database.dart';
import '../domain/search_history_repository.dart';

/// Persistent implementation of [SearchHistoryRepository] — SQLite
/// (drift) via [AppDatabase], the same shared connection every other
/// drift repository in this app uses.
///
/// `@LazySingleton`, not per-screen — B2 (Explore) is the only screen
/// that reads this today, but the same discipline CLAUDE.md rule 10
/// applies elsewhere (share the one connection, don't let a screen open
/// its own) still holds even for a single-consumer repository.
@LazySingleton(as: SearchHistoryRepository)
class DriftSearchHistoryRepository implements SearchHistoryRepository {
  DriftSearchHistoryRepository(this._db);

  final AppDatabase _db;

  /// B2: "last 10".
  static const int _limit = 10;

  /// The last timestamp this repository handed out — see
  /// [_nextTimestamp].
  DateTime? _lastTimestamp;

  /// A timestamp guaranteed later than every one this instance has
  /// already recorded, even when [DateTime.now] itself can't tell two
  /// rapid-fire calls apart. That matters here specifically: SQLite's
  /// datetime columns round-trip at *second* precision (verified
  /// directly — drift's default storage truncates anything finer),
  /// and `insertOnConflictUpdate` re-recording an *existing* query is a
  /// plain `UPDATE` — it never touches SQLite's own rowid — so neither
  /// sub-second precision nor rowid order is available as a tiebreaker
  /// for "which of these was searched most recently". [now] is
  /// truncated to whole seconds *before* comparing, matching exactly
  /// what will actually survive that round trip — comparing untruncated
  /// values here would keep finding "a later instant" microseconds
  /// apart that collapses to the identical stored second anyway.
  DateTime _nextTimestamp() {
    final now = DateTime.now();
    final truncated = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second,
    );
    final next = _lastTimestamp != null && !truncated.isAfter(_lastTimestamp!)
        ? _lastTimestamp!.add(const Duration(seconds: 1))
        : truncated;
    _lastTimestamp = next;
    return next;
  }

  @override
  Stream<List<String>> watch() {
    final query = _db.select(_db.searchHistoryTable)
      ..orderBy([(row) => OrderingTerm.desc(row.searchedAt)])
      ..limit(_limit);
    return query.watch().map((rows) => rows.map((row) => row.query).toList());
  }

  @override
  Future<Result<void>> record(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const Success(null);

    try {
      // `query` is the primary key, so re-recording an existing entry
      // updates its `searchedAt` in place rather than duplicating it —
      // exactly the "moves to the front" behavior B2 wants.
      await _db
          .into(_db.searchHistoryTable)
          .insertOnConflictUpdate(
            SearchHistoryTableCompanion.insert(
              query: trimmed,
              searchedAt: _nextTimestamp(),
            ),
          );
      await _trimToLimit();
      return const Success(null);
    } catch (e) {
      return Failure('Could not record search "$trimmed": $e');
    }
  }

  @override
  Future<Result<void>> remove(String query) async {
    try {
      await (_db.delete(
        _db.searchHistoryTable,
      )..where((row) => row.query.equals(query))).go();
      return const Success(null);
    } catch (e) {
      return Failure('Could not remove "$query": $e');
    }
  }

  @override
  Future<Result<void>> clear() async {
    try {
      await _db.delete(_db.searchHistoryTable).go();
      return const Success(null);
    } catch (e) {
      return Failure('Could not clear search history: $e');
    }
  }

  /// Keeps only the [_limit] most recent rows — called after every
  /// [record] so the table itself never grows past what B2 ever shows,
  /// rather than relying on every reader to remember to `..limit(10)`.
  Future<void> _trimToLimit() async {
    final all = await (_db.select(
      _db.searchHistoryTable,
    )..orderBy([(row) => OrderingTerm.desc(row.searchedAt)])).get();
    if (all.length <= _limit) return;

    final stale = all.skip(_limit).map((row) => row.query).toList();
    await (_db.delete(
      _db.searchHistoryTable,
    )..where((row) => row.query.isIn(stale))).go();
  }
}
