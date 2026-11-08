import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/repositories/tmdb_media_repository.dart';
import 'package:movies/core/data/tmdb/tmdb_configuration_service.dart';
import 'package:movies/core/data/tmdb/tmdb_media_datasource.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/repositories/media_repository.dart';
import 'package:movies/core/network/api_client.dart';

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
  late TmdbMediaRepository repository;

  setUp(() {
    final apiClient = ApiClient();
    adapter = _FixtureRoutedAdapter();
    apiClient.dio.httpClientAdapter = adapter;
    final datasource = TmdbMediaDatasource(apiClient);
    final configService = TmdbConfigurationService(apiClient);
    repository = TmdbMediaRepository(datasource, configService);
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
  });

  group('detail', () {
    test('movie key -> /movie/{id} with the right append_to_response',
        () async {
      final result = await repository.detail(
        const MediaKey(type: MediaType.movie, tmdbId: 693134),
      );

      expect(adapter.requestedPaths, ['/movie/693134']);
      expect(adapter.lastQueryParameters?['append_to_response'],
          'credits,videos,similar,release_dates,watch/providers');
      expect(result, isA<Success<MediaDetail>>());
      expect(
        (result as Success<MediaDetail>).value.item.title,
        'Dune: Part Two',
      );
    });

    test('tv key -> /tv/{id} with the right append_to_response', () async {
      final result = await repository.detail(
        const MediaKey(type: MediaType.tvShow, tmdbId: 94997),
      );

      expect(adapter.requestedPaths, ['/tv/94997']);
      expect(adapter.lastQueryParameters?['append_to_response'],
          'credits,videos,similar,content_ratings,watch/providers');
      expect(
        (result as Success<MediaDetail>).value.item.title,
        'Signal Lost',
      );
    });
  });

  group('not yet implemented — the repo compiles, but these throw', () {
    test('searchMulti', () {
      expect(() => repository.searchMulti('x'), throwsUnimplementedError);
    });

    test('discover', () {
      expect(
        () => repository.discover(const DiscoverFilter()),
        throwsUnimplementedError,
      );
    });
  });
}
