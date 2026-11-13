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
/// it's in My List: poster, title, year, genres"). Three of these
/// columns (backdropPath, voteCount, popularity) go beyond what
/// `MediaItem` exposes today and stay unused — extending
/// `MediaItem`/`Movie`/`TvShow` to carry them is a separate, larger
/// change (see each column's own doc comment below).
@DataClassName('UserMediaEntryRow')
class UserMediaEntries extends Table {
  /// `MediaKey.type` — stored as text (the enum's name) rather than an
  /// int index, so the raw database stays human-readable and isn't
  /// silently invalidated by reordering `MediaType`'s values.
  TextColumn get mediaType => textEnum<MediaType>()();

  /// `MediaKey.tmdbId`.
  IntColumn get tmdbId => integer()();

  // --- Catalog snapshot: enough to render a MediaItem-shaped card
  // without a network call. All nullable. `title`/`genres`/`posterPath`/
  // `voteAverage`/`year` are mapped both ways by
  // `DriftUserLibraryRepository` (`UserMediaEntry`'s own fields of the
  // same name/purpose — `posterUrl` on the domain side, see below).
  // `backdropPath`/`voteCount`/`popularity` remain unmapped: `MediaItem`/
  // `MediaDetail` carry none of these three at all today, and adding
  // them would mean extending that entity (every TMDB mapper, every
  // carousel/hero call site, every test fixture) — out of scope for the
  // my-list-sort-fix branch that mapped the rest of this block. Tracked
  // in docs/TODO_AUDIT.md ("limpieza posterior: columnas muertas").
  TextColumn get title => text().nullable()();

  /// Named `posterPath` for the SQL column's own history, but holds
  /// `UserMediaEntry.posterUrl` — a fully resolved image URL (TMDB host
  /// + a size token already baked in by the mapper), not a raw TMDB
  /// path fragment. `MediaItem` never carries the raw path past the
  /// data layer's own DTO, so there is nothing shorter to store here.
  TextColumn get posterPath => text().nullable()();
  TextColumn get backdropPath => text().nullable()();

  /// `UserMediaEntry.genres`, serialized as comma-joined ids (same
  /// format as `TasteProfileTable.likedGenres`) — never a display name
  /// (CLAUDE.md rule 15); `GenreCatalog.byId` rebuilds each `Genre`.
  TextColumn get genres => text().nullable()();

  /// `UserMediaEntry.voteAverage`.
  RealColumn get voteAverage => real().nullable()();
  IntColumn get voteCount => integer().nullable()();
  RealColumn get popularity => real().nullable()();

  /// `UserMediaEntry.year` — release/first-air year, kept separate from
  /// a full release date since a year is all the offline snapshot ever
  /// needs to show (`docs/SCREENS.md` D1).
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

  /// `TasteProfile.likedGenres`, serialized as comma-joined ids (e.g.
  /// `"action,drama"`) — never a display name (CLAUDE.md rule 15);
  /// `GenreCatalog.byId` rebuilds each `Genre`.
  TextColumn get likedGenres => text()();

  /// Same id-only serialization as [likedGenres].
  TextColumn get vetoedGenres => text()();

