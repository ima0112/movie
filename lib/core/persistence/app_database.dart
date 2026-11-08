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

  // --- Duration snapshot, added in schema v3
  // (core/domain/entities/user_media_entry.dart's own fields of the same
  // name) — populated once, at the moment H2's "Save" upserts a watched
  // entry, from whatever `MediaDetail` the detail screen already has
  // loaded. Nullable with no default: an entry watched before this
  // schema version, or an unwatched Favorites/Watch later entry, simply
  // has these as SQL NULL — never a fabricated 0 that could be summed
  // silently. ---
  IntColumn get runtimeMinutes => integer().nullable()();
  IntColumn get episodeCount => integer().nullable()();
  IntColumn get episodeRuntimeMinutes => integer().nullable()();

  /// When this row last changed. Lets a future sync step know what to
  /// push without re-sending every row.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {mediaType, tmdbId};
}

/// The local user's own profile (`docs/DECISIONS.md` section 7) — a
/// single row, never a list. [id] always stores `0`;
/// `DriftUserProfileRepository` never writes or queries any other value,
/// so there is never more than one row (drift has no direct "singleton
/// table" construct to enforce this at the schema level).
@DataClassName('UserProfileRow')
class UserProfileTable extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  TextColumn get displayName => text()();

  /// See `UserProfile.initialColor` — a 32-bit ARGB int, not a color
  /// name or hex string.
  IntColumn get initialColor => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The local user's taste profile (C5 "My Tastes") — same single-row
/// convention as [UserProfileTable].
@DataClassName('TasteProfileRow')
class TasteProfileTable extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();

  /// `TasteProfile.likedGenres`, serialized as `id:name` pairs joined by
  /// commas (e.g. `"action:Action,drama:Drama"`) — a genre's `id` alone
  /// isn't enough to rebuild a `Genre` without a lookup table, and there
  /// isn't a normalized genre catalog in `core/domain` yet to look it up
  /// against, so both fields are stored directly.
  TextColumn get likedGenres => text()();

  /// Same `id:name` serialization as [likedGenres].
  TextColumn get vetoedGenres => text()();

  /// `TasteProfile.likedVibes`, comma-joined — vibe names come from
  /// `assets/vibes.json` and never contain a comma.
  TextColumn get likedVibes => text()();
  IntColumn get yearFrom => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
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
@DriftDatabase(tables: [UserMediaEntries, UserProfileTable, TasteProfileTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Testing-only: pass a `NativeDatabase.memory()` (or any other
  /// in-memory `QueryExecutor`) so tests never touch a real file on disk
  /// or need `path_provider`'s platform channel — see
  /// `drift_user_library_repository_test.dart`.
  AppDatabase.forTesting(super.executor);

  /// Bump this whenever a table changes shape. Went to 2 when
  /// [UserProfileTable] and [TasteProfileTable] were added, and to 3 when
  /// [UserMediaEntries] grew its `runtimeMinutes`/`episodeCount`/
  /// `episodeRuntimeMinutes` columns — [onUpgrade] below adds each
  /// version's own change in order, never a destructive drop/recreate,
  /// so nobody's existing My List/profile/tastes data is lost on update.
  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(userProfileTable);
        await m.createTable(tasteProfileTable);
      }
      if (from < 3) {
        await m.addColumn(userMediaEntries, userMediaEntries.runtimeMinutes);
        await m.addColumn(userMediaEntries, userMediaEntries.episodeCount);
        await m.addColumn(
          userMediaEntries,
          userMediaEntries.episodeRuntimeMinutes,
        );
      }
    },
  );
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'pako_tv');
}
