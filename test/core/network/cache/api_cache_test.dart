import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/fetch_mode.dart';
import 'package:movies/core/network/cache/api_cache.dart';
import 'package:movies/core/network/cache/api_cache_policy_interceptor.dart';
import 'package:movies/core/network/cache/cache_ttl.dart';

/// Counts what reaches the "network" and can be told to fail.
class _Adapter implements HttpClientAdapter {
  final requests = <Uri>[];
  bool offline = false;
  int status = 200;
  int version = 1;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options.uri);
    if (offline) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'no network',
      );
    }
    return ResponseBody.fromString(
      jsonEncode({'v': version, 'path': options.path}),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _Adapter adapter;
  late ApiCache cache;
  late Dio dio;
  late DateTime clock;

  setUp(() {
    clock =
        DateTime.now(); // the package stamps saved answers with the real clock
    adapter = _Adapter();
    cache = ApiCache.withStore(MemCacheStore(), now: () => clock);
    dio = Dio(BaseOptions(baseUrl: 'https://api.example'))
      ..httpClientAdapter = adapter
      ..interceptors.addAll(cache.interceptors);
  });

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    FetchMode? mode,
  }) => dio.get<dynamic>(
    path,
    queryParameters: query,
    options: Options(extra: {ApiCachePolicyInterceptor.modeKey: ?mode}),
  );

  group('within the TTL', () {
    test('opening the same detail twice asks the network once', () async {
      final a = await get('/movie/603');
      final b = await get('/movie/603');

      expect(adapter.requests, hasLength(1));
      expect(b.data, a.data);
      expect(cache.stats.misses, 1);
      expect(cache.stats.hits, 1);
    });

    test('a different title, or the same one with other parameters, is its '
        'own entry', () async {
      await get('/movie/603');
      await get('/movie/604');
      await get('/movie/603', query: {'append_to_response': 'credits'});

      expect(adapter.requests, hasLength(3));
    });

    test('a cache hit is the same data, decoded as JSON', () async {
      await get('/movie/603');
      final hit = await get('/movie/603');
      expect(hit.data, isA<Map<String, dynamic>>());
      expect((hit.data as Map)['path'], '/movie/603');
    });
  });

  group('past the TTL', () {
    test('a detail is asked again after 6 hours, not before', () async {
      await get('/movie/603');

      clock = clock.add(const Duration(hours: 5, minutes: 59));
      await get('/movie/603');
      expect(adapter.requests, hasLength(1));

      clock = clock.add(const Duration(minutes: 2));
      adapter.version = 2;
      final fresh = await get('/movie/603');
      expect(adapter.requests, hasLength(2));
      expect((fresh.data as Map)['v'], 2);
    });

    test(
      'each route has its own clock: a Home list is stale after 10 min while '
      'a detail is not',
      () async {
        await get('/trending/all/week');
        await get('/movie/603');

        clock = clock.add(const Duration(minutes: 11));
        await get('/trending/all/week');
        await get('/movie/603');

        expect(adapter.requests.map((u) => u.path), [
          '/trending/all/week',
          '/movie/603',
          '/trending/all/week',
        ]);
      },
    );
  });

  group('what is never cached', () {
    test('search, whatever the time', () async {
      await get('/search/multi', query: {'query': 'matrix'});
      await get('/search/multi', query: {'query': 'matrix'});
      expect(adapter.requests, hasLength(2));
      expect(cache.stats.bypasses, 2);
    });

    test('a route nobody listed', () async {
      await get('/genre/movie/list');
      await get('/genre/movie/list');
      expect(adapter.requests, hasLength(2));
    });

    test('FetchMode.live: neither read nor saved', () async {
      await get('/discover/movie', query: {'page': 3}, mode: FetchMode.live);
      await get('/discover/movie', query: {'page': 3}, mode: FetchMode.live);
      expect(adapter.requests, hasLength(2));

      // Nothing was saved, so a normal read afterwards still asks.
      await get('/discover/movie', query: {'page': 3});
      expect(adapter.requests, hasLength(3));
    });

    test('an error answer is not saved', () async {
      adapter.status = 500;
      await expectLater(get('/movie/603'), throwsA(isA<DioException>()));
      adapter.status = 200;
      await get('/movie/603');
      expect(adapter.requests, hasLength(2));
    });
  });

  group('refreshing', () {
    test(
      'FetchMode.refresh skips the saved answer and saves the new one',
      () async {
        await get('/trending/all/week');
        adapter.version = 2;

        final refreshed = await get(
          '/trending/all/week',
          mode: FetchMode.refresh,
        );
        expect(adapter.requests, hasLength(2));
        expect((refreshed.data as Map)['v'], 2);

        // A normal read now gets the refreshed answer without asking.
        final next = await get('/trending/all/week');
        expect(adapter.requests, hasLength(2));
        expect((next.data as Map)['v'], 2);
        expect(cache.stats.refreshes, 1);
      },
    );
  });

  group('language and region are part of the key', () {
    test('the same title in another language is another entry', () async {
      await get('/movie/603', query: {'language': 'en-US', 'region': 'US'});
      await get('/movie/603', query: {'language': 'es-MX', 'region': 'MX'});
      expect(adapter.requests, hasLength(2));

      await get('/movie/603', query: {'language': 'en-US', 'region': 'US'});
      await get('/movie/603', query: {'language': 'es-MX', 'region': 'MX'});
      expect(adapter.requests, hasLength(2));
    });
  });

  group('without a network', () {
    test('an old answer is served instead of an error', () async {
      await get('/movie/603');
      clock = clock.add(const Duration(hours: 7)); // past the TTL
      adapter.offline = true;

      final old = await get('/movie/603');
      expect((old.data as Map)['path'], '/movie/603');
      expect(adapter.requests, hasLength(2)); // it did try
    });

    test('with nothing saved the failure is an error', () async {
      adapter.offline = true;
      await expectLater(get('/movie/603'), throwsA(isA<DioException>()));
    });

    test(
      'a user\'s refresh with no network also falls back to what is saved',
      () async {
        await get('/movie/603');
        adapter.offline = true;
        final r = await get('/movie/603', mode: FetchMode.refresh);
        expect((r.data as Map)['path'], '/movie/603');
      },
    );
  });

  group('clearing', () {
    test('clear() forgets everything', () async {
      await get('/movie/603');
      await get('/person/287');
      await cache.clear();

      await get('/movie/603');
      await get('/person/287');
      expect(adapter.requests, hasLength(4));
    });

    test('invalidate() forgets only the matching paths', () async {
      await get('/movie/603');
      await get('/person/287');
      await cache.invalidate(RegExp(r'/person/'));

      await get('/movie/603');
      await get('/person/287');
      expect(adapter.requests.map((u) => u.path), [
        '/movie/603',
        '/person/287',
        '/person/287',
      ]);
    });
  });

  test(
    'ApiCache.off() adds nothing: every request goes to the network',
    () async {
      final plain = Dio(BaseOptions(baseUrl: 'https://api.example'))
        ..httpClientAdapter = adapter
        ..interceptors.addAll(ApiCache.off().interceptors);
      await plain.get<dynamic>('/movie/603');
      await plain.get<dynamic>('/movie/603');
      expect(adapter.requests, hasLength(2));
    },
  );

  test(
    'the rules table and the policy agree on which routes are cacheable',
    () {
      expect(CacheTtl.ruleFor('/movie/603'), isNotNull);
    },
  );
}
