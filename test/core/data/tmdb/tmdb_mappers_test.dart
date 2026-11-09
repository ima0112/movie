import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/tmdb/dtos/tmdb_movie_list_item_dto.dart';
import 'package:movies/core/data/tmdb/dtos/tmdb_tv_list_item_dto.dart';
import 'package:movies/core/data/tmdb/tmdb_image_urls.dart';
import 'package:movies/core/data/tmdb/tmdb_mappers.dart';
import 'package:movies/core/domain/entities/media_item.dart';

Map<String, dynamic> _loadFixture(String name) =>
    jsonDecode(File('test/fixtures/$name').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  const imagesConfig = TmdbImagesConfig.fallback();

  group(
    'mediaItemFromMovieDto (test/fixtures/tmdb_movie_now_playing.json)',
    () {
      final results =
          (_loadFixture('tmdb_movie_now_playing.json')['results'] as List)
              .cast<Map<String, dynamic>>();
      final movies = results
          .map(TmdbMovieListItemDto.fromJson)
          .map((dto) => mediaItemFromMovieDto(dto, imagesConfig: imagesConfig))
          .toList();

      test('maps title, release date, vote average, and a resolved poster '
          'URL for a normal item', () {
        final trailOfEmbers = movies.firstWhere((m) => m.id == 101);

        expect(trailOfEmbers.title, 'Trail of Embers');
        expect(trailOfEmbers.releaseDate, DateTime(2026, 3, 20));
        expect(trailOfEmbers.voteAverage, 7.4);
        expect(
          trailOfEmbers.posterUrl,
          'https://image.tmdb.org/t/p/w342/trail-of-embers.jpg',
        );
        expect(trailOfEmbers, isA<Movie>());
      });

      test('maps every known genre id', () {
        final trailOfEmbers = movies.firstWhere((m) => m.id == 101);
        expect(
          trailOfEmbers.genres.map((g) => g.id),
          containsAll(['action', 'adventure']),
        );

        // id 103's genre_ids are [14 (Fantasy), 10751 (Family)] — both
        // map now (Fantasy has had a catalog equivalent since the
        // vibe-keywords-curated branch); see tmdb_genre_mapper_test.dart
        // for actual "unknown id gets dropped" coverage.
        final theLastLantern = movies.firstWhere((m) => m.id == 103);
        expect(theLastLantern.genres.map((g) => g.id), ['fantasy', 'family']);
      });

      test('an item with no poster_path -> posterUrl is null, not a broken '
          'URL', () {
        final withoutWaiting = movies.firstWhere((m) => m.id == 102);
        expect(withoutWaiting.posterUrl, isNull);
      });
    },
  );

  group('mediaItemFromTvDto (test/fixtures/tmdb_tv_popular.json)', () {
    final results = (_loadFixture('tmdb_tv_popular.json')['results'] as List)
        .cast<Map<String, dynamic>>();
    final shows = results
        .map(TmdbTvListItemDto.fromJson)
        .map((dto) => mediaItemFromTvDto(dto, imagesConfig: imagesConfig))
        .toList();

    test('maps name into title, first_air_date, and a resolved poster URL', () {
      final signalLost = shows.firstWhere((s) => s.id == 201);

      expect(signalLost.title, 'Signal Lost');
      expect(signalLost.releaseDate, DateTime(2024, 9, 12));
      expect(
        signalLost.posterUrl,
        'https://image.tmdb.org/t/p/w342/signal-lost.jpg',
      );
      expect(signalLost, isA<TvShow>());
    });

    test("TV's merged \"Action & Adventure\" (10759) maps to our "
        '"action"', () {
      final signalLost = shows.firstWhere((s) => s.id == 201);
      expect(signalLost.genres.map((g) => g.id), contains('action'));
    });

    test('an item with no poster_path, an empty first_air_date, and only '
        'unmapped genre ids (News/Reality) -> null poster, null date, and '
        'an empty genre list, not a crash', () {
      final midnightPanel = shows.firstWhere((s) => s.id == 202);

      expect(midnightPanel.posterUrl, isNull);
      expect(midnightPanel.releaseDate, isNull);
      expect(midnightPanel.genres, isEmpty);
    });
  });

  group(
    'mediaItemFromTrendingJson (test/fixtures/tmdb_trending_all_week.json)',
    () {
      final results =
          (_loadFixture('tmdb_trending_all_week.json')['results'] as List)
              .cast<Map<String, dynamic>>();

      test('a movie-typed entry maps to a Movie', () {
        final item = mediaItemFromTrendingJson(
          results.firstWhere((r) => r['id'] == 101),
          imagesConfig: imagesConfig,
        );

        expect(item, isA<Movie>());
        expect(item!.title, 'Trail of Embers');
      });

      test('a tv-typed entry maps to a TvShow', () {
        final item = mediaItemFromTrendingJson(
          results.firstWhere((r) => r['id'] == 201),
          imagesConfig: imagesConfig,
        );

        expect(item, isA<TvShow>());
        expect(item!.title, 'Signal Lost');
      });

      test('a person-typed entry maps to null — Discover never shows '
          'people', () {
        final item = mediaItemFromTrendingJson(
          results.firstWhere((r) => r['id'] == 301),
          imagesConfig: imagesConfig,
        );

        expect(item, isNull);
      });
    },
  );
}
