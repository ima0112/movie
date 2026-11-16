import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/drift_settings_repository.dart';
import 'package:movies/core/data/repositories/tmdb_media_repository.dart';
import 'package:movies/core/data/tmdb/tmdb_configuration_service.dart';
import 'package:movies/core/data/tmdb/tmdb_media_datasource.dart';
import 'package:movies/core/domain/entities/app_settings.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/discover_page.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/search_result.dart';
import 'package:movies/core/domain/entities/streaming_service.dart';
import 'package:movies/core/domain/entities/season_summary.dart';
import 'package:movies/core/domain/repositories/media_repository.dart';
import 'package:movies/core/domain/repositories/settings_repository.dart';
import 'package:movies/core/network/api_client.dart';
import 'package:movies/core/network/network_status.dart';
import 'package:movies/core/persistence/app_database.dart';

/// Routes each request to one of this app's own fixtures by path, so a
/// single repository test exercises real HTTP + real JSON decoding
/// end-to-end without an actual network call. `/trending/all/week`,
/// `/movie/*`, and `/tv/*` all get a fixture that at least decodes
/// correctly; only `tmdb_movie_now_playing.json`/`tmdb_tv_popular.json`
/// need the specific edge cases the mapper tests already cover in
/// detail — this test is about *routing* (does `inTheaters` really hit
/// `/movie/now_playing`?), not re-proving the mapper itself.
class _FixtureRoutedAdapter implements HttpClientAdapter {
  final List<String> requestedPaths = [];
  Map<String, dynamic>? lastQueryParameters;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestedPaths.add(options.path);
    lastQueryParameters = options.queryParameters;

    final path = options.path;
    final fixture = switch (path) {
      _ when RegExp(r'^/tv/\d+/season/\d+$').hasMatch(path) =>
        'tmdb_season_detail.json',
      _ when RegExp(r'^/tv/\d+$').hasMatch(path) => 'tmdb_tv_detail_full.json',
      _ when RegExp(r'^/movie/\d+$').hasMatch(path) =>
        'tmdb_movie_detail_full.json',
      _ when RegExp(r'^/person/\d+$').hasMatch(path) =>
        'tmdb_person_detail_full.json',
      _ when RegExp(r'^/(movie|tv)/\d+/watch/providers$').hasMatch(path) =>
        'tmdb_title_watch_providers.json',
      '/discover/tv' => 'tmdb_tv_popular.json',
      '/discover/movie' => 'tmdb_movie_now_playing.json',
      '/search/multi' => 'tmdb_trending_all_week.json',
      _ when path.startsWith('/watch/providers') => 'tmdb_watch_providers.json',
      _ when path.startsWith('/tv') || path == '/trending/tv/week' =>
        'tmdb_tv_popular.json',
      '/trending/all/week' => 'tmdb_trending_all_week.json',
      _ => 'tmdb_movie_now_playing.json',
    };

