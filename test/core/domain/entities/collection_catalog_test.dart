import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/collection.dart';
import 'package:movies/core/domain/entities/collection_catalog.dart';
import 'package:movies/core/domain/entities/media_type.dart';

void main() {
  // The real file, read straight from disk: no asset bundle, no Flutter.
  final catalog = CollectionCatalog.fromJsonString(
    File('assets/collections.json').readAsStringSync(),
  );

  List<String> ids(Iterable<Collection> cs) => [for (final c in cs) c.id];

  test('13 collections: 9 of the world, 3 formats and 1 occasion', () {
    expect(catalog.all(), hasLength(13));
    expect(
      catalog.inGroup(CollectionGroup.world, MediaType.movie),
      hasLength(4),
    );
    expect(
      catalog.inGroup(CollectionGroup.world, MediaType.tvShow),
      hasLength(5),
    );
    expect(
      catalog.all().where((c) => c.group == CollectionGroup.format),
      hasLength(3),
    );
    expect(
      catalog.all().where((c) => c.group == CollectionGroup.occasion),
      hasLength(1),
    );
  });

  test('each kind of title gets only the collections that exist for it', () {
    expect(ids(catalog.availableFor(MediaType.movie)), [
      'spanish_cinema',
      'korean_cinema',
      'bollywood',
      'indian_cinema',
      'anime',
      'kids',
    ]);
    expect(ids(catalog.availableFor(MediaType.tvShow)), [
      'turkish_series',
      'spanish_series',
      'latin_american_series',
      'k_dramas',
      'british_series',
      'soaps',
      'anime',
      'reality_shows',
      'kids',
    ]);
  });

  test('ids are unique and byId finds one, or null for a stale id', () {
    expect({for (final c in catalog.all()) c.id}, hasLength(13));
    expect(catalog.byId('anime')?.id, 'anime');
    expect(catalog.byId('western'), isNull);
  });

  test('only Kids stays out of My Tastes', () {
    expect(
      [
        for (final c in catalog.all())
          if (!c.inTastes) c.id,
      ],
      ['kids'],
    );
  });

  test('Soaps are a union: the "telenovela" keyword or the Soap genre, any '
      'country', () {
    final queries = catalog.byId('soaps')!.tv!.queries;
    expect(queries, hasLength(2));
    expect(queries[0].withKeywordIds, {199262});
    expect(queries[1].withTmdbGenreIds, {10766});
    expect(queries.every((q) => q.originCountries.isEmpty), isTrue);
  });

  test('Anime is Animation and Japan in both kinds of title', () {
    for (final type in MediaType.values) {
      final q = catalog.byId('anime')!.ruleFor(type)!.queries.single;
      expect(q.withTmdbGenreIds, {16});
      expect(q.originCountries, {'JP'});
    }
  });

  test('country series keep talk shows and news out; K-dramas reality too', () {
    for (final id in [
      'turkish_series',
      'spanish_series',
      'latin_american_series',
    ]) {
      final q = catalog.byId(id)!.tv!.queries.single;
      expect(q.withoutTmdbGenreIds, {10767, 10763}, reason: id);
    }
    expect(catalog.byId('k_dramas')!.tv!.queries.single.withoutTmdbGenreIds, {
      10767,
      10763,
      10764,
    });
  });

  test('Reality is TMDB type 3, Turkish series have a lower vote floor', () {
    expect(catalog.byId('reality_shows')!.tv!.queries.single.tvType, 3);
    expect(catalog.byId('turkish_series')!.tv!.queries.single.minVoteCount, 30);
    expect(
      catalog.byId('british_series')!.tv!.queries.single.minVoteCount,
      100,
    );
  });

  test('Bollywood is by language, Indian cinema by country — both exist', () {
    expect(
      catalog.byId('bollywood')!.movie!.queries.single.originalLanguage,
      'hi',
    );
    expect(
      catalog.byId('indian_cinema')!.movie!.queries.single.originCountries,
      {'IN'},
    );
  });

  test('Kids: family or animation without horror, thriller and crime on '
      'movies; the Kids genre on TV', () {
    final kids = catalog.byId('kids')!;
    final movie = kids.movie!.queries.single;
    expect(movie.withTmdbGenreIds, {10751, 16});
    expect(movie.requireAllGenres, isFalse);
    expect(movie.withoutTmdbGenreIds, {27, 53, 80});
    expect(kids.tv!.queries.single.withTmdbGenreIds, {10762});
  });

  test('a new row in the JSON is a new collection, with no code', () {
    final parsed = CollectionCatalog.fromJsonString('''
      {"collections": [{"id": "miniseries", "group": "format",
        "tv": {"queries": [{"tvType": 2, "minVoteCount": 50}]}}]}
    ''');
    expect(parsed.availableFor(MediaType.tvShow).single.id, 'miniseries');
    expect(parsed.availableFor(MediaType.movie), isEmpty);
    expect(parsed.all().single.inTastes, isTrue);
  });
}
