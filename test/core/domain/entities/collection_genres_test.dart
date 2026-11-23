import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/tmdb/tmdb_genre_mapper.dart';
import 'package:movies/core/domain/entities/collection_catalog.dart';
import 'package:movies/core/domain/entities/collection_genres.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_type.dart';

void main() {
  final catalog = CollectionCatalog.fromJsonString(
    File('assets/collections.json').readAsStringSync(),
  );
  const genreOf = TmdbGenreMapper.fromTmdbId;

  test('Anime requires Animation on both kinds; Kids requires Family on '
      'movies and excludes Horror, Thriller, Crime, War and Western', () {
    final anime = catalog.byId('anime')!;
    for (final type in MediaType.values) {
      expect(CollectionGenres.required(anime, type, genreOf), {
        const Genre(id: 'animation'),
      });
    }
    final kids = catalog.byId('kids')!;
    expect(CollectionGenres.required(kids, MediaType.movie, genreOf), {
      const Genre(id: 'family'),
    });
    expect(CollectionGenres.excluded(kids, MediaType.movie, genreOf), {
      const Genre(id: 'horror'),
      const Genre(id: 'thriller'),
      const Genre(id: 'crime'),
      const Genre(id: 'war'),
      const Genre(id: 'western'),
    });
  });

  test(
    'a genre TMDB has but we do not (Kids on TV, Soap) requires nothing',
    () {
      expect(
        CollectionGenres.required(
          catalog.byId('kids')!,
          MediaType.tvShow,
          genreOf,
        ),
        isEmpty,
      );
      expect(
        CollectionGenres.requiredAnywhere(catalog.byId('soaps')!, genreOf),
        isEmpty,
      );
    },
  );

  test(
    'with All, what the collection excludes on any kind: For kids leaves '
    'out Horror, Thriller, Crime, War and Western even though its TV side excludes none',
    () {
      final kids = catalog.byId('kids')!;
      expect(CollectionGenres.excludedFor(kids, null, genreOf), {
        const Genre(id: 'horror'),
        const Genre(id: 'thriller'),
        const Genre(id: 'crime'),
        const Genre(id: 'war'),
        const Genre(id: 'western'),
      });
      expect(
        CollectionGenres.excludedFor(kids, MediaType.tvShow, genreOf),
        isEmpty,
      );
      expect(
        CollectionGenres.excludedFor(catalog.byId('anime')!, null, genreOf),
        isEmpty,
      );
    },
  );

  test('a collection that doesn\'t exist for the kind requires nothing', () {
    expect(
      CollectionGenres.required(
        catalog.byId('turkish_series')!,
        MediaType.movie,
        genreOf,
      ),
      isEmpty,
    );
  });
}