    return ResponseBody.fromString(
      File('test/fixtures/$fixture').readAsStringSync(),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _FixtureRoutedAdapter adapter;
  late TmdbMediaDatasource datasource;
  late TmdbMediaRepository repository;
  late SettingsRepository settingsRepository;

  setUp(() {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    settingsRepository = DriftSettingsRepository(db);
    final apiClient = ApiClient(settingsRepository, NetworkStatus());
    adapter = _FixtureRoutedAdapter();
    apiClient.dio.httpClientAdapter = adapter;
    datasource = TmdbMediaDatasource(apiClient);
    final configService = TmdbConfigurationService(apiClient);
    repository = TmdbMediaRepository(
      datasource,
      configService,
      settingsRepository,
    );
  });

  group('getHeroItems', () {
    test('type: null -> /trending/all/week, movies and TV shows only '
        '(no person entries)', () async {
      final result = await repository.getHeroItems();

      expect(adapter.requestedPaths, ['/trending/all/week']);
      final items = (result as Success<List<MediaItem>>).value;
      expect(items, isNotEmpty);
      expect(items.every((i) => i is Movie || i is TvShow), isTrue);
    });

    test('type: movie -> interleaves all 4 "Movies home" sources', () async {
      final result = await repository.getHeroItems(type: MediaType.movie);

      expect(
        adapter.requestedPaths,
        unorderedEquals([
          '/movie/now_playing',
          '/trending/movie/week',
          '/movie/top_rated',
          '/movie/upcoming',
        ]),
      );
      final items = (result as Success<List<MediaItem>>).value;
      expect(items, isNotEmpty);
      expect(items.length, lessThanOrEqualTo(8));
    });
  });

  group('getCarouselSection', () {
    test('inTheaters -> only /movie/now_playing', () async {
      final result = await repository.getCarouselSection(
        CarouselSection.inTheaters,
        type: MediaType.movie,
      );

      expect(adapter.requestedPaths, ['/movie/now_playing']);
      expect(result, isA<Success<List<MediaItem>>>());
    });

    test('topRated with type: tvShow -> only /tv/top_rated', () async {
      final result = await repository.getCarouselSection(
        CarouselSection.topRated,
        type: MediaType.tvShow,
      );

      expect(adapter.requestedPaths, ['/tv/top_rated']);
      expect(result, isA<Success<List<MediaItem>>>());
    });

    test('watchLater -> an empty success, no request at all (no TMDB '
        'endpoint hydrates this yet)', () async {
      final result = await repository.getCarouselSection(
        CarouselSection.watchLater,
      );

      expect(adapter.requestedPaths, isEmpty);
      expect((result as Success<List<MediaItem>>).value, isEmpty);
    });

    test(
      'recommendationsFor a movie seed hits /movie/{id}/recommendations',
      () async {
        final result = await repository.recommendationsFor(
          const MediaKey(type: MediaType.movie, tmdbId: 42),
        );

        expect(adapter.requestedPaths, ['/movie/42/recommendations']);
        expect(result, isA<Success<List<MediaItem>>>());
      },
    );

    test(
      'recommendationsFor a TV seed hits /tv/{id}/recommendations',
      () async {
        final result = await repository.recommendationsFor(
          const MediaKey(type: MediaType.tvShow, tmdbId: 7),
        );

        expect(adapter.requestedPaths, ['/tv/7/recommendations']);
        expect(result, isA<Success<List<MediaItem>>>());
      },
    );

    test(
      'trending/topRated with type: null -> an empty success, not a '
      'thrown UnimplementedError (neither section has an "All" segment '
      'equivalent, but this never actually happens via DiscoverCubit)',
      () async {
        final trending = await repository.getCarouselSection(
          CarouselSection.trending,
        );
        final topRated = await repository.getCarouselSection(
          CarouselSection.topRated,
        );

        expect(adapter.requestedPaths, isEmpty);
        expect((trending as Success<List<MediaItem>>).value, isEmpty);
        expect((topRated as Success<List<MediaItem>>).value, isEmpty);
      },
    );
  });

  group('detail', () {
    test(
      'movie key -> /movie/{id} with the right append_to_response',
      () async {
        final result = await repository.detail(
          const MediaKey(type: MediaType.movie, tmdbId: 693134),
        );

        expect(adapter.requestedPaths, ['/movie/693134']);
        expect(
          adapter.lastQueryParameters?['append_to_response'],
          'credits,videos,similar,release_dates,watch/providers',
        );
        expect(result, isA<Success<MediaDetail>>());
        expect(
          (result as Success<MediaDetail>).value.item.title,
          'Dune: Part Two',
        );
      },
    );

    test('tv key -> /tv/{id} with the right append_to_response', () async {
      final result = await repository.detail(
        const MediaKey(type: MediaType.tvShow, tmdbId: 94997),
      );

      expect(adapter.requestedPaths, ['/tv/94997']);
      expect(
        adapter.lastQueryParameters?['append_to_response'],
        'credits,aggregate_credits,videos,similar,content_ratings,watch/providers',
      );
      expect((result as Success<MediaDetail>).value.item.title, 'Signal Lost');
    });

    test('a SettingsRepository region change changes a fresh detail call\'s '
        '"Where to watch" data — the fixture only has providers for Spain, '
        'so switching to a region with none makes hasAny false', () async {
      await settingsRepository.save(
        const AppSettings(languageCode: 'en', regionCode: 'ES'),
      );
      final beforeResult = await repository.detail(
        const MediaKey(type: MediaType.movie, tmdbId: 693134),
      );
      expect(
        (beforeResult as Success<MediaDetail>).value.watchProviders.hasAny,
        isTrue,
      );

      await settingsRepository.save(
        const AppSettings(languageCode: 'en', regionCode: 'FR'),
      );

      final afterResult = await repository.detail(
        const MediaKey(type: MediaType.movie, tmdbId: 693134),
      );
      expect(
        (afterResult as Success<MediaDetail>).value.watchProviders.hasAny,
        isFalse,
      );
    });

    test('a regionCode override applies to that one call only, leaving the '
        'saved region as it was', () async {
      await settingsRepository.save(
        const AppSettings(languageCode: 'en', regionCode: 'ES'),
      );
      const key = MediaKey(type: MediaType.movie, tmdbId: 693134);

      final overridden = await repository.detail(key, regionCode: 'FR');
      expect(
        (overridden as Success<MediaDetail>).value.watchProviders.hasAny,
        isFalse,
      );

      final saved = await repository.detail(key);
      expect(
        (saved as Success<MediaDetail>).value.watchProviders.hasAny,
        isTrue,
      );
      expect(settingsRepository.current.regionCode, 'ES');
    });
  });

  group('season', () {
    test('-> /tv/{tvId}/season/{n}', () async {
      final result = await repository.season(94997, 1);

      expect(adapter.requestedPaths, ['/tv/94997/season/1']);
      expect(result, isA<Success<SeasonDetail>>());
      final season = (result as Success<SeasonDetail>).value;
      expect(season.name, 'Season 1');
      expect(season.overview, isNotEmpty);
      expect(season.episodes, hasLength(2));
    });
  });

  group('searchMulti', () {
    test('a blank query -> an empty success, no request at all', () async {
      final result = await repository.searchMulti('   ');

      expect(adapter.requestedPaths, isEmpty);
      expect((result as Success<List<SearchResult>>).value, isEmpty);
    });

    test('hits /search/multi and keeps people alongside titles', () async {
      final result = await repository.searchMulti('dune');

      expect(adapter.requestedPaths, ['/search/multi']);
      expect(adapter.lastQueryParameters?['query'], 'dune');
      final results = (result as Success<List<SearchResult>>).value;
      final titles = results.whereType<MediaResult>().map((r) => r.item);
      final people = results.whereType<PersonResult>().map((r) => r.person);
      expect(titles, isNotEmpty);
      expect(titles.every((i) => i is Movie || i is TvShow), isTrue);
      // The fixture's "person" entry now comes through, with its fields.
      final jordan = people.singleWhere((p) => p.id == 301);
      expect(jordan.name, 'Jordan Ashworth');
      expect(jordan.profilePath, '/jordan-ashworth.jpg');
      expect(jordan.knownForDepartment, 'Acting');
    });
  });

  group('streamingServices', () {
    test('movies -> /watch/providers/movie with the region, most relevant '
        'first, with logo URLs', () async {
      await settingsRepository.save(
        const AppSettings(languageCode: 'en', regionCode: 'ES'),
      );
      final result = await repository.streamingServices(type: MediaType.movie);

      expect(adapter.requestedPaths, ['/watch/providers/movie']);
      expect(adapter.lastQueryParameters?['watch_region'], 'ES');
      final services = (result as Success<List<StreamingService>>).value;
      expect(services.map((s) => s.name), [
        'Netflix',
        'Amazon Prime Video',
        'Disney Plus',
        'Obscure',
      ]);
      expect(services.first.id, 8);
      expect(services.first.logoUrl, endsWith('/netflix.jpg'));
      expect(services[2].logoUrl, isNull);
    });

    test('All -> both types, merged without repeats', () async {
      final result = await repository.streamingServices();

      expect(adapter.requestedPaths, [
        '/watch/providers/movie',
        '/watch/providers/tv',
      ]);
      final services = (result as Success<List<StreamingService>>).value;
      expect(services.map((s) => s.id).toSet(), hasLength(services.length));
    });

    test('discover sends the provider filter with the saved region', () async {
      await settingsRepository.save(
        const AppSettings(languageCode: 'en', regionCode: 'ES'),
      );
      await repository.discover(
        const DiscoverFilter(type: MediaType.movie, withWatchProviders: {8}),
      );
      expect(adapter.lastQueryParameters?['with_watch_providers'], '8');
      expect(adapter.lastQueryParameters?['watch_region'], 'ES');
    });
  });

  group('streamingProvidersFor', () {
    test('a title\'s subscription services in the saved region, with logos, '
        'and not its rent/buy ones', () async {
      final result = await repository.streamingProvidersFor(
        const MediaKey(type: MediaType.movie, tmdbId: 603),
      );

      expect(adapter.requestedPaths, ['/movie/603/watch/providers']);
      final services = (result as Success<List<StreamingService>>).value;
      expect(services.map((s) => s.name), ['Netflix', 'Hulu']);
      expect(services.first.id, 8);
      expect(services.first.logoUrl, endsWith('/w92/netflix.jpg'));
      expect(services.last.logoUrl, isNull);
    });

    test('a TV show goes through /tv; a region with no subscription service '
        'is an empty list', () async {
      await settingsRepository.save(
        const AppSettings(languageCode: 'es', regionCode: 'ES'),
      );
      final result = await repository.streamingProvidersFor(
        const MediaKey(type: MediaType.tvShow, tmdbId: 1),
      );

      expect(adapter.requestedPaths, ['/tv/1/watch/providers']);
      expect((result as Success<List<StreamingService>>).value, isEmpty);
    });
  });

  group('pages', () {
    test('discoverPage sends the page number and returns the totals', () async {
      final result = await repository.discoverPage(
        const DiscoverFilter(type: MediaType.movie),
        page: 3,
      );

      expect(adapter.requestedPaths, ['/discover/movie']);
      expect(adapter.lastQueryParameters!['page'], 3);
      final page = (result as Success<DiscoverPage>).value;
      expect(page.items, isNotEmpty);
      expect(page.totalPages, 42); // from the fixture
      expect(page.totalResults, greaterThan(0));
      expect(page.hasMore, isTrue);
    });

    test('All merges both types for the same page', () async {
      final result = await repository.discoverPage(
        const DiscoverFilter(),
        page: 2,
      );
      final page = (result as Success<DiscoverPage>).value;
      expect(
        adapter.requestedPaths,
        containsAll(['/discover/movie', '/discover/tv']),
      );
      expect(page.page, 2);
      expect(page.items.any((i) => i is Movie), isTrue);
      expect(page.items.any((i) => i is TvShow), isTrue);
    });

    test("a collection's page uses its own endpoint with the page", () async {
      final result = await repository.carouselSectionPage(
        CarouselSection.inTheaters,
        page: 2,
      );
      expect(adapter.requestedPaths, ['/movie/now_playing']);
      expect(adapter.lastQueryParameters!['page'], 2);
      expect(result, isA<Success<DiscoverPage>>());
    });

    test('Finished shows pages through /discover/tv; Watch later is empty '
        'with no request', () async {
      await repository.carouselSectionPage(
        CarouselSection.finishedShows,
        page: 2,
      );
      expect(adapter.requestedPaths, ['/discover/tv']);
      expect(adapter.lastQueryParameters!['with_status'], '3');

      adapter.requestedPaths.clear();
      final none = await repository.carouselSectionPage(
        CarouselSection.watchLater,
      );
      expect(adapter.requestedPaths, isEmpty);
      expect((none as Success<DiscoverPage>).value.items, isEmpty);
    });
  });

  group('discover', () {
    test('type: movie -> only /discover/movie', () async {
      final result = await repository.discover(
        const DiscoverFilter(type: MediaType.movie),
      );

      expect(adapter.requestedPaths, ['/discover/movie']);
      expect(result, isA<Success<List<MediaItem>>>());
    });

    test('type: tvShow -> only /discover/tv', () async {
      final result = await repository.discover(
        const DiscoverFilter(type: MediaType.tvShow),
      );

      expect(adapter.requestedPaths, ['/discover/tv']);
      expect(result, isA<Success<List<MediaItem>>>());
    });

    test('type: null -> both /discover/movie and /discover/tv, '
        'interleaved', () async {
      final result = await repository.discover(const DiscoverFilter());

      expect(
        adapter.requestedPaths,
        containsAll(['/discover/movie', '/discover/tv']),
      );
      final items = (result as Success<List<MediaItem>>).value;
      expect(items.any((i) => i is Movie), isTrue);
      expect(items.any((i) => i is TvShow), isTrue);
    });
  });

  group('person detail', () {
    test('/person/{id} with the right append_to_response', () async {
      final dto = await datasource.personDetail(287);

      expect(adapter.requestedPaths, ['/person/287']);
      expect(
        adapter.lastQueryParameters?['append_to_response'],
        'movie_credits,tv_credits',
      );
      expect(dto.name, isNotEmpty);
    });
  });
}
