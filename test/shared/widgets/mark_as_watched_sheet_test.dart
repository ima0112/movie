import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/core/domain/entities/watch_providers.dart';
import 'package:movies/shared/widgets/mark_as_watched_sheet.dart';

const _dune = MediaKey(type: MediaType.movie, tmdbId: 1);
const _theBear = MediaKey(type: MediaType.tvShow, tmdbId: 2);

Movie _movie(int id) => Movie(
  id: id,
  title: 'Title',
  posterUrl: null,
  genres: const [],
  releaseDate: DateTime(2024, 1, 1),
  voteAverage: 8,
);

MovieDetail _movieDetail({int? runtimeMinutes}) => MovieDetail(
  item: _movie(1),
  overview: '',
  cast: const [],
  crew: const [],
  videos: const [],
  similar: const [],
  imdbId: null,
  tagline: null,
  status: 'Released',
  watchProviders: WatchProviders.empty,
  runtimeMinutes: runtimeMinutes,
  releaseDate: DateTime(2024, 1, 1),
  certification: null,
);

TvShowDetail _tvShowDetail({
  int numberOfEpisodes = 10,
  int? episodeRuntimeMinutes,
}) => TvShowDetail(
  item: _movie(2),
  overview: '',
  cast: const [],
  crew: const [],
  videos: const [],
  similar: const [],
  imdbId: null,
  tagline: null,
  status: 'Ended',
  watchProviders: WatchProviders.empty,
  creators: const [],
  seasons: const [],
  numberOfEpisodes: numberOfEpisodes,
  episodeRuntimeMinutes: episodeRuntimeMinutes,
  firstAirDate: null,
  lastAirDate: null,
  inProduction: false,
  certification: null,
);

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

    testWidgets('Save with a MovieDetail on hand populates runtimeMinutes', (
      tester,
    ) async {
      final repository = InMemoryUserLibraryRepository();
      await tester.pumpWidget(
        MaterialApp(
          home: MarkAsWatchedSheet(
            mediaKey: _dune,
            userLibraryRepository: repository,
            mediaDetail: _movieDetail(runtimeMinutes: 166),
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final saved = await repository.watchEntry(_dune).first;
      expect(saved!.runtimeMinutes, 166);
      expect(saved.episodeCount, isNull);
      expect(saved.episodeRuntimeMinutes, isNull);
    });

    testWidgets('Save with a TvShowDetail on hand populates episodeCount and '
        'episodeRuntimeMinutes', (tester) async {
      final repository = InMemoryUserLibraryRepository();
      await tester.pumpWidget(
        MaterialApp(
          home: MarkAsWatchedSheet(
            mediaKey: _theBear,
            userLibraryRepository: repository,
            mediaDetail: _tvShowDetail(
              numberOfEpisodes: 62,
              episodeRuntimeMinutes: 24,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final saved = await repository.watchEntry(_theBear).first;
      expect(saved!.runtimeMinutes, isNull);
      expect(saved.episodeCount, 62);
      expect(saved.episodeRuntimeMinutes, 24);
    });

    testWidgets(
      'Save without a mediaDetail preserves the existing entry\'s duration '
      'fields instead of blanking them',
      (tester) async {
        final repository = InMemoryUserLibraryRepository();
        await tester.pumpWidget(
          MaterialApp(
            home: MarkAsWatchedSheet(
              mediaKey: _dune,
              userLibraryRepository: repository,
              existingEntry: UserMediaEntry(
                key: _dune,
                watchedAt: DateTime(2024, 1, 1),
                rating: 3,
                runtimeMinutes: 166,
              ),
              // Re-editing the rating/date without a MediaDetail on hand
              // (e.g. some future call site that doesn't have one).
            ),
          ),
        );

        // The 5th star.
        await tester.tap(find.byType(GestureDetector).at(4));
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        final saved = await repository.watchEntry(_dune).first;
        expect(saved!.rating, 5);
        expect(saved.runtimeMinutes, 166);
      },
    );
  });
}
