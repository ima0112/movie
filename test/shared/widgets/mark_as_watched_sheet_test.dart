import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/shared/widgets/mark_as_watched_sheet.dart';

const _dune = MediaKey(type: MediaType.movie, tmdbId: 1);

void main() {
  group('MarkAsWatchedSheet', () {
    testWidgets(
      'tapping Save with zero interaction saves a null rating and today '
      "as the date — H2's own fields are optional in practice",
      (tester) async {
        final repository = InMemoryUserLibraryRepository();
        await tester.pumpWidget(
          MaterialApp(
            home: MarkAsWatchedSheet(
              mediaKey: _dune,
              userLibraryRepository: repository,
            ),
          ),
        );

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        final saved = await repository.watchEntry(_dune).first;
        expect(saved!.rating, isNull);
        final now = DateTime.now();
        expect(saved.watchedAt!.year, now.year);
        expect(saved.watchedAt!.month, now.month);
        expect(saved.watchedAt!.day, now.day);
      },
    );

    testWidgets('picking a star rating before Save saves that rating', (
      tester,
    ) async {
      final repository = InMemoryUserLibraryRepository();
      await tester.pumpWidget(
        MaterialApp(
          home: MarkAsWatchedSheet(
            mediaKey: _dune,
            userLibraryRepository: repository,
          ),
        ),
      );

      // The 4th star icon, left to right.
      await tester.tap(find.byType(GestureDetector).at(3));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final saved = await repository.watchEntry(_dune).first;
      expect(saved!.rating, 4);
    });

    testWidgets(
      'shows "Remove from Watched" only when re-opened for an already-'
      'watched entry',
      (tester) async {
        final repository = InMemoryUserLibraryRepository();

        await tester.pumpWidget(
          MaterialApp(
            home: MarkAsWatchedSheet(
              mediaKey: _dune,
              userLibraryRepository: repository,
            ),
          ),
        );
        expect(find.text('Remove from Watched'), findsNothing);

        await tester.pumpWidget(
          MaterialApp(
            home: MarkAsWatchedSheet(
              mediaKey: _dune,
              userLibraryRepository: repository,
              existingEntry: UserMediaEntry(
                key: _dune,
                watchedAt: DateTime(2024, 1, 1),
                rating: 5,
              ),
            ),
          ),
        );
        expect(find.text('Remove from Watched'), findsOneWidget);
      },
    );
  });
}
