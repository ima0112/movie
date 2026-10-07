import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/persistence/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

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
        raw.execute('PRAGMA user_version = 5;');

        final db = AppDatabase.forTesting(NativeDatabase.opened(raw));
        addTearDown(db.close);

        final onboardingRow = await db
            .select(db.onboardingTable)
            .getSingle();
        expect(onboardingRow.completed, isTrue);

        final settingsRows = await db.select(db.settingsTable).get();
        expect(settingsRows, isEmpty);
      },
    );
  });
}
