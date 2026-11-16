import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/features/my_list/presentation/widgets/library_row_swipeable.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/library_row.dart';

/// Manual-verification step (swipe left → remove + Undo) made automatic
/// and repeatable, the same way `movie_detail_screen_test.dart` covers
/// what a live simulator session can't: no gesture-injection tool exists
/// for the simulator here, so `tester.drag`/`tester.tap` on the real
/// `Dismissible` + `SnackBar` is the rigorous equivalent.
void main() {
  const dune = MediaKey(type: MediaType.movie, tmdbId: 1);

  Future<void> pumpRow(
    WidgetTester tester,
    UserLibraryRepository repository, {
    UserMediaEntry? entry,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LibraryRowSwipeable(
            key: const ValueKey(dune),
            entry:
                entry ??
                const UserMediaEntry(
                  title: 'Test Title',
                  key: dune,
                  isFavorite: true,
                ),
            tab: LibraryTab.favorites,
            userLibraryRepository: repository,
            posterUrl: null,
            title: 'Dune: Part Two',
            metadata: '2024 · Movie · 2 h 46 min',
            trailing: const LibraryRowTrailing.chevron(),
          ),
        ),
      ),
    );
  }

  testWidgets('swiping left removes the entry and shows an Undo snackbar', (
    tester,
  ) async {
    final repository = InMemoryUserLibraryRepository();
    await repository.upsert(
      const UserMediaEntry(title: 'Test Title', key: dune, isFavorite: true),
    );
    await pumpRow(tester, repository);

    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(await repository.watchEntry(dune).first, isNull);
    expect(find.text('Removed from Favorites'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
  });

  testWidgets('tapping Undo restores the removed entry', (tester) async {
    final repository = InMemoryUserLibraryRepository();
    await repository.upsert(
      const UserMediaEntry(title: 'Test Title', key: dune, isFavorite: true),
    );
    // The row is built from what the repository holds, date included.
    final saved = await repository.watchEntry(dune).first;
    await pumpRow(tester, repository, entry: saved);

    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(await repository.watchEntry(dune).first, isNull);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    // Back as it was, with the date it joined Favorites.
    expect(await repository.watchEntry(dune).first, saved);
  });
}