  /// `TasteProfile.likedVibes`, comma-joined — [Vibe] ids from
  /// `assets/vibes.json` (never a display name, CLAUDE.md rule 15), and
  /// none of them contain a comma.
  TextColumn get likedVibes => text()();
  IntColumn get yearFrom => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Whether A2 (Onboarding) has ever been completed on this device — one
/// row, same single-row convention as [UserProfileTable]. See
/// `core/domain/repositories/onboarding_repository.dart`'s own doc
/// comment for why this is its own flag rather than derived from
/// [UserProfileTable] having a row.
@DataClassName('OnboardingRow')
class OnboardingTable extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// The user's own TMDB content preferences (F11) — one row, same
/// single-row convention as [UserProfileTable]. See
/// `core/domain/repositories/settings_repository.dart`'s own doc
/// comment for why [languageCode]/[regionCode] always have a value
/// (never nullable): row `id = 0` is only ever absent before this
/// device's very first `SettingsRepository.load` call, which persists
/// a system-locale-derived default immediately rather than leaving it
/// unset.
@DataClassName('SettingsRow')
class SettingsTable extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  TextColumn get languageCode => text()();
  TextColumn get regionCode => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// B2's "Recent" search chips (`docs/SCREENS.md` B2: "'Recent' as chips
/// (last 10; tap to run, long-press to remove; 'Clear all')"). `query`
/// itself is the primary key: re-searching an already-present query
/// just bumps its [searchedAt] in place (`DriftSearchHistoryRepository`
/// upserts), which is what keeps "most recent" ordering correct without
/// ever storing a duplicate row.
///
/// Registered here (like every other table) so it shares the app's one
/// `AppDatabase` connection, even though the repository interface and
/// its drift-backed implementation are feature-private — see
/// `features/search/domain/search_history_repository.dart`'s own doc
/// comment for why.
@DataClassName('SearchHistoryEntryRow')
class SearchHistoryTable extends Table {
  TextColumn get query => text()();
  DateTimeColumn get searchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {query};
}

/// Home's "Recently viewed" (`docs/SCREENS.md` B1, All tab): the last titles
/// whose detail was opened, with the small snapshot the section draws without
/// a network call. One row per `(mediaType, tmdbId)` — re-opening a title
/// updates [viewedAtMicros] in place — and the repository keeps the table to
/// its 10 newest rows.
@DataClassName('RecentlyViewedRow')
class RecentlyViewedTable extends Table {
  /// `MediaKey.type`, stored as the enum's name (like `UserMediaEntries`).
  TextColumn get mediaType => textEnum<MediaType>()();

  /// `MediaKey.tmdbId`.
  IntColumn get tmdbId => integer()();

  TextColumn get title => text()();

  /// The fully resolved poster URL (as in `UserMediaEntries.posterPath`).
  TextColumn get posterUrl => text().nullable()();

  RealColumn get voteAverage => real()();

  DateTimeColumn get releaseDate => dateTime().nullable()();

  /// When the detail was opened, in microseconds since the epoch. An integer
  /// rather than a `DateTimeColumn`: SQLite's datetime storage rounds to
  /// whole seconds, and two titles opened within a second must still order
  /// correctly.
  IntColumn get viewedAtMicros => integer()();

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
@DriftDatabase(
  tables: [
    UserMediaEntries,
    UserProfileTable,
    TasteProfileTable,
    SearchHistoryTable,
    OnboardingTable,
    SettingsTable,
    RecentlyViewedTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Testing-only: pass a `NativeDatabase.memory()` (or any other
  /// in-memory `QueryExecutor`) so tests never touch a real file on disk
  /// or need `path_provider`'s platform channel — see
  /// `drift_user_library_repository_test.dart`.
  AppDatabase.forTesting(super.executor);

  /// Bump this whenever a table changes shape. Went to 2 when
  /// [UserProfileTable] and [TasteProfileTable] were added, to 3 when
  /// [UserMediaEntries] grew its `runtimeMinutes`/`episodeCount`/
  /// `episodeRuntimeMinutes` columns, to 4 when [SearchHistoryTable]
  /// was added, to 5 when [OnboardingTable] was, and to 6 when
  /// [SettingsTable] was, and to 7 when [RecentlyViewedTable] was — [onUpgrade] below adds each version's own
  /// change in order, never a destructive drop/recreate, so nobody's
  /// existing My List/profile/tastes/search/onboarding data is lost on
  /// update.
  @override
  int get schemaVersion => 7;

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
      if (from < 4) {
        await m.createTable(searchHistoryTable);
      }
      if (from < 5) {
        await m.createTable(onboardingTable);
      }
      if (from < 6) {
        await m.createTable(settingsTable);
      }
      if (from < 7) {
        await m.createTable(recentlyViewedTable);
      }
    },
  );
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'pako_tv');
}
