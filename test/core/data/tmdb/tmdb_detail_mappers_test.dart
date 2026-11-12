import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/tmdb/dtos/tmdb_movie_detail_dto.dart';
import 'package:movies/core/data/tmdb/dtos/tmdb_season_detail_dto.dart';
import 'package:movies/core/data/tmdb/dtos/tmdb_tv_detail_dto.dart';
import 'package:movies/core/data/tmdb/tmdb_detail_mappers.dart';
import 'package:movies/core/data/tmdb/tmdb_image_urls.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/release_status.dart';

Map<String, dynamic> _loadFixture(String name) =>
    jsonDecode(File('test/fixtures/$name').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  const imagesConfig = TmdbImagesConfig.fallback();

  group('release status', () {
    final today = DateTime(2026, 5, 10);

    MovieDetail movie(
      List<Map<String, dynamic>> entries, {
      String status = 'Released',
      String region = 'US',
    }) {
      final json = _loadFixture('tmdb_movie_detail_full.json');
      json['status'] = status;
      json['release_dates'] = {
        'results': [
          {'iso_3166_1': region, 'release_dates': entries},
          // Another region's dates must never leak in.
          {
            'iso_3166_1': 'FR',
            'release_dates': [
              {
                'certification': '',
                'type': 4,
                'release_date': '2020-01-01T00:00:00.000Z',
              },
            ],
          },
        ],
      };
      return mediaDetailFromMovieDto(
        TmdbMovieDetailDto.fromJson(json),
        imagesConfig: imagesConfig,
        region: region,
        today: today,
      );
    }

    test('a cinema date ahead is upcoming, read as written (no timezone '
        'shift)', () {
      final detail = movie([
        {
          'certification': '',
          'type': 3,
          'release_date': '2026-06-12T00:00:00.000Z',
        },
      ], status: 'Post Production');
      expect(detail.releaseStatus?.stage, ReleaseStage.upcoming);
      expect(detail.releaseStatus?.date, DateTime(2026, 6, 12));
    });

    test('in cinemas now, with the digital date when TMDB has it', () {
      final detail = movie([
        {
          'certification': 'PG',
          'type': 3,
          'release_date': '2026-04-30T00:00:00.000Z',
        },
        {
          'certification': '',
          'type': 4,
          'release_date': '2026-06-25T00:00:00.000Z',
        },
      ]);
      expect(detail.releaseStatus?.stage, ReleaseStage.inTheaters);
      expect(detail.releaseStatus?.streamingDate, DateTime(2026, 6, 25));
    });

    test('an ordinary released movie has no status, and a TV show with a '
        'future first episode is upcoming', () {
      expect(
        movie([
          {
            'certification': 'PG',
            'type': 4,
            'release_date': '2020-01-01T00:00:00.000Z',
          },
        ]).releaseStatus,
        isNull,
      );

      final tvJson = _loadFixture('tmdb_tv_detail_full.json');
      tvJson['first_air_date'] = '2026-09-01';
      tvJson['status'] = 'Planned';
      final tv = mediaDetailFromTvDto(
        TmdbTvDetailDto.fromJson(tvJson),
        imagesConfig: imagesConfig,
        region: 'US',
        today: today,
      );
      expect(tv.releaseStatus?.stage, ReleaseStage.upcoming);
      expect(tv.releaseStatus?.date, DateTime(2026, 9, 1));
    });
  });

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
      expect(
        detail.overview,
        'Paul Atreides unites with Chani and the Fremen.',
      );
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

    test('carries each cast member\'s raw profile_path through as-is — '
        'some have a photo, some (like Zendaya here) don\'t', () {
      final detail = load('tmdb_movie_detail_full.json');

      final chalamet = detail.cast.firstWhere(
        (c) => c.person.name == 'Timothée Chalamet',
      );
      expect(chalamet.person.profilePath, '/chalamet.jpg');

      final zendaya = detail.cast.firstWhere((c) => c.person.name == 'Zendaya');
      expect(zendaya.person.profilePath, isNull);
    });

    test('maps similar via the same list-item mapper Discover uses', () {
      final detail = load('tmdb_movie_detail_full.json');

      expect(detail.similar.single.title, 'John Wick: Chapter 4');
    });

    test('trailer selection: official + Trailer + user\'s language (en) wins '
        'over an official-but-Spanish Trailer and an official-but-English '
        'Teaser', () {
      final detail = load('tmdb_movie_detail_full.json');

      expect(detail.trailer?.key, 'en-trailer');
    });

    test('trailer selection: official wins over a non-official Teaser when '
        'nothing official matches the user\'s language', () {
      final detail = load(
        'tmdb_movie_detail_trailer_official_non_user_lang.json',
      );

      expect(detail.trailer?.key, 'fr-trailer');
    });

    test('trailer selection: a Teaser wins when nothing is official', () {
      final detail = load('tmdb_movie_detail_trailer_teaser_only.json');

      expect(detail.trailer?.key, 'clip-teaser');
    });

    test('trailer selection: falls back to the first available video when '
        'nothing is official or a Teaser', () {
      final detail = load('tmdb_movie_detail_trailer_fallback_only.json');

      expect(detail.trailer?.key, 'first-clip');
    });

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

    test(
      'maps each provider logo_path to a w92 logo URL, by provider name',
      () {
        final detail = load('tmdb_movie_detail_full.json');

        expect(detail.watchProviders.logos, {
          'Movistar Plus+': 'https://image.tmdb.org/t/p/w92/movistar.png',
          'Apple TV': 'https://image.tmdb.org/t/p/w92/apple.png',
        });
      },
    );

    test('maps original_language and production country codes', () {
      final detail = load('tmdb_movie_detail_full.json');

      expect(detail.originalLanguage, 'en');
      expect(detail.countryCodes, ['US', 'GB']);
    });

    test('maps backdrop_path to a w780 backdrop URL', () {
      final detail = load('tmdb_movie_detail_full.json');

      expect(
        detail.backdropUrl,
        'https://image.tmdb.org/t/p/w780/backdrop-dune.jpg',
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

    test('a movie with providers for other regions but not the user\'s -> '
        'watchProviders.hasAny is false, not those other regions\' data', () {
      final detail = load(
        'tmdb_movie_detail_no_region_providers.json',
        region: 'ES',
      );

      expect(detail.watchProviders.hasAny, isFalse);
      expect(detail.certification, isNull);
    });

    test('the same movie DOES have providers for the region they were '
        'actually released in', () {
      final detail = load(
        'tmdb_movie_detail_no_region_providers.json',
        region: 'US',
      );

      expect(detail.watchProviders.flatrate, ['Disney Plus']);
      expect(detail.certification, 'PG');
    });

    test('Fantasy (14) and Family (10751) both map — Fantasy has had a '
        'catalog equivalent since the vibe-keywords-curated branch', () {
      final detail = load('tmdb_movie_detail_no_region_providers.json');

      expect(detail.item.genres.map((g) => g.id), ['fantasy', 'family']);
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

    test('maps each season summary\'s vote_average; none -> null', () {
      final seasons = load().seasons;

      expect(seasons.first.voteAverage, 8.7);
      expect(seasons.last.voteAverage, isNull);
    });

    test('maps last_episode_to_air and next_episode_to_air; a 0 rating is '
        'null', () {
      final detail = load();

      final last = detail.lastEpisode!;
      expect(last.seasonNumber, 2);
      expect(last.episodeNumber, 5);
      expect(last.name, 'Static');
      expect(last.airDate, DateTime(2025, 10, 16));
      expect(last.stillPath, '/static.jpg');
      expect(last.voteAverage, 8.9);

      final next = detail.nextEpisode!;
      expect(next.name, 'Reboot');
      expect(next.stillPath, isNull);
      expect(next.voteAverage, isNull);
    });

    test('a show with no last/next episode maps both to null', () {
      final json = _loadFixture('tmdb_tv_detail_full.json')
        ..['last_episode_to_air'] = null
        ..['next_episode_to_air'] = null;
      final detail = mediaDetailFromTvDto(
        TmdbTvDetailDto.fromJson(json),
        imagesConfig: imagesConfig,
        region: 'ES',
      );

      expect(detail.lastEpisode, isNull);
      expect(detail.nextEpisode, isNull);
    });

    Map<String, dynamic> aggregate({int castCount = 150}) => {
      'cast': [
        for (var i = castCount - 1; i >= 0; i--)
          {
            'id': 1000 + i,
            'name': 'Actor $i',
            'profile_path': null,
            'known_for_department': 'Acting',
            'order': i,
            'roles': [
              {'character': 'Minor', 'episode_count': 1},
              {'character': 'Main $i', 'episode_count': 50},
            ],
          },
      ],
      'crew': [
        {
          'id': 5,
          'name': 'Showrunner',
          'profile_path': null,
          'known_for_department': 'Writing',
          'department': 'Production',
          'jobs': [
            {'job': 'Writer', 'episode_count': 3},
            {'job': 'Executive Producer', 'episode_count': 90},
          ],
        },
      ],
    };

    test('uses the whole run\'s aggregate_credits: first 100 by order, the '
        'most-played character, the most-held job', () {
      final json = _loadFixture('tmdb_tv_detail_full.json')
        ..['aggregate_credits'] = aggregate();
      final detail = mediaDetailFromTvDto(
        TmdbTvDetailDto.fromJson(json),
        imagesConfig: imagesConfig,
        region: 'ES',
      );

      expect(detail.cast, hasLength(100));
      expect(detail.cast.first.person.name, 'Actor 0');
      expect(detail.cast.first.character, 'Main 0');
      expect(detail.cast.last.person.name, 'Actor 99');
      expect(detail.crew.single.job, 'Executive Producer');
      expect(detail.crew.single.department, 'Production');
    });

    test('with no aggregate_credits it falls back to the latest season\'s '
        'credits', () {
      final json = _loadFixture('tmdb_tv_detail_full.json')
        ..remove('aggregate_credits');
      final detail = mediaDetailFromTvDto(
        TmdbTvDetailDto.fromJson(json),
        imagesConfig: imagesConfig,
        region: 'ES',
      );
      final dto = TmdbTvDetailDto.fromJson(json);

      expect(detail.cast, hasLength(dto.credits.cast.length));
    });

    test('maps original_language and origin_country', () {
      final detail = load();

      expect(detail.originalLanguage, 'en');
      expect(detail.countryCodes, ['US']);
    });

    test('maps backdrop_path to a w780 backdrop URL', () {
      expect(
        load().backdropUrl,
        'https://image.tmdb.org/t/p/w780/tv-backdrop.jpg',
      );
    });

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

    test('maps vote_average and guest_stars; a missing rating is null, no '
        'guests is empty', () {
      final dto = TmdbSeasonDetailDto.fromJson(
        _loadFixture('tmdb_season_detail.json'),
      );
      final episodes = episodesFromSeasonDetail(dto);

      expect(episodes.first.voteAverage, 8.5);
      expect(episodes.first.guestStars, hasLength(1));
      final guest = episodes.first.guestStars.single;
      expect(guest.person.id, 11);
      expect(guest.person.name, 'Ana Soto');
      expect(guest.person.profilePath, '/ana.jpg');
      expect(guest.character, 'Dr. Vega');

      expect(episodes.last.voteAverage, isNull);
      expect(episodes.last.guestStars, isEmpty);
    });
  });

  group('seasonDetailFromDto', () {
    test('carries the season-level name/overview alongside its episodes', () {
      final dto = TmdbSeasonDetailDto.fromJson(
        _loadFixture('tmdb_season_detail.json'),
      );
      final season = seasonDetailFromDto(dto);

      expect(season.seasonNumber, 1);
      expect(season.name, 'Season 1');
      expect(season.overview, isNotEmpty);
      expect(season.episodes, hasLength(2));
    });
  });
}
