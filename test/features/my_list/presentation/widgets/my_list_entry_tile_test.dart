import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/features/my_list/presentation/widgets/my_list_entry_tile.dart';
import 'package:movies/l10n/app_localizations.dart';

const _dune = MediaKey(type: MediaType.movie, tmdbId: 1);
const _bear = MediaKey(type: MediaType.tvShow, tmdbId: 101);

Future<void> _pump(
  WidgetTester tester,
  UserMediaEntry entry, {
  LibraryTab tab = LibraryTab.favorites,
}) {
  return tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: MyListEntryTile(
          entry: entry,
          tab: tab,
          userLibraryRepository: InMemoryUserLibraryRepository(),
        ),
      ),
    ),
  );
}

void main() {
  group('MyListEntryTile', () {
    testWidgets('renders title, year, and type with no network call — a single '
        'pump is enough, no FutureBuilder waiting on a fetch', (tester) async {
      await _pump(
        tester,
        const UserMediaEntry(
          key: _dune,
          title: 'Dune: Part Two',
          isFavorite: true,
          year: 2024,
        ),
      );

      // No `pumpAndSettle`/extra pump needed — if this still depended
      // on a Future, the row would render empty/placeholder on this
      // single frame.
      expect(find.text('Dune: Part Two'), findsOneWidget);
      expect(find.textContaining('2024'), findsOneWidget);
    });

    testWidgets('shows runtime for a movie once it has one, omits it '
        'when the entry has none yet', (tester) async {
      await _pump(
        tester,
        const UserMediaEntry(
          key: _dune,
          title: 'Dune: Part Two',
          isFavorite: true,
          year: 2024,
          runtimeMinutes: 166,
        ),
      );
      expect(find.textContaining('2 h 46 min'), findsOneWidget);

      await _pump(
        tester,
        const UserMediaEntry(
          key: _dune,
          title: 'Dune: Part Two',
          isFavorite: true,
          year: 2024,
        ),
      );
      expect(find.textContaining('min'), findsNothing);
    });

    testWidgets('shows episode count for a TV show once it has one', (
      tester,
    ) async {
      await _pump(
        tester,
        const UserMediaEntry(
          key: _bear,
          title: 'The Bear',
          isFavorite: true,
          year: 2022,
          episodeCount: 28,
        ),
      );

      expect(find.textContaining('28 episodes'), findsOneWidget);
    });

    testWidgets('a null posterUrl shows the placeholder, not a broken '
        'image or an extra request', (tester) async {
      await _pump(
        tester,
        const UserMediaEntry(key: _dune, title: 'Dune: Part Two'),
      );

      expect(find.byType(Image), findsNothing);
    });

    testWidgets('falls back to a generic title when the entry has none '
        '(an entry saved before title existed)', (tester) async {
      await _pump(tester, const UserMediaEntry(key: _dune, title: ''));

      expect(find.textContaining('#1'), findsOneWidget);
    });
  });
}
