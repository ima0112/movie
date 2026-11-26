import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/fetch_mode.dart';
import 'package:movies/core/network/cache/api_cache.dart';
import 'package:movies/core/network/cache/api_cache_policy_interceptor.dart';

class _Adapter implements HttpClientAdapter {
  final requests = <Uri>[];
  bool offline = false;
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
      jsonEncode({'v': version}),
      200,
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
    // The package stamps saved answers with the real clock.
    clock = DateTime.now();
    adapter = _Adapter();
    cache = ApiCache.withStore(MemCacheStore(), now: () => clock);
    dio = Dio(BaseOptions(baseUrl: 'https://api.example'))
      ..httpClientAdapter = adapter
      ..interceptors.addAll(cache.interceptors);
    cache.attach(dio);
  });

  Future<int> version(String path) async =>
      ((await dio.get<dynamic>(path)).data as Map)['v'] as int;

  test('an old detail opens at once with what was saved and is refreshed '
      'behind it for the next time', () async {
    await version('/movie/603');
    adapter.version = 2;
    clock = clock.add(const Duration(hours: 7)); // past the 6 h TTL

    expect(await version('/movie/603'), 1); // the old one, no waiting
    await pumpEventQueue();
    expect(adapter.requests, hasLength(2)); // refreshed behind it
    expect(cache.stats.revalidations, 1);

    // The refreshed answer is current now: no new request and the new data.
    clock = clock.subtract(const Duration(hours: 7));
    expect(await version('/movie/603'), 2);
    expect(adapter.requests, hasLength(2));
  });

  test('a Home list has its window too: 24 hours', () async {
    await version('/trending/all/week');
    clock = clock.add(const Duration(hours: 23)); // past 10 min, inside 24 h
    adapter.version = 2;

    expect(await version('/trending/all/week'), 1);
    await pumpEventQueue();
    expect(adapter.requests, hasLength(2));
  });

  test('past the window the network is waited for', () async {
    await version('/trending/all/week');
    clock = clock.add(const Duration(hours: 25));
    adapter.version = 2;

    expect(await version('/trending/all/week'), 2);
    expect(cache.stats.revalidations, 0);
  });

  test('a detail waits too after 7 days', () async {
    await version('/movie/603');
    clock = clock.add(const Duration(days: 8));
    adapter.version = 2;

    expect(await version('/movie/603'), 2);
  });

  test('a route with no window asks as soon as it is stale', () async {
    await version('/person/287');
    clock = clock.add(const Duration(hours: 25)); // past its 24 h TTL
    adapter.version = 2;

    expect(await version('/person/287'), 2);
    expect(cache.stats.revalidations, 0);
  });

  test('two reads inside the window start one refresh', () async {
    await version('/movie/603');
    clock = clock.add(const Duration(hours: 7));

    await Future.wait([version('/movie/603'), version('/movie/603')]);
    await pumpEventQueue();

    expect(adapter.requests, hasLength(2)); // the first + one refresh
  });

  test('a refresh that fails changes nothing and is not an error', () async {
    await version('/movie/603');
    clock = clock.add(const Duration(hours: 7));
    adapter.offline = true;

    expect(await version('/movie/603'), 1);
    await pumpEventQueue();

    // Still there for the next read, which tries again.
    expect(await version('/movie/603'), 1);
  });

  test('a user refresh is never answered with the old one', () async {
    await version('/movie/603');
    clock = clock.add(const Duration(hours: 7));
    adapter.version = 2;

    final r = await dio.get<dynamic>(
      '/movie/603',
      options: Options(
        extra: {ApiCachePolicyInterceptor.modeKey: FetchMode.refresh},
      ),
    );
    expect((r.data as Map)['v'], 2);
  });
}
