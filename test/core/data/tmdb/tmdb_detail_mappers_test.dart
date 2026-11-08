import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/tmdb/dtos/tmdb_movie_detail_dto.dart';
import 'package:movies/core/data/tmdb/dtos/tmdb_season_detail_dto.dart';
import 'package:movies/core/data/tmdb/dtos/tmdb_tv_detail_dto.dart';
import 'package:movies/core/data/tmdb/tmdb_detail_mappers.dart';
import 'package:movies/core/data/tmdb/tmdb_image_urls.dart';
import 'package:movies/core/domain/entities/media_detail.dart';

Map<String, dynamic> _loadFixture(String name) =>
    jsonDecode(File('test/fixtures/$name').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  const imagesConfig = TmdbImagesConfig.fallback();

  group('mediaDetailFromMovieDto', () {
    MovieDetail load(String fixture, {String region = 'ES'}) {
      final dto = TmdbMovieDetailDto.fromJson(_loadFixture(fixture));
      return mediaDetailFromMovieDto(
        dto,
        imagesConfig: imagesConfig,
        region: region,
      );
    }

    test('maps title, overview, runtime, release date, tagline, imdbId', () {
      final detail = load('tmdb_movie_detail_full.json');

      expect(detail.item.title, 'Dune: Part Two');
      expect(detail.overview, 'Paul Atreides unites with Chani and the Fremen.');
      expect(detail.runtimeMinutes, 166);
      expect(detail.releaseDate, DateTime(2024, 3, 1));
      expect(detail.tagline, 'Long live the fighters.');
      expect(detail.imdbId, 'tt15239678');
    });

    test('maps cast and crew into Person-wrapping value objects', () {
      final detail = load('tmdb_movie_detail_full.json');

      expect(detail.cast, hasLength(2));
      expect(detail.cast.first.person.name, 'Timothée Chalamet');
      expect(detail.cast.first.character, 'Paul Atreides');
      expect(detail.crew.single.person.name, 'Denis Villeneuve');
      expect(detail.crew.single.job, 'Director');
    });

    test('maps similar via the same list-item mapper Discover uses', () {
      final detail = load('tmdb_movie_detail_full.json');

      expect(detail.similar.single.title, 'John Wick: Chapter 4');
    });

    test(
      'trailer selection: official + Trailer + user\'s language (es) wins '
      'over an official-but-English Trailer and an official-but-English '
      'Teaser',
      () {
        final detail = load('tmdb_movie_detail_full.json');

        expect(detail.trailer?.key, 'es-trailer');
      },
    );

    test('certification picks the region\'s own first non-empty value, '
        'skipping an empty one that came first', () {
      final detail = load('tmdb_movie_detail_full.json');

      expect(detail.certification, '12');
    });

    test('watch providers for the requested region', () {
      final detail = load('tmdb_movie_detail_full.json');

      expect(detail.watchProviders.flatrate, ['Movistar Plus+']);
      expect(detail.watchProviders.rent, ['Apple TV']);
      expect(
        detail.watchProviders.link,
        'https://www.themoviedb.org/movie/693134-dune-part-two/watch?locale=ES',
      );
    });

    test('a movie with no trailer at all -> trailer is null, not a crash', () {
      final detail = load('tmdb_movie_detail_no_trailer.json');

      expect(detail.trailer, isNull);
      expect(detail.cast, isEmpty);
      expect(detail.item.posterUrl, isNull);
      expect(detail.tagline, isNull);
      expect(detail.certification, isNull);
    });

    test(
      'a movie with providers for other regions but not the user\'s -> '
      'watchProviders.hasAny is false, not those other regions\' data',
      () {
        final detail = load(
          'tmdb_movie_detail_no_region_providers.json',
          region: 'ES',
        );

        expect(detail.watchProviders.hasAny, isFalse);
        expect(detail.certification, isNull);
      },
    );

    test('the same movie DOES have providers for the region they were '
        'actually released in', () {
      final detail = load(
        'tmdb_movie_detail_no_region_providers.json',
        region: 'US',
      );

      expect(detail.watchProviders.flatrate, ['Disney Plus']);
      expect(detail.certification, 'PG');
    });

    test('Fantasy (14, no catalog equivalent) is dropped; Family (10751) '
        'is kept', () {
      final detail = load('tmdb_movie_detail_no_region_providers.json');

      expect(detail.item.genres.map((g) => g.id), ['family']);
    });
  });

  group('mediaDetailFromTvDto', () {
    TvShowDetail load() {
      final dto = TmdbTvDetailDto.fromJson(
        _loadFixture('tmdb_tv_detail_full.json'),
      );
      return mediaDetailFromTvDto(
        dto,
        imagesConfig: imagesConfig,
        region: 'ES',
      );
    }

    test('maps name into title, first/last air date, episode runtime', () {
      final detail = load();

      expect(detail.item.title, 'Signal Lost');
      expect(detail.firstAirDate, DateTime(2024, 9, 12));
      expect(detail.lastAirDate, DateTime(2026, 2, 1));
      expect(detail.episodeRuntimeMinutes, 52);
      expect(detail.numberOfEpisodes, 24);
      expect(detail.inProduction, isTrue);
    });

    test('TV\'s merged "Action & Adventure" (10759) maps to "action"', () {
      final detail = load();

      expect(detail.item.genres.map((g) => g.id), contains('action'));
    });

    test('maps created_by into creators', () {
      final detail = load();

      expect(detail.creators.single.name, 'Jamie Costa');
    });

    test('maps the embedded seasons summary', () {
      final detail = load();

      expect(detail.seasons, hasLength(2));
      expect(detail.seasons.first.seasonNumber, 1);
      expect(detail.seasons.last.episodeCount, 12);
    });

    test('certification comes from content_ratings, not release_dates', () {
      final detail = load();

      expect(detail.certification, '16');
    });

    test('watch providers for the requested region', () {
      final detail = load();

      expect(detail.watchProviders.flatrate, ['Netflix']);
    });
  });

  group('episodesFromSeasonDetail', () {
    test('maps every episode, including one with no overview, still, air '
        'date, or runtime', () {
      final dto = TmdbSeasonDetailDto.fromJson(
        _loadFixture('tmdb_season_detail.json'),
      );
      final episodes = episodesFromSeasonDetail(dto);

      expect(episodes, hasLength(2));

      final first = episodes.first;
      expect(first.name, 'Silence');
      expect(first.runtimeMinutes, 54);
      expect(first.airDate, DateTime(2024, 9, 12));

      final second = episodes.last;
      expect(second.name, 'Depth');
      expect(second.overview, isEmpty);
      expect(second.stillPath, isNull);
      expect(second.airDate, isNull);
      expect(second.runtimeMinutes, isNull);
    });
  });
}
