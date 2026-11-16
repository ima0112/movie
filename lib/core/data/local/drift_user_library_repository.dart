import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/genre.dart';
import '../../domain/entities/genre_catalog.dart';
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
  Future<Result<void>> upsert(UserMediaEntry given) async {
    try {
      final now = DateTime.now();
      final stored = await (_db.select(
        _db.userMediaEntries,
      )..where((row) => _matchesKey(row, given.key))).getSingleOrNull();
      final entry = given.withSaveDates(
        stored == null ? null : _toEntry(stored),
        now,
      );
      await _db
          .into(_db.userMediaEntries)
          .insertOnConflictUpdate(
            UserMediaEntriesCompanion.insert(
              mediaType: entry.key.type,
              tmdbId: entry.key.tmdbId,
              title: Value(entry.title),
              isFavorite: Value(entry.isFavorite),
              isWatchLater: Value(entry.isWatchLater),
              favoritedAt: Value(entry.favoritedAt),
              watchLaterAt: Value(entry.watchLaterAt),
              watchedAt: Value(entry.watchedAt),
              rating: Value(entry.rating),
              runtimeMinutes: Value(entry.runtimeMinutes),
              episodeCount: Value(entry.episodeCount),
              episodeRuntimeMinutes: Value(entry.episodeRuntimeMinutes),
              genres: Value(_serializeGenres(entry.genres)),
              posterPath: Value(entry.posterUrl),
              voteAverage: Value(entry.voteAverage),
              year: Value(entry.year),
              updatedAt: now,
            ),
          );
      return const Success(null);
    } catch (_) {
      return Failure(FailureReason.storage);
    }
  }

  @override
  Future<Result<void>> updateCatalogSnapshot(
    MediaKey key, {
    required String title,
    required List<Genre> genres,
    String? posterUrl,
    double? voteAverage,
    int? year,
    int? runtimeMinutes,
    int? episodeCount,
    int? episodeRuntimeMinutes,
  }) async {
    try {
      await (_db.update(
        _db.userMediaEntries,
      )..where((row) => _matchesKey(row, key))).write(
        UserMediaEntriesCompanion(
          title: Value(title),
          genres: Value(_serializeGenres(genres)),
          // `Value.absent()` — not `Value(null)` — for every optional
          // field below: "nothing fresher" must leave the stored column
          // untouched, never blank a value this same row already had.
          posterPath: posterUrl == null
              ? const Value.absent()
              : Value(posterUrl),
          voteAverage: voteAverage == null
              ? const Value.absent()
              : Value(voteAverage),
          year: year == null ? const Value.absent() : Value(year),
          runtimeMinutes: runtimeMinutes == null
              ? const Value.absent()
              : Value(runtimeMinutes),
          episodeCount: episodeCount == null
              ? const Value.absent()
              : Value(episodeCount),
          episodeRuntimeMinutes: episodeRuntimeMinutes == null
              ? const Value.absent()
              : Value(episodeRuntimeMinutes),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return const Success(null);
    } catch (_) {
      return Failure(FailureReason.storage);
    }
  }

  @override
  Future<Result<void>> remove(MediaKey key) async {
    try {
      await (_db.delete(
        _db.userMediaEntries,
      )..where((row) => _matchesKey(row, key))).go();
      return const Success(null);
    } catch (_) {
      return Failure(FailureReason.storage);
    }
  }

  @override
  Future<Result<void>> clearAll() async {
    try {
      await _db.delete(_db.userMediaEntries).go();
      return const Success(null);
    } catch (_) {
      return Failure(FailureReason.storage);
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
    } catch (_) {
      return Failure(FailureReason.storage);
    }
  }

  @override
  Future<Result<List<UserMediaEntry>>> all() async {
    try {
      final rows = await _db.select(_db.userMediaEntries).get();
      return Success(rows.map(_toEntry).toList());
    } catch (_) {
      return Failure(FailureReason.storage);
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
      favoritedAt: row.favoritedAt,
      watchLaterAt: row.watchLaterAt,
      watchedAt: row.watchedAt,
      rating: row.rating,
      runtimeMinutes: row.runtimeMinutes,
      episodeCount: row.episodeCount,
      episodeRuntimeMinutes: row.episodeRuntimeMinutes,
      genres: _deserializeGenres(row.genres),
      posterUrl: row.posterPath,
      voteAverage: row.voteAverage,
      year: row.year,
    );
  }

  /// Ids only, comma-joined — same format and reasoning as
  /// `DriftTasteProfileRepository`'s own genre serialization. A display
  /// name is never persisted (CLAUDE.md rule 15); [_deserializeGenres]
  /// looks each id back up in [GenreCatalog].
  static String _serializeGenres(List<Genre> genres) =>
      genres.map((g) => g.id).join(',');

  static List<Genre> _deserializeGenres(String? serialized) {
    if (serialized == null || serialized.isEmpty) return const [];
    return serialized
        .split(',')
        .map(GenreCatalog.byId)
        .whereType<Genre>()
        .toList();
  }
}

extension on UserMediaEntryRow {
  MediaKey get key => MediaKey(type: mediaType, tmdbId: tmdbId);
}
