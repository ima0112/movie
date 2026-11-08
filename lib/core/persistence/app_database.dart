import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:injectable/injectable.dart';

import '../domain/entities/media_type.dart';

part 'app_database.g.dart';

/// Local snapshot of "My List" — favorites, watch later, and watched
/// (`docs/DECISIONS.md` section 4). One row per `(mediaType, tmdbId)`,
/// i.e. per `MediaKey` (`core/domain/entities/media_key.dart`) — the
/// composite primary key mirrors that entity's identity.
///
/// Beyond `UserMediaEntry`'s own flags, this table also stores a minimal
/// snapshot of the catalog item (title, poster, genres, rating...) so My
/// List, Stats, and an offline detail view can render without a network
/// round trip — see `docs/SCREENS.md` D1 ("offline with a snapshot if
/// it's in My List: poster, title, year, genres"). Some of these columns
/// (backdropPath, voteCount, popularity) go beyond what `MediaItem`
/// exposes today; the mapper that reads this table back into a domain
/// entity (a later branch) will need to either extend
/// `MediaItem`/`Movie`/`TvShow` or leave them unused for now.
@DataClassName('UserMediaEntryRow')
class UserMediaEntries extends Table {
  /// `MediaKey.type` — stored as text (the enum's name) rather than an
  /// int index, so the raw database stays human-readable and isn't
  /// silently invalidated by reordering `MediaType`'s values.
  TextColumn get mediaType => textEnum<MediaType>()();

  /// `MediaKey.tmdbId`.
  IntColumn get tmdbId => integer()();

  // --- Catalog snapshot: enough to render a MediaItem-shaped card
  // without a network call. All nullable: `UserLibraryRepository.upsert`
  // only ever receives a `UserMediaEntry` (just the flags below), which
  // carries none of this — a call site that also has the catalog item on
  // hand (e.g. the screen that just fetched it) is what would populate
  // these, once something writes them at all. Until then, a row can
  // exist with every snapshot column empty.
  TextColumn get title => text().nullable()();
  TextColumn get posterPath => text().nullable()();
  TextColumn get backdropPath => text().nullable()();

  /// Genre names, serialized (e.g. comma-joined) by whoever writes this
  /// row — drift/SQLite has no native array column, and this is a
  /// read-mostly snapshot, not something ever queried by individual
  /// genre.
  TextColumn get genres => text().nullable()();
  RealColumn get voteAverage => real().nullable()();
  IntColumn get voteCount => integer().nullable()();
  RealColumn get popularity => real().nullable()();

  /// Release/first-air year — kept separate from a full release date
  /// since a year is all the offline snapshot ever needs to show
  /// (`docs/SCREENS.md` D1).
  IntColumn get year => integer().nullable()();

  // --- UserMediaEntry's own fields
  // (core/domain/entities/user_media_entry.dart). ---
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isWatchLater => boolean().withDefault(const Constant(false))();
  DateTimeColumn get watchedAt => dateTime().nullable()();

  /// 1–5, only meaningful once [watchedAt] is set — see
  /// `UserMediaEntry.markWatched`.
  IntColumn get rating => integer().nullable()();

  /// When this row last changed. Lets a future sync step know what to
  /// push without re-sending every row.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {mediaType, tmdbId};
}

/// The app's single SQLite (drift) database.
///
/// Source of truth: `docs/STRUCTURE.md` (`core/persistence/
/// app_database.dart`) and `docs/DECISIONS.md` section 4.
///
/// `@LazySingleton` with no `as:` — there's no interface to register it
/// against, just the one connection every repository built on drift
/// (starting with `DriftUserLibraryRepository`) needs to share.
@LazySingleton()
@DriftDatabase(tables: [UserMediaEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Bump this whenever a table changes shape; drift's `onUpgrade`
  /// migration callback (added once there's a schema to migrate away
  /// from) keys off it. Starts at 1 — [UserMediaEntries] is this
  /// database's first table.
  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'pako_tv');
}
