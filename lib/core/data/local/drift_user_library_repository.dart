import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/genre.dart';
import '../../domain/entities/media_key.dart';
import '../../domain/entities/media_type.dart';
import '../../domain/entities/result.dart';
import '../../domain/entities/user_media_entry.dart';
import '../../domain/repositories/user_library_repository.dart';
import '../../persistence/app_database.dart';

/// Persistent implementation of [UserLibraryRepository] — SQLite (drift)
/// via [AppDatabase]. This is the app's real "My List" storage;
/// `InMemoryUserLibraryRepository` (`in_memory_user_library_repository.dart`)
/// is no longer the one annotated `@LazySingleton(as: UserLibraryRepository)`
/// — only one implementation may be, or injectable's codegen fails on the
/// ambiguity — but it's kept as a fast, dependency-free test double.
///
/// `@LazySingleton`, not per-screen, for the same reason
/// `InMemoryUserLibraryRepository` was: every screen that reads My List
/// (the list itself, a detail screen's action row, Stats...) must share
/// the same connection — see CLAUDE.md rule 10.
@LazySingleton(as: UserLibraryRepository)
class DriftUserLibraryRepository implements UserLibraryRepository {
  DriftUserLibraryRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<UserMediaEntry>> watch({LibraryTab? tab, MediaType? type}) {
    final query = _db.select(_db.userMediaEntries);
    if (type != null) {
      query.where((row) => row.mediaType.equalsValue(type));
    }
    switch (tab) {
      case LibraryTab.favorites:
        query.where((row) => row.isFavorite.equals(true));
      case LibraryTab.watchLater:
        query.where((row) => row.isWatchLater.equals(true));
      case LibraryTab.watched:
        query.where((row) => row.watchedAt.isNotNull());
      case null:
        break;
    }
    return query.watch().map((rows) => rows.map(_toEntry).toList());
  }

  @override
  Stream<UserMediaEntry?> watchEntry(MediaKey key) {
    final query = _db.select(_db.userMediaEntries)
      ..where((row) => _matchesKey(row, key));
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _toEntry(row),
    );
  }

  @override
  Future<Result<void>> upsert(UserMediaEntry entry) async {
    try {
      await _db
          .into(_db.userMediaEntries)
          .insertOnConflictUpdate(
            UserMediaEntriesCompanion.insert(
              mediaType: entry.key.type,
              tmdbId: entry.key.tmdbId,
              title: Value(entry.title),
              isFavorite: Value(entry.isFavorite),
              isWatchLater: Value(entry.isWatchLater),
              watchedAt: Value(entry.watchedAt),
              rating: Value(entry.rating),
              runtimeMinutes: Value(entry.runtimeMinutes),
              episodeCount: Value(entry.episodeCount),
              episodeRuntimeMinutes: Value(entry.episodeRuntimeMinutes),
              genres: Value(_serializeGenres(entry.genres)),
              updatedAt: DateTime.now(),
            ),
          );
      return const Success(null);
    } catch (e) {
      return Failure('Could not save $entry: $e');
    }
  }

  @override
  Future<Result<void>> remove(MediaKey key) async {
    try {
      await (_db.delete(
        _db.userMediaEntries,
      )..where((row) => _matchesKey(row, key))).go();
      return const Success(null);
    } catch (e) {
      return Failure('Could not remove $key: $e');
    }
  }

  @override
  Future<Result<void>> clearAll() async {
    try {
      await _db.delete(_db.userMediaEntries).go();
      return const Success(null);
    } catch (e) {
      return Failure('Could not clear My List: $e');
    }
  }

  @override
  Future<Result<List<MediaKey>>> watchedKeys(
    MediaType type, {
    int limit = 500,
  }) async {
    try {
      final query = _db.select(_db.userMediaEntries)
        ..where(
          (row) => row.mediaType.equalsValue(type) & row.watchedAt.isNotNull(),
        )
        ..orderBy([(row) => OrderingTerm.desc(row.watchedAt)])
        ..limit(limit);
      final rows = await query.get();
      return Success(rows.map((row) => row.key).toList());
    } catch (e) {
      return Failure('Could not load watched keys: $e');
    }
  }

  @override
  Future<Result<List<UserMediaEntry>>> all() async {
    try {
      final rows = await _db.select(_db.userMediaEntries).get();
      return Success(rows.map(_toEntry).toList());
    } catch (e) {
      return Failure('Could not load entries: $e');
    }
  }

  static Expression<bool> _matchesKey(
    $UserMediaEntriesTable row,
    MediaKey key,
  ) {
    return row.mediaType.equalsValue(key.type) & row.tmdbId.equals(key.tmdbId);
  }

  static UserMediaEntry _toEntry(UserMediaEntryRow row) {
    return UserMediaEntry(
      key: row.key,
      // Defensive only — every upsert() call from this branch onward
      // always supplies a title; `null` only happens for a column that
      // was never written at all (this app hasn't shipped, so no real
      // row like that exists).
      title: row.title ?? '',
      isFavorite: row.isFavorite,
      isWatchLater: row.isWatchLater,
      watchedAt: row.watchedAt,
      rating: row.rating,
      runtimeMinutes: row.runtimeMinutes,
      episodeCount: row.episodeCount,
      episodeRuntimeMinutes: row.episodeRuntimeMinutes,
      genres: _deserializeGenres(row.genres),
    );
  }

  /// `id:name` pairs, comma-joined — same format and reasoning as
  /// `DriftTasteProfileRepository`'s own genre serialization: a genre's
  /// `id` alone isn't enough to rebuild a `Genre` without a lookup
  /// table, and there isn't a normalized genre catalog in `core/domain`
  /// yet to look it up against, so both fields are stored directly.
  static String _serializeGenres(List<Genre> genres) =>
      genres.map((g) => '${g.id}:${g.name}').join(',');

  static List<Genre> _deserializeGenres(String? serialized) {
    if (serialized == null || serialized.isEmpty) return const [];
    return serialized.split(',').map((pair) {
      final separator = pair.indexOf(':');
      return Genre(
        id: pair.substring(0, separator),
        name: pair.substring(separator + 1),
      );
    }).toList();
  }
}

extension on UserMediaEntryRow {
  MediaKey get key => MediaKey(type: mediaType, tmdbId: tmdbId);
}
