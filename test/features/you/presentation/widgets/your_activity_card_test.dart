import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/features/you/presentation/widgets/your_activity_card.dart';
import 'package:movies/l10n/app_localizations.dart';

const _dune = MediaKey(type: MediaType.movie, tmdbId: 1);
const _oppenheimer = MediaKey(type: MediaType.movie, tmdbId: 2);
const _theBear = MediaKey(type: MediaType.tvShow, tmdbId: 101);
const _oldMovie = MediaKey(type: MediaType.movie, tmdbId: 3);

Future<void> _pump(
  WidgetTester tester,
  InMemoryUserLibraryRepository repository,
) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: YourActivityCard(
          userLibraryRepository: repository,
          onSeeStats: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('YourActivityCard', () {
    testWidgets('sums a watched movie\'s runtimeMinutes into Hours', (
      tester,
    ) async {
      final repository = InMemoryUserLibraryRepository();
      await repository.upsert(
        UserMediaEntry(
          title: 'Test Title',
          key: _dune,
          watchedAt: DateTime(2024, 1, 1),
          runtimeMinutes: 166,
        ),
      );

      await _pump(tester, repository);

      // 166 min / 60 = 2.77h, rounds to 3.
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Hours'), findsOneWidget);
    });

    testWidgets(
      'sums a watched TV show\'s episodeCount * episodeRuntimeMinutes into '
      'Hours',
      (tester) async {
        final repository = InMemoryUserLibraryRepository();
        await repository.upsert(
          UserMediaEntry(
            title: 'Test Title',
            key: _theBear,
            watchedAt: DateTime(2024, 1, 1),
            episodeCount: 62,
            episodeRuntimeMinutes: 24,
          ),
        );

        await _pump(tester, repository);

        // 62 * 24 = 1488 min / 60 = 24.8h, rounds to 25.
        expect(find.text('25'), findsOneWidget);
      },
    );

    testWidgets('a watched entry with no duration fields (pre-migration data) '
        'contributes 0 to Hours instead of throwing', (tester) async {
      final repository = InMemoryUserLibraryRepository();
      await repository.upsert(
        UserMediaEntry(
          title: 'Test Title',
          key: _oldMovie,
          watchedAt: DateTime(2024, 1, 1),
        ),
      );

      await _pump(tester, repository);

      // No exception from null runtimeMinutes/episodeCount/
      // episodeRuntimeMinutes. Hours, Favorites, and Watch later all
      // separately show "0" too, so this checks Watched instead of
      // asserting that digit is unique on screen.
      expect(tester.takeException(), isNull);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets(
      'mixes movies, TV shows, and undated (no runtime) entries correctly, '
      'and ignores unwatched entries entirely',
      (tester) async {
        final repository = InMemoryUserLibraryRepository();
        await repository.upsert(
          UserMediaEntry(
            title: 'Test Title',
            key: _dune,
            watchedAt: DateTime(2024, 1, 1),
            runtimeMinutes: 120,
          ),
        );
        await repository.upsert(
          UserMediaEntry(
            title: 'Test Title',
            key: _theBear,
            watchedAt: DateTime(2024, 1, 1),
            episodeCount: 10,
            episodeRuntimeMinutes: 30,
          ),
        );
        await repository.upsert(
          UserMediaEntry(
            title: 'Test Title',
            key: _oldMovie,
            watchedAt: DateTime(2024, 1, 1),
          ),
        );
        // Only a favorite, never watched — must not count towards Hours
        // or Watched even though it has no duration fields either.
        await repository.upsert(
          const UserMediaEntry(
            title: 'Test Title',
            key: _oppenheimer,
            isFavorite: true,
          ),
        );

        await _pump(tester, repository);

        // (120 + 10*30 + 0) / 60 = 7h.
        expect(find.text('7'), findsOneWidget);
        expect(find.text('3'), findsOneWidget); // Watched.
        expect(find.text('1'), findsOneWidget); // Favorites.
      },
    );

    testWidgets('clearAll() on UserLibraryRepository zeroes an already-mounted '
        'card\'s numbers, with no restart', (tester) async {
      final repository = InMemoryUserLibraryRepository();
      await repository.upsert(
        UserMediaEntry(
          title: 'Test Title',
          key: _dune,
          watchedAt: DateTime(2024, 1, 1),
          runtimeMinutes: 166,
        ),
      );
      await _pump(tester, repository);
      expect(find.text('3'), findsOneWidget);

      await repository.clearAll();
      await tester.pumpAndSettle();

      expect(find.text('3'), findsNothing);
      expect(find.text('0'), findsWidgets);
    });
  });
}
