import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/tmdb/tmdb_discover_params.dart';
import 'package:movies/core/domain/entities/collection_catalog.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/genre_catalog.dart';
import 'package:movies/core/domain/entities/media_type.dart';

void main() {
  group('discoverQueryParams — always present', () {
    test('include_adult is always false', () {
      final params = discoverQueryParams(
        const DiscoverFilter(),
        type: MediaType.movie,
      );

      expect(params['include_adult'], false);
    });

    test('vote_count.gte defaults to 100 from H8, regardless of '
        'minVoteAverage', () {
      final params = discoverQueryParams(
        DiscoverFilter(minVoteAverage: 7),
        type: MediaType.movie,
      );

      expect(params['vote_count.gte'], 100);
    });

    test('vote_count.gte emits DiscoverFilter.minVoteCount\'s own value '
        'when set to something other than the default', () {
      final params = discoverQueryParams(
        const DiscoverFilter(minVoteCount: 200),
        type: MediaType.movie,
      );

      expect(params['vote_count.gte'], 200);
    });

    test('defaults to sort_by popularity.desc', () {
      final params = discoverQueryParams(
        const DiscoverFilter(),
        type: MediaType.movie,
      );

      expect(params['sort_by'], 'popularity.desc');
    });
  });

  group('discoverQueryParams — withGenres', () {
    test('OR semantics -> pipe-separated TMDB ids', () {
      final params = discoverQueryParams(
        DiscoverFilter(
          withGenres: {
            GenreCatalog.all.firstWhere((g) => g.id == 'action'),
            GenreCatalog.all.firstWhere((g) => g.id == 'comedy'),
          },
        ),
        type: MediaType.movie,
      );

      // action=28, comedy=35.
      expect(params['with_genres'], anyOf('28|35', '35|28'));
    });

    test('the same normalized genre resolves to a different TMDB id per '
        'type (TV\'s merged "Action & Adventure")', () {
      final action = GenreCatalog.all.firstWhere((g) => g.id == 'action');
      final movie = discoverQueryParams(
        DiscoverFilter(withGenres: {action}),
        type: MediaType.movie,
      );
      final tv = discoverQueryParams(
        DiscoverFilter(withGenres: {action}),
        type: MediaType.tvShow,
      );

      expect(movie['with_genres'], '28');
      expect(tv['with_genres'], '10759');
    });

    test('omitted entirely when empty', () {
      final params = discoverQueryParams(
        const DiscoverFilter(),
        type: MediaType.movie,
      );

      expect(params.containsKey('with_genres'), isFalse);
    });
  });

  group('discoverQueryParams — withoutGenres', () {
    test('comma-separated TMDB ids', () {
      final params = discoverQueryParams(
        DiscoverFilter(
          withoutGenres: {GenreCatalog.all.firstWhere((g) => g.id == 'horror')},
        ),
        type: MediaType.movie,
      );

      expect(params['without_genres'], '27');
    });
  });

  group('discoverQueryParams — excludeTalkAndNews', () {
    const suggesting = DiscoverFilter(excludeTalkAndNews: true);

    test('on TV it excludes Talk (10767) and News (10763), joined with the '
        'user\'s own vetoes', () {
      final params = discoverQueryParams(
        suggesting.copyWith(withoutGenres: {const Genre(id: 'comedy')}),
        type: MediaType.tvShow,
      );
      expect((params['without_genres'] as String).split(',').toSet(), {
        '35',
        '10767',
        '10763',
      });
    });

    test(
      'browsing (the default) excludes nothing, and movies are untouched',
      () {
        expect(
          discoverQueryParams(const DiscoverFilter(), type: MediaType.tvShow),
          isNot(contains('without_genres')),
        );
        expect(
          discoverQueryParams(suggesting, type: MediaType.movie),
          isNot(contains('without_genres')),
        );
      },
    );
  });

  group('discoverQueryParamSets — collections', () {
    final catalog = CollectionCatalog.fromJsonString(
      File('assets/collections.json').readAsStringSync(),
    );
    DiscoverFilter of(
      String id, {
      Set<Genre> genres = const {},
      int votes = 100,
    }) => DiscoverFilter(
      collection: catalog.byId(id),
      withGenres: genres,
      minVoteCount: votes,
    );
    List<Map<String, dynamic>> tv(DiscoverFilter f) =>
        discoverQueryParamSets(f, type: MediaType.tvShow);
    List<Map<String, dynamic>> movie(DiscoverFilter f) =>
        discoverQueryParamSets(f, type: MediaType.movie);

    test('a country collection: origin country, no talk or news, its own '
        'vote floor', () {
      final params = tv(of('turkish_series')).single;
      expect(params['with_origin_country'], 'TR');
      expect(params['without_genres'], '10767,10763');
      expect(params['vote_count.gte'], 30);
    });

    test('a section\'s own higher vote floor (Top rated) wins over the '
        'collection\'s', () {
      expect(
        tv(of('turkish_series', votes: 300)).single['vote_count.gte'],
        300,
      );
    });

    test('several countries are OR-ed with a pipe; a language is single', () {
      expect(
        (tv(of('latin_american_series')).single['with_origin_country']
                as String)
            .split('|'),
        containsAll(['MX', 'CO', 'AR']),
      );
      expect(movie(of('bollywood')).single['with_original_language'], 'hi');
    });

    test('Reality is a TV type; the type means nothing on movies', () {
      expect(tv(of('reality_shows')).single['with_type'], 3);
    });

    test('a collection missing for the type has no queries at all', () {
      expect(movie(of('turkish_series')), isEmpty);
      expect(tv(of('bollywood')), isEmpty);
    });

    test('Soaps are two queries: the keyword, and the Soap genre', () {
      final sets = tv(of('soaps'));
      expect(sets, hasLength(2));
      expect(sets[0]['with_keywords'], '199262');
      expect(sets[0], isNot(contains('with_genres')));
      expect(sets[1]['with_genres'], '10766');
    });

    test('Anime and a picked genre are ANDed: with_genres=16,35', () {
      final params = movie(
        of('anime', genres: {const Genre(id: 'comedy')}),
      ).single;
      expect(params['with_genres'], '16,35');
      expect(params['with_origin_country'], 'JP');
    });

    test(
      'two picked genres make one query each — any of them, with Animation',
      () {
        final sets = movie(
          of(
            'anime',
            genres: {
              const Genre(id: 'comedy'),
              const Genre(id: 'drama'),
            },
          ),
        );
        expect(sets.map((s) => s['with_genres']).toSet(), {'16,35', '16,18'});
      },
    );

    test('Kids on movies: Family or Animation, so one query per genre when '
        'one is picked too', () {
      expect(movie(of('kids')).single['with_genres'], '10751|16');
      final sets = movie(of('kids', genres: {const Genre(id: 'comedy')}));
      expect(sets.map((s) => s['with_genres']).toSet(), {'10751,35', '16,35'});
      expect(sets.first['without_genres'], '27,53,80');
    });

    test('the user\'s own vetoes join the collection\'s exclusions', () {
      final params = tv(
        DiscoverFilter(
          collection: catalog.byId('k_dramas'),
          withoutGenres: {const Genre(id: 'comedy')},
        ),
      ).single;
      expect((params['without_genres'] as String).split(',').toSet(), {
        '35',
        '10767',
        '10763',
        '10764',
      });
    });

    test('a collection keyword and a stand-in genre\'s keyword cannot share '
        'a request: that query drops, the genre one stays', () {
      final sets = tv(of('soaps', genres: {const Genre(id: 'horror')}));
      expect(sets.every((s) => s['with_keywords'] != '199262'), isTrue);
      expect(sets, isNotEmpty);
    });

    test('a collection counts as one active filter', () {
      expect(of('anime').activeFilterCount, 1);
    });
  });

  group('discoverQueryParams — withKeywords', () {
    test('OR semantics -> pipe-separated ids, several of them', () {
      final params = discoverQueryParams(
        const DiscoverFilter(withKeywords: {1, 2}),
        type: MediaType.movie,
      );

      expect(params['with_keywords'], anyOf('1|2', '2|1'));
    });

    test('a single id has no pipe at all', () {
      final params = discoverQueryParams(
        const DiscoverFilter(withKeywords: {1}),
        type: MediaType.movie,
      );

      expect(params['with_keywords'], '1');
    });

    test('omitted entirely when empty', () {
      final params = discoverQueryParams(
        const DiscoverFilter(),
        type: MediaType.movie,
      );

      expect(params.containsKey('with_keywords'), isFalse);
    });
  });

  group('discoverQueryParams — year range', () {
    test('movie uses primary_release_date.gte/lte, Jan 1 / Dec 31', () {
      final params = discoverQueryParams(
        const DiscoverFilter(yearFrom: 1990, yearTo: 1999),
        type: MediaType.movie,
      );

      expect(params['primary_release_date.gte'], '1990-01-01');
      expect(params['primary_release_date.lte'], '1999-12-31');
    });

    test('TV uses first_air_date.gte/lte instead', () {
      final params = discoverQueryParams(
        const DiscoverFilter(yearFrom: 1990),
        type: MediaType.tvShow,
      );

      expect(params['first_air_date.gte'], '1990-01-01');
      expect(params.containsKey('primary_release_date.gte'), isFalse);
    });

    test('omitted when unset', () {
      final params = discoverQueryParams(
        const DiscoverFilter(),
        type: MediaType.movie,
      );

      expect(params.containsKey('primary_release_date.gte'), isFalse);
      expect(params.containsKey('primary_release_date.lte'), isFalse);
    });
  });

  group('discoverQueryParams — minVoteAverage', () {
    test('vote_average.gte matches the filter value', () {
      final params = discoverQueryParams(
        const DiscoverFilter(minVoteAverage: 7.5),
        type: MediaType.movie,
      );

      expect(params['vote_average.gte'], 7.5);
    });

    test('omitted when unset', () {
      final params = discoverQueryParams(
        const DiscoverFilter(),
        type: MediaType.movie,
      );

      expect(params.containsKey('vote_average.gte'), isFalse);
    });
  });

  group('discoverQueryParams — maxRuntimeMinutes (movies only)', () {
    test('with_runtime.lte for a movie', () {
      final params = discoverQueryParams(
        const DiscoverFilter(maxRuntimeMinutes: 120),
        type: MediaType.movie,
      );

      expect(params['with_runtime.lte'], 120);
    });

    test('never set for a TV show, even if present on the filter', () {
      final params = discoverQueryParams(
        const DiscoverFilter(maxRuntimeMinutes: 120),
        type: MediaType.tvShow,
      );

      expect(params.containsKey('with_runtime.lte'), isFalse);
    });
  });

  group('discoverQueryParams — tvStatus (TV only)', () {
    test('airing -> with_status 0', () {
      final params = discoverQueryParams(
        const DiscoverFilter(tvStatus: DiscoverTvStatus.airing),
        type: MediaType.tvShow,
      );

      expect(params['with_status'], '0');
    });

    test('ended -> with_status 3', () {
      final params = discoverQueryParams(
        const DiscoverFilter(tvStatus: DiscoverTvStatus.ended),
        type: MediaType.tvShow,
      );

      expect(params['with_status'], '3');
    });

    test('never set for a movie, even if present on the filter', () {
      final params = discoverQueryParams(
        const DiscoverFilter(tvStatus: DiscoverTvStatus.airing),
        type: MediaType.movie,
      );

      expect(params.containsKey('with_status'), isFalse);
    });
  });

  group('discoverQueryParams — sortBy per type', () {
    test('releaseDate: primary_release_date.desc for movie, '
        'first_air_date.desc for TV', () {
      final movie = discoverQueryParams(
        const DiscoverFilter(sortBy: DiscoverSortBy.releaseDate),
        type: MediaType.movie,
      );
      final tv = discoverQueryParams(
        const DiscoverFilter(sortBy: DiscoverSortBy.releaseDate),
        type: MediaType.tvShow,
      );

      expect(movie['sort_by'], 'primary_release_date.desc');
      expect(tv['sort_by'], 'first_air_date.desc');
    });

    test('rating -> vote_average.desc for both types', () {
      final params = discoverQueryParams(
        const DiscoverFilter(sortBy: DiscoverSortBy.rating),
        type: MediaType.movie,
      );

      expect(params['sort_by'], 'vote_average.desc');
    });

    test('title: title.asc for movie, name.asc for TV', () {
      final movie = discoverQueryParams(
        const DiscoverFilter(sortBy: DiscoverSortBy.title),
        type: MediaType.movie,
      );
      final tv = discoverQueryParams(
        const DiscoverFilter(sortBy: DiscoverSortBy.title),
        type: MediaType.tvShow,
      );

      expect(movie['sort_by'], 'title.asc');
      expect(tv['sort_by'], 'name.asc');
    });
  });

  group('discoverQueryParams — B2 browse fields', () {
    test('with_watch_providers + watch_region only together, OR-joined', () {
      final params = discoverQueryParams(
        const DiscoverFilter(withWatchProviders: {8, 337}),
        type: MediaType.movie,
        watchRegion: 'ES',
      );
      expect(params['with_watch_providers'], '8|337');
      expect(params['watch_region'], 'ES');

      // No region -> a provider filter can't mean anything: left out.
      final noRegion = discoverQueryParams(
        const DiscoverFilter(withWatchProviders: {8}),
        type: MediaType.movie,
      );
      expect(noRegion.containsKey('with_watch_providers'), isFalse);

      // No providers -> no region either.
      final none = discoverQueryParams(
        const DiscoverFilter(),
        type: MediaType.movie,
        watchRegion: 'ES',
      );
      expect(none.containsKey('watch_region'), isFalse);
    });

    test('an exact release window uses the right date field per type, and '
        'wins over the year bounds', () {
      final filter = DiscoverFilter(
        yearFrom: 1990,
        releasedFrom: DateTime(2026, 3, 5),
        releasedTo: DateTime(2026, 5, 4),
      );
      final movie = discoverQueryParams(filter, type: MediaType.movie);
      expect(movie['primary_release_date.gte'], '2026-03-05');
      expect(movie['primary_release_date.lte'], '2026-05-04');

      final tv = discoverQueryParams(filter, type: MediaType.tvShow);
      expect(tv['first_air_date.gte'], '2026-03-05');
      expect(tv['first_air_date.lte'], '2026-05-04');
    });

    test('maxVoteCount becomes vote_count.lte', () {
      final params = discoverQueryParams(
        const DiscoverFilter(maxVoteCount: 1500),
        type: MediaType.movie,
      );
      expect(params['vote_count.lte'], 1500);
      expect(
        discoverQueryParams(
          const DiscoverFilter(),
          type: MediaType.movie,
        ).containsKey('vote_count.lte'),
        isFalse,
      );
    });

    test('the new fields take part in equality and copyWith', () {
      const a = DiscoverFilter(withWatchProviders: {8}, maxVoteCount: 10);
      expect(
        a,
        const DiscoverFilter(withWatchProviders: {8}, maxVoteCount: 10),
      );
      expect(
        a == const DiscoverFilter(withWatchProviders: {9}, maxVoteCount: 10),
        isFalse,
      );
      expect(a.copyWith(maxVoteCount: () => null).maxVoteCount, isNull);
      expect(a.isDefault, isFalse);
    });
  });

  test('sorting by votes sends vote_count.desc for both types', () {
    for (final type in MediaType.values) {
      final params = discoverQueryParams(
        const DiscoverFilter(sortBy: DiscoverSortBy.voteCount),
        type: type,
      );
      expect(params['sort_by'], 'vote_count.desc');
    }
  });

  group('discoverQueryParams — Surprise me\'s filters', () {
    const horror = Genre(id: 'horror');

    test('without_keywords: explicit ids, comma-joined', () {
      final params = discoverQueryParams(
        const DiscoverFilter(withoutKeywords: {1, 2}),
        type: MediaType.movie,
      );

      expect(params['without_keywords'], '1,2');
    });

    test(
      'a TV veto with no TV genre becomes a keyword, not a dropped veto',
      () {
        final params = discoverQueryParams(
          DiscoverFilter(
            withoutGenres: {
              horror,
              const Genre(id: 'comedy'),
            },
          ),
          type: MediaType.tvShow,
        );

        expect(params['without_genres'], '35');
        expect(params['without_keywords'], '315058');
      },
    );

    test('a movie veto stays a genre and adds no keyword', () {
      final params = discoverQueryParams(
        DiscoverFilter(withoutGenres: {horror}),
        type: MediaType.movie,
      );

      expect(params['without_genres'], '27');
      expect(params.containsKey('without_keywords'), isFalse);
    });

    test('nothing to exclude: no without_keywords at all', () {
      final params = discoverQueryParams(
        const DiscoverFilter(),
        type: MediaType.tvShow,
      );

      expect(params.containsKey('without_keywords'), isFalse);
    });

    test('monetization types go with the platforms, OR-joined', () {
      final params = discoverQueryParams(
        const DiscoverFilter(
          withWatchProviders: {8, 337},
          monetizationTypes: {
            WatchMonetization.flatrate,
            WatchMonetization.rent,
          },
        ),
        type: MediaType.movie,
        watchRegion: 'ES',
      );

      expect(params['with_watch_providers'], '8|337');
      expect(params['watch_region'], 'ES');
      expect(params['with_watch_monetization_types'], 'flatrate|rent');
    });

    test('monetization alone = any service of the region: the region and the '
        'types go, no provider list', () {
      final params = discoverQueryParams(
        const DiscoverFilter(monetizationTypes: {WatchMonetization.flatrate}),
        type: MediaType.movie,
        watchRegion: 'ES',
      );

      expect(params['watch_region'], 'ES');
      expect(params['with_watch_monetization_types'], 'flatrate');
      expect(params.containsKey('with_watch_providers'), isFalse);
    });

    test('nothing about availability set: none of the three params', () {
      final params = discoverQueryParams(
        const DiscoverFilter(),
        type: MediaType.movie,
        watchRegion: 'ES',
      );

      expect(params.containsKey('watch_region'), isFalse);
      expect(params.containsKey('with_watch_monetization_types'), isFalse);
      expect(params.containsKey('with_watch_providers'), isFalse);
    });

    test('no region known: availability is left out (it means nothing without '
        'one)', () {
      final params = discoverQueryParams(
        const DiscoverFilter(monetizationTypes: {WatchMonetization.flatrate}),
        type: MediaType.movie,
      );

      expect(params.containsKey('with_watch_monetization_types'), isFalse);
    });

    test('the new fields count in equality', () {
      expect(
        const DiscoverFilter(withoutKeywords: {1}),
        isNot(const DiscoverFilter()),
      );
      expect(
        const DiscoverFilter(monetizationTypes: {WatchMonetization.rent}),
        isNot(const DiscoverFilter()),
      );
      expect(
        const DiscoverFilter(withoutKeywords: {1}),
        const DiscoverFilter(withoutKeywords: {1}),
      );
    });
  });

  group('discoverQueryParams — TV genres', () {
    const tv = MediaType.tvShow;

    test('liking Adventure or Fantasy on TV asks for the combined genre', () {
      final params = discoverQueryParams(
        DiscoverFilter(
          withGenres: {
            const Genre(id: 'adventure'),
            const Genre(id: 'fantasy'),
          },
        ),
        type: tv,
      );
      expect(params['with_genres'], anyOf('10759|10765', '10765|10759'));
    });

    test('Western and War reach TV by their own ids', () {
      final params = discoverQueryParams(
        DiscoverFilter(
          withGenres: {
            const Genre(id: 'western'),
            const Genre(id: 'war'),
          },
        ),
        type: tv,
      );
      expect(params['with_genres'], anyOf('37|10768', '10768|37'));
    });

    test('vetoing Fantasy on TV does not exclude Sci-Fi & Fantasy; vetoing '
        'both does', () {
      final one = discoverQueryParams(
        DiscoverFilter(withoutGenres: {const Genre(id: 'fantasy')}),
        type: tv,
      );
      final both = discoverQueryParams(
        DiscoverFilter(
          withoutGenres: {
            const Genre(id: 'fantasy'),
            const Genre(id: 'sci-fi'),
          },
        ),
        type: tv,
      );
      expect(one.containsKey('without_genres'), isFalse);
      expect(both['without_genres'], '10765');
    });

    test('movies are untouched: Fantasy is 14 and Adventure 12 there', () {
      final params = discoverQueryParams(
        DiscoverFilter(
          withGenres: {
            const Genre(id: 'fantasy'),
            const Genre(id: 'adventure'),
          },
          withoutGenres: {const Genre(id: 'war')},
        ),
        type: MediaType.movie,
      );
      expect(params['with_genres'], anyOf('14|12', '12|14'));
      expect(params['without_genres'], '10752');
    });

    test('vetoing a stand-in genre excludes its keywords', () {
      final params = discoverQueryParams(
        DiscoverFilter(withoutGenres: {const Genre(id: 'history')}),
        type: tv,
      );
      expect(params.containsKey('without_genres'), isFalse);
      expect((params['without_keywords'] as String).split(',').toSet(), {
        '15060',
        '15126',
        '282633',
      });
    });
  });

  group('discoverQueryParamSets', () {
    const tv = MediaType.tvShow;

    test('a movie filter, or a TV filter with nothing to stand in for, is one '
        'query — the same as discoverQueryParams', () {
      final movie = DiscoverFilter(withGenres: {const Genre(id: 'horror')});
      expect(discoverQueryParamSets(movie, type: MediaType.movie), [
        discoverQueryParams(movie, type: MediaType.movie),
      ]);
      final plain = DiscoverFilter(withGenres: {const Genre(id: 'comedy')});
      expect(discoverQueryParamSets(plain, type: tv), [
        discoverQueryParams(plain, type: tv),
      ]);
    });

    test('liking only a stand-in genre on TV is one query by keyword', () {
      final sets = discoverQueryParamSets(
        DiscoverFilter(withGenres: {const Genre(id: 'horror')}),
        type: tv,
      );
      expect(sets, hasLength(1));
      expect(sets.single['with_keywords'], '315058');
      expect(sets.single.containsKey('with_genres'), isFalse);
    });

    test('a native like and a stand-in like are two queries, both with the '
        'rest of the filter', () {
      final sets = discoverQueryParamSets(
        DiscoverFilter(
          withGenres: {
            const Genre(id: 'drama'),
            const Genre(id: 'horror'),
          },
          withoutGenres: {const Genre(id: 'comedy')},
          yearFrom: 2000,
          minVoteCount: 150,
        ),
        type: tv,
      );

      expect(sets, hasLength(2));
      expect(sets[0]['with_genres'], '18');
      expect(sets[0].containsKey('with_keywords'), isFalse);
      expect(sets[1]['with_keywords'], '315058');
      expect(sets[1].containsKey('with_genres'), isFalse);
      for (final s in sets) {
        expect(s['without_genres'], '35');
        expect(s['first_air_date.gte'], '2000-01-01');
        expect(s['vote_count.gte'], 150);
      }
    });

    test('Music is its own query and leaves Talk out, keeping the vetoes', () {
      final sets = discoverQueryParamSets(
        DiscoverFilter(
          withGenres: {
            const Genre(id: 'music'),
            const Genre(id: 'romance'),
          },
          withoutGenres: {const Genre(id: 'comedy')},
        ),
        type: tv,
      );

      expect(sets, hasLength(2));
      expect(sets[0]['with_keywords'], '9840');
      expect(sets[0]['without_genres'], '35');
      expect(
        (sets[1]['with_keywords'] as String).split('|').toSet(),
        containsAll({'283297', '4344'}),
      );
      expect((sets[1]['without_genres'] as String).split(',').toSet(), {
        '35',
        '10767',
      });
    });

    test('a filter that already has keywords (a vibe\'s) leaves the stand-ins '
        'out: they would be OR-ed into the same with_keywords', () {
      final sets = discoverQueryParamSets(
        DiscoverFilter(
          withGenres: {
            const Genre(id: 'horror'),
            const Genre(id: 'drama'),
          },
          withKeywords: {1299},
        ),
        type: tv,
      );
      expect(sets, hasLength(1));
      expect(sets.single['with_genres'], '18');
      expect(sets.single['with_keywords'], '1299');
    });
  });
}
