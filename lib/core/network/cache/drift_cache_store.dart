import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:drift/drift.dart';

import '../../persistence/app_database.dart';

/// The response cache's disk half: saved TMDB answers in the app's SQLite
/// database (`ApiResponseCacheTable`), so lists and details open with no
/// network (`docs/DECISIONS.md` "Caching", Phase 3).
///
/// Bounded twice — [maxBytes] of bodies and [maxEntries] rows — by dropping the
/// least recently used first, and by age: [purgeOlderThan] runs at startup.
/// A single answer over [maxEntryBytes] is not stored at all.
class DriftCacheStore extends CacheStore {
  DriftCacheStore(
    this._db, {
    this.maxBytes = defaultMaxBytes,
    this.maxEntries = defaultMaxEntries,
    this.maxEntryBytes = defaultMaxEntryBytes,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  static const int defaultMaxBytes = 30 * 1024 * 1024;
  static const int defaultMaxEntries = 150;
  static const int defaultMaxEntryBytes = 1024 * 1024;

  final AppDatabase _db;
  final int maxBytes;
  final int maxEntries;
  final int maxEntryBytes;
  final DateTime Function() _now;

  $ApiResponseCacheTableTable get _t => _db.apiResponseCacheTable;

  @override
  Future<bool> exists(String key) async {
    final row =
        await (_db.selectOnly(_t)
              ..addColumns([_t.key])
              ..where(_t.key.equals(key)))
            .getSingleOrNull();
    return row != null;
  }

  @override
  Future<CacheResponse?> get(String key) async {
    final row = await (_db.select(
      _t,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    if (row == null) return null;
    // Reading it makes it recently used.
    await (_db.update(_t)..where((t) => t.key.equals(key))).write(
      ApiResponseCacheTableCompanion(lastAccessedAt: Value(_now())),
    );
    return _toResponse(row);
  }

  @override
  Future<List<CacheResponse>> getFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    final rows = await _db.select(_t).get();
    return [
      for (final row in rows)
        if (pathExists(row.url, pathPattern, queryParams: queryParams))
          _toResponse(row),
    ];
  }

  @override
  Future<void> set(CacheResponse response) async {
    final size = response.content?.length ?? 0;
    if (size > maxEntryBytes) return;
    await _db
        .into(_t)
        .insertOnConflictUpdate(
          ApiResponseCacheTableCompanion.insert(
            key: response.key,
            url: response.url,
            statusCode: response.statusCode,
            content: Value(
              response.content == null
                  ? null
                  : Uint8List.fromList(response.content!),
            ),
            headers: Value(
              response.headers == null
                  ? null
                  : Uint8List.fromList(response.headers!),
            ),
            cacheControl: Value(response.cacheControl.toHeader()),
            eTag: Value(response.eTag),
            lastModified: Value(response.lastModified),
            date: Value(response.date),
            expires: Value(response.expires),
            maxStale: Value(response.maxStale),
            priority: Value(response.priority.index),
            requestDate: response.requestDate,
            responseDate: response.responseDate,
            lastAccessedAt: _now(),
            sizeBytes: size,
          ),
        );
    await _trim();
  }

  @override
  Future<void> delete(String key, {bool staleOnly = false}) async {
    if (staleOnly) {
      final saved = await get(key);
      if (saved == null || !saved.isStaled()) return;
    }
    await (_db.delete(_t)..where((t) => t.key.equals(key))).go();
  }

  @override
  Future<void> deleteFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    final rows = await _db.select(_t).get();
    final keys = [
      for (final row in rows)
        if (pathExists(row.url, pathPattern, queryParams: queryParams)) row.key,
    ];
    if (keys.isEmpty) return;
    await (_db.delete(_t)..where((t) => t.key.isIn(keys))).go();
  }

  @override
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool staleOnly = false,
  }) async {
    final rows =
        await (_db.select(_t)..where(
              (t) => t.priority.isSmallerOrEqualValue(priorityOrBelow.index),
            ))
            .get();
    final keys = [
      for (final row in rows)
        if (!staleOnly || _toResponse(row).isStaled()) row.key,
    ];
    if (keys.isEmpty) return;
    await (_db.delete(_t)..where((t) => t.key.isIn(keys))).go();
  }

  @override
  Future<void> close() async {}

  /// Drops what was received more than [age] ago — the offline horizon, run at
  /// startup so a long-unused app doesn't keep months-old answers.
  Future<void> purgeOlderThan(Duration age) async {
    final cutoff = _now().subtract(age);
    await (_db.delete(
      _t,
    )..where((t) => t.responseDate.isSmallerThanValue(cutoff))).go();
  }

  /// The least recently used rows go until the table fits both caps.
  Future<void> _trim() async {
    final rows =
        await (_db.selectOnly(_t)
              ..addColumns([_t.key, _t.sizeBytes])
              ..orderBy([OrderingTerm.asc(_t.lastAccessedAt)]))
            .map((r) => (key: r.read(_t.key)!, size: r.read(_t.sizeBytes)!))
            .get();
    var count = rows.length;
    var bytes = rows.fold<int>(0, (sum, r) => sum + r.size);
    final drop = <String>[];
    for (final row in rows) {
      if (count <= maxEntries && bytes <= maxBytes) break;
      drop.add(row.key);
      count--;
      bytes -= row.size;
    }
    if (drop.isNotEmpty) {
      await (_db.delete(_t)..where((t) => t.key.isIn(drop))).go();
    }
  }

  static CacheResponse _toResponse(ApiResponseCacheRow row) => CacheResponse(
    cacheControl: CacheControl.fromString(row.cacheControl),
    content: row.content,
    date: row.date,
    eTag: row.eTag,
    expires: row.expires,
    headers: row.headers,
    key: row.key,
    lastModified: row.lastModified,
    maxStale: row.maxStale,
    priority: CachePriority.values[row.priority],
    requestDate: row.requestDate,
    responseDate: row.responseDate,
    url: row.url,
    statusCode: row.statusCode,
  );
}
