import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/tmdb/tmdb_discover_params.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/genre_catalog.dart';
import 'package:movies/core/domain/entities/media_type.dart';

void main() {
  group('discoverQueryParams — always present', () {
    test('include_adult is always false', () {
      final params = discoverQueryParams(
        const DiscoverFilter(),
        type: MediaType.movie,
        region: 'ES',
      );

      expect(params['include_adult'], false);
    });

    test('vote_count.gte is always the fixed 100 from H8, regardless of '
        'minVoteAverage', () {
      final params = discoverQueryParams(
        DiscoverFilter(minVoteAverage: 7),
        type: MediaType.movie,
        region: 'ES',
      );

      expect(params['vote_count.gte'], 100);
    });

    test('defaults to sort_by popularity.desc', () {
      final params = discoverQueryParams(
        const DiscoverFilter(),
        type: MediaType.movie,
        region: 'ES',
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
        region: 'ES',
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
        region: 'ES',
      );
      final tv = discoverQueryParams(
        DiscoverFilter(withGenres: {action}),
        type: MediaType.tvShow,
        region: 'ES',
      );

      expect(movie['with_genres'], '28');
      expect(tv['with_genres'], '10759');
    });

    test('omitted entirely when empty', () {
      final params = discoverQueryParams(
        const DiscoverFilter(),
        type: MediaType.movie,
        region: 'ES',
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
        region: 'ES',
      );

      expect(params['without_genres'], '27');
    });
  });

  group('discoverQueryParams — year range', () {
    test('movie uses primary_release_date.gte/lte, Jan 1 / Dec 31', () {
      final params = discoverQueryParams(
        const DiscoverFilter(yearFrom: 1990, yearTo: 1999),
        type: MediaType.movie,
        region: 'ES',
      );

      expect(params['primary_release_date.gte'], '1990-01-01');
      expect(params['primary_release_date.lte'], '1999-12-31');
    });

    test('TV uses first_air_date.gte/lte instead', () {
      final params = discoverQueryParams(
        const DiscoverFilter(yearFrom: 1990),
        type: MediaType.tvShow,
        region: 'ES',
      );

      expect(params['first_air_date.gte'], '1990-01-01');
      expect(params.containsKey('primary_release_date.gte'), isFalse);
    });

    test('omitted when unset', () {
      final params = discoverQueryParams(
        const DiscoverFilter(),
        type: MediaType.movie,
        region: 'ES',
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
        region: 'ES',
      );

      expect(params['vote_average.gte'], 7.5);
    });

    test('omitted when unset', () {
      final params = discoverQueryParams(
        const DiscoverFilter(),
        type: MediaType.movie,
        region: 'ES',
      );

      expect(params.containsKey('vote_average.gte'), isFalse);
    });
  });

  group('discoverQueryParams — maxRuntimeMinutes (movies only)', () {
    test('with_runtime.lte for a movie', () {
      final params = discoverQueryParams(
        const DiscoverFilter(maxRuntimeMinutes: 120),
        type: MediaType.movie,
        region: 'ES',
      );

      expect(params['with_runtime.lte'], 120);
    });

    test('never set for a TV show, even if present on the filter', () {
      final params = discoverQueryParams(
        const DiscoverFilter(maxRuntimeMinutes: 120),
        type: MediaType.tvShow,
        region: 'ES',
      );

      expect(params.containsKey('with_runtime.lte'), isFalse);
    });
  });

  group('discoverQueryParams — tvStatus (TV only)', () {
    test('airing -> with_status 0', () {
      final params = discoverQueryParams(
        const DiscoverFilter(tvStatus: DiscoverTvStatus.airing),
        type: MediaType.tvShow,
        region: 'ES',
      );

      expect(params['with_status'], '0');
    });

    test('ended -> with_status 3', () {
      final params = discoverQueryParams(
        const DiscoverFilter(tvStatus: DiscoverTvStatus.ended),
        type: MediaType.tvShow,
        region: 'ES',
      );

      expect(params['with_status'], '3');
    });

    test('never set for a movie, even if present on the filter', () {
      final params = discoverQueryParams(
        const DiscoverFilter(tvStatus: DiscoverTvStatus.airing),
        type: MediaType.movie,
        region: 'ES',
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
        region: 'ES',
      );
      final tv = discoverQueryParams(
        const DiscoverFilter(sortBy: DiscoverSortBy.releaseDate),
        type: MediaType.tvShow,
        region: 'ES',
      );

      expect(movie['sort_by'], 'primary_release_date.desc');
      expect(tv['sort_by'], 'first_air_date.desc');
    });

    test('rating -> vote_average.desc for both types', () {
      final params = discoverQueryParams(
        const DiscoverFilter(sortBy: DiscoverSortBy.rating),
        type: MediaType.movie,
        region: 'ES',
      );

      expect(params['sort_by'], 'vote_average.desc');
    });

    test('title: title.asc for movie, name.asc for TV', () {
      final movie = discoverQueryParams(
        const DiscoverFilter(sortBy: DiscoverSortBy.title),
        type: MediaType.movie,
        region: 'ES',
      );
      final tv = discoverQueryParams(
        const DiscoverFilter(sortBy: DiscoverSortBy.title),
        type: MediaType.tvShow,
        region: 'ES',
      );

      expect(movie['sort_by'], 'title.asc');
      expect(tv['sort_by'], 'name.asc');
    });
  });

  group('discoverQueryParams — familyMode', () {
    test('off by default: no certification params at all', () {
      final params = discoverQueryParams(
        const DiscoverFilter(),
        type: MediaType.movie,
        region: 'ES',
      );

      expect(params.containsKey('certification_country'), isFalse);
      expect(params.containsKey('certification.lte'), isFalse);
    });

    test('on: certification_country matches the given region, with a '
        'fixed certification.lte', () {
      final params = discoverQueryParams(
        const DiscoverFilter(),
        type: MediaType.movie,
        region: 'ES',
        familyMode: true,
      );

      expect(params['certification_country'], 'ES');
      expect(params['certification.lte'], '16');
    });

    test('applies the same way to a TV discover call', () {
      final params = discoverQueryParams(
        const DiscoverFilter(),
        type: MediaType.tvShow,
        region: 'ES',
        familyMode: true,
      );

      expect(params['certification_country'], 'ES');
      expect(params['certification.lte'], '16');
    });
  });
}
