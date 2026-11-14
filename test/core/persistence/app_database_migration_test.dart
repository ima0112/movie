import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/persistence/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

/// What the later migration steps need of an older database: the tables whose
/// columns they add (their other columns don't matter here).
void _addLibraryTable(sqlite3.Database raw) {
  raw.execute(
    'CREATE TABLE user_media_entries ('
    'media_type TEXT NOT NULL, tmdb_id INTEGER NOT NULL, '
    'PRIMARY KEY (media_type, tmdb_id));',
  );
  _addTasteTable(raw);
}

void _addTasteTable(sqlite3.Database raw) => raw.execute(
  'CREATE TABLE taste_profile_table (id INTEGER NOT NULL DEFAULT 0, '
  'PRIMARY KEY (id));',
);

void main() {
  group('AppDatabase migration', () {
    test(
      'upgrading from schema v5 (before SettingsTable existed) creates '
      'SettingsTable and leaves the already-present onboarding data alone',
      () async {
        // A raw sqlite3 database hand-built to look like this app's own
        // schema v5 (OnboardingTable, with a completed=true row already
        // in it) — the "device that updates from an older version of
        // the app" case this migration step must not disturb.
        final raw = sqlite3.sqlite3.openInMemory();
        raw.execute('''
          CREATE TABLE onboarding_table (
            id INTEGER NOT NULL DEFAULT 0,
            completed INTEGER NOT NULL DEFAULT 0,
            PRIMARY KEY (id)
          );
        ''');
        raw.execute(
          'INSERT INTO onboarding_table (id, completed) VALUES (0, 1);',
        );
        _addLibraryTable(raw);
        raw.execute('PRAGMA user_version = 5;');

        final db = AppDatabase.forTesting(NativeDatabase.opened(raw));
        addTearDown(db.close);

        final onboardingRow = await db.select(db.onboardingTable).getSingle();
        expect(onboardingRow.completed, isTrue);

        final settingsRows = await db.select(db.settingsTable).get();
        expect(settingsRows, isEmpty);
      },
    );

    test('upgrading from schema v6 (before RecentlyViewedTable existed) '
        'creates it, empty, and keeps the existing settings row', () async {
      final raw = sqlite3.sqlite3.openInMemory();
      raw.execute('''
        CREATE TABLE settings_table (
          id INTEGER NOT NULL DEFAULT 0,
          language_code TEXT NOT NULL,
          region_code TEXT NOT NULL,
          PRIMARY KEY (id)
        );
      ''');
      raw.execute(
        "INSERT INTO settings_table (id, language_code, region_code) "
        "VALUES (0, 'es', 'ES');",
      );
      _addLibraryTable(raw);
      raw.execute('PRAGMA user_version = 6;');

      final db = AppDatabase.forTesting(NativeDatabase.opened(raw));
      addTearDown(db.close);

      expect(await db.select(db.recentlyViewedTable).get(), isEmpty);
      final settings = await db.select(db.settingsTable).getSingle();
      expect(settings.regionCode, 'ES');
    });

    test('upgrading from schema v8 (before the favorite/watch-later dates) '
        'adds them as empty columns and keeps the saved entry', () async {
      final raw = sqlite3.sqlite3.openInMemory();
      raw.execute(
        'CREATE TABLE user_media_entries ('
        'media_type TEXT NOT NULL, tmdb_id INTEGER NOT NULL, '
        'title TEXT, is_favorite INTEGER NOT NULL DEFAULT 0, '
        'is_watch_later INTEGER NOT NULL DEFAULT 0, '
        'updated_at INTEGER NOT NULL, '
        'PRIMARY KEY (media_type, tmdb_id));',
      );
      raw.execute(
        "INSERT INTO user_media_entries (media_type, tmdb_id, title, "
        "is_favorite, updated_at) VALUES ('movie', 1, 'Dune', 1, 0);",
      );
      _addTasteTable(raw);
      raw.execute('PRAGMA user_version = 8;');

      final db = AppDatabase.forTesting(NativeDatabase.opened(raw));
      addTearDown(db.close);

      final row = await db.select(db.userMediaEntries).getSingle();
      expect(row.title, 'Dune');
      expect(row.isFavorite, isTrue);
      expect(row.favoritedAt, isNull);
      expect(row.watchLaterAt, isNull);
    });
  });
}
