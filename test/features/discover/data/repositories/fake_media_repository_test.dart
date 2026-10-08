import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/season_summary.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';

const _drama = Genre(id: 'drama');
const _comedy = Genre(id: 'comedy');
const _sciFi = Genre(id: 'sci-fi');
const _horror = Genre(id: 'horror');

void main() {
  group('FakeMediaRepository.detail', () {
    final repository = FakeMediaRepository();

    test(
      'returns a coherent MovieDetail for each of the 3 sample ids',
      () async {
        for (final id in [1, 2, 3]) {
          final result = await repository.detail(
            MediaKey(type: MediaType.movie, tmdbId: id),
          );

          expect(result, isA<Success<MediaDetail>>());
          final detail = (result as Success<MediaDetail>).value as MovieDetail;

          expect(detail.item.id, id);
          expect(detail.overview, isNotEmpty);
          expect(detail.cast, isNotEmpty);
          expect(detail.crew, isNotEmpty);
          expect(
            detail.trailer,
            isNotNull,
            reason: 'D1 needs a Trailer button',
          );
          expect(detail.trailer!.isYoutube, isTrue);
          expect(detail.similar, isNotEmpty);
          expect(detail.watchProviders.hasAny, isTrue);
          expect(detail.runtimeMinutes, isNotNull);
        }
      },
    );

    test(
      'falls back to an empty-but-valid detail for a movie with no sample data',
      () async {
        final result = await repository.detail(
          const MediaKey(type: MediaType.movie, tmdbId: 4), // Knives Out
        );

        final detail = (result as Success<MediaDetail>).value as MovieDetail;

        expect(detail.item.title, 'Knives Out');
        expect(detail.cast, isEmpty);
        expect(detail.trailer, isNull);
        expect(detail.watchProviders.hasAny, isFalse);
      },
    );

    test('fails for an unknown movie id', () async {
      final result = await repository.detail(
        const MediaKey(type: MediaType.movie, tmdbId: 999),
      );

      expect(result, isA<Failure<MediaDetail>>());
    });

    test(
      'returns a coherent TvShowDetail for each of the 3 sample ids',
      () async {
        for (final id in [101, 103, 106]) {
          final result = await repository.detail(
            MediaKey(type: MediaType.tvShow, tmdbId: id),
          );

          expect(result, isA<Success<MediaDetail>>());
          final detail = (result as Success<MediaDetail>).value as TvShowDetail;

          expect(detail.item.id, id);
          expect(detail.overview, isNotEmpty);
          expect(detail.cast, isNotEmpty);
          expect(detail.creators, isNotEmpty);
          expect(detail.seasons, isNotEmpty);
          expect(detail.watchProviders.hasAny, isTrue);
        }
      },
    );

    test('falls back to an empty-but-valid detail for a TV show with no '
        'sample data', () async {
      final result = await repository.detail(
        const MediaKey(type: MediaType.tvShow, tmdbId: 102), // Fallout
      );

      final detail = (result as Success<MediaDetail>).value as TvShowDetail;

      expect(detail.item.title, 'Fallout');
      expect(detail.cast, isEmpty);
      expect(detail.seasons, isEmpty);
      expect(detail.watchProviders.hasAny, isFalse);
    });

    test('fails for an unknown TV show id', () async {
      final result = await repository.detail(
        const MediaKey(type: MediaType.tvShow, tmdbId: 999),
      );

      expect(result, isA<Failure<MediaDetail>>());
    });
  });

  group('FakeMediaRepository.season', () {
    final repository = FakeMediaRepository();

    test('returns the special season (0) for a show that has one', () async {
      final result = await repository.season(101, 0); // The Bear

      final season = (result as Success<SeasonDetail>).value;
      expect(season.name, 'Specials');
      expect(season.episodes, isNotEmpty);
    });

    test('returns a regular season for an airing show with several '
        'seasons', () async {
      final result = await repository.season(106, 4); // The Boys

      final season = (result as Success<SeasonDetail>).value;
      expect(season.seasonNumber, 4);
      expect(season.overview, isNotEmpty);
      expect(season.episodes, isNotEmpty);
    });

    test('returns a season for an ended show', () async {
      final result = await repository.season(103, 1); // True Detective

      final season = (result as Success<SeasonDetail>).value;
      expect(season.name, 'Season 1');
      expect(season.episodes.first.name, isNotEmpty);
    });

    test('fails for a season with no sample data', () async {
      final result = await repository.season(106, 2); // The Boys S2

      expect(result, isA<Failure<SeasonDetail>>());
    });

    test('fails for an unknown TV show id', () async {
      final result = await repository.season(999, 1);

      expect(result, isA<Failure<SeasonDetail>>());
    });
  });

  group('FakeMediaRepository.searchMulti', () {
    final repository = FakeMediaRepository();

    test('matches a title substring, case-insensitively', () async {
      final result = await repository.searchMulti('dune');

      final items = (result as Success<List<MediaItem>>).value;
      expect(items.map((i) => i.title), ['Dune: Part Two']);
    });

    test('matches across both movies and TV shows', () async {
      final result = await repository.searchMulti('the');

      final items = (result as Success<List<MediaItem>>).value;
      expect(
        items.map((i) => i.title),
        containsAll(['The Substance', 'The Bear', 'The Boys']),
      );
    });

    test('returns nothing for a query matching no title', () async {
      final result = await repository.searchMulti('xyz-not-a-title');

      expect((result as Success<List<MediaItem>>).value, isEmpty);
    });

    test('a blank query returns nothing rather than everything', () async {
      final result = await repository.searchMulti('   ');

      expect((result as Success<List<MediaItem>>).value, isEmpty);
    });
  });

  group('FakeMediaRepository.discover', () {
    final repository = FakeMediaRepository();

    test('type: movie only returns movies; tvShow only TV shows', () async {
      final movies = await repository.discover(
        const DiscoverFilter(type: MediaType.movie),
      );
      final tvShows = await repository.discover(
        const DiscoverFilter(type: MediaType.tvShow),
      );

      expect(
        (movies as Success<List<MediaItem>>).value.every(
          (i) => i.type == MediaType.movie,
        ),
        isTrue,
      );
      expect(
        (tvShows as Success<List<MediaItem>>).value.every(
          (i) => i.type == MediaType.tvShow,
        ),
        isTrue,
      );
    });

    test('type: null (All) interleaves both types', () async {
      final result = await repository.discover(const DiscoverFilter());

      final items = (result as Success<List<MediaItem>>).value;
      expect(items.any((i) => i.type == MediaType.movie), isTrue);
      expect(items.any((i) => i.type == MediaType.tvShow), isTrue);
    });

    test('withGenres matches any of the given genres (OR), not all', () async {
      final result = await repository.discover(
        DiscoverFilter(type: MediaType.movie, withGenres: {_horror}),
      );

      final items = (result as Success<List<MediaItem>>).value;
      expect(items.map((i) => i.title), ['The Substance']);
    });

    test('withoutGenres excludes anything matching any of them', () async {
      final result = await repository.discover(
        DiscoverFilter(type: MediaType.movie, withoutGenres: {_drama, _sciFi}),
      );

      final items = (result as Success<List<MediaItem>>).value;
      // Every remaining movie has neither Drama nor Science Fiction.
      expect(
        items.every(
          (i) => !i.genres.contains(_drama) && !i.genres.contains(_sciFi),
        ),
        isTrue,
      );
      expect(items, isNotEmpty);
    });

    test('yearFrom/yearTo bounds by release year, inclusive', () async {
      final result = await repository.discover(
        const DiscoverFilter(
          type: MediaType.movie,
          yearFrom: 2023,
          yearTo: 2023,
        ),
      );

      final items = (result as Success<List<MediaItem>>).value;
      expect(items.every((i) => i.releaseDate!.year == 2023), isTrue);
      expect(items, isNotEmpty);
    });

    test('an item with no release date never matches a year bound', () async {
      final result = await repository.discover(
        const DiscoverFilter(type: MediaType.movie, yearFrom: 1900),
      );

      final items = (result as Success<List<MediaItem>>).value;
      expect(items.any((i) => i.title == 'Untitled Sci-Fi Project'), isFalse);
    });

    test('minVoteAverage filters out anything rated lower', () async {
      final result = await repository.discover(
        const DiscoverFilter(type: MediaType.movie, minVoteAverage: 8.0),
      );

      final items = (result as Success<List<MediaItem>>).value;
      expect(items.every((i) => i.voteAverage >= 8.0), isTrue);
      expect(items, isNotEmpty);
    });

    test('sortBy: rating orders highest first', () async {
      final result = await repository.discover(
        const DiscoverFilter(
          type: MediaType.movie,
          sortBy: DiscoverSortBy.rating,
        ),
      );

      final ratings = (result as Success<List<MediaItem>>).value
          .map((i) => i.voteAverage)
          .toList();
      expect(ratings, [...ratings]..sort((a, b) => b.compareTo(a)));
    });

    test('sortBy: title orders alphabetically', () async {
      final result = await repository.discover(
        const DiscoverFilter(
          type: MediaType.movie,
          sortBy: DiscoverSortBy.title,
        ),
      );

      final titles = (result as Success<List<MediaItem>>).value
          .map((i) => i.title)
          .toList();
      expect(titles, [...titles]..sort());
    });

    test('sortBy: releaseDate orders most recent first', () async {
      final result = await repository.discover(
        const DiscoverFilter(
          type: MediaType.movie,
          sortBy: DiscoverSortBy.releaseDate,
        ),
      );

      final dates = (result as Success<List<MediaItem>>).value
          .map((i) => i.releaseDate)
          .toList();
      for (var i = 1; i < dates.length; i++) {
        final prev = dates[i - 1] ?? DateTime(0);
        final curr = dates[i] ?? DateTime(0);
        expect(prev.isAfter(curr) || prev.isAtSameMomentAs(curr), isTrue);
      }
    });

    test('sortBy: popularity keeps the sample data\'s own declared order '
        '(no dedicated popularity field on MediaItem yet)', () async {
      final result = await repository.discover(
        const DiscoverFilter(type: MediaType.movie),
      );

      final titles = (result as Success<List<MediaItem>>).value
          .map((i) => i.title)
          .toList();
      // Dune: Part Two is declared first in FakeMediaRepository.
      expect(titles.first, 'Dune: Part Two');
    });

    test('combining filters narrows further, not either/or', () async {
      final result = await repository.discover(
        DiscoverFilter(
          type: MediaType.movie,
          withGenres: {_comedy},
          minVoteAverage: 7.9,
        ),
      );

      final items = (result as Success<List<MediaItem>>).value;
      expect(
        items.every((i) => i.genres.contains(_comedy) && i.voteAverage >= 7.9),
        isTrue,
      );
      expect(items, isNotEmpty);
    });
  });
}
