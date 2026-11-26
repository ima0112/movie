import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/fetch_mode.dart';
import 'package:movies/core/network/cache/api_cache.dart';
import 'package:movies/core/network/cache/api_cache_policy_interceptor.dart';
import 'package:movies/core/network/interceptors/network_status_interceptor.dart';
import 'package:movies/core/network/network_status.dart';

class _Adapter implements HttpClientAdapter {
  bool offline = false;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    if (offline) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'no network',
      );
    }
    return ResponseBody.fromString(
      jsonEncode({'ok': true}),
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
  late NetworkStatus status;
  late Dio dio;

  setUp(() {
    adapter = _Adapter();
    status = NetworkStatus();
    final cache = ApiCache.withStore(MemCacheStore());
    dio = Dio(BaseOptions(baseUrl: 'https://api.example'))
      ..httpClientAdapter = adapter
      // The order ApiClient uses: NetworkStatus before the cache.
      ..interceptors.addAll([
        NetworkStatusInterceptor(status),
        ...cache.interceptors,
      ]);
    cache.attach(dio);
  });

  test('a cache hit never marks the app online', () async {
    await dio.get<dynamic>('/movie/603');
    status.reportUnreachable(); // something else found the network down

    await dio.get<dynamic>('/movie/603'); // answered by the cache

    expect(adapter.calls, 1);
    expect(status.isOnline, isFalse);
  });

  test(
    'offline, a saved screen still opens — and the banner still shows',
    () async {
      await dio.get<dynamic>('/trending/all/week');
      adapter.offline = true;

      // The saved list is old enough that the network is tried first.
      final refreshed = await dio.get<dynamic>(
        '/trending/all/week',
        options: Options(
          extra: {ApiCachePolicyInterceptor.modeKey: FetchMode.refresh},
        ),
      );

      expect((refreshed.data as Map)['ok'], isTrue);
      expect(status.isOnline, isFalse);
    },
  );

  test('offline with nothing saved is still a failure', () async {
    adapter.offline = true;

    await expectLater(
      dio.get<dynamic>('/movie/603'),
      throwsA(isA<DioException>()),
    );
    expect(status.isOnline, isFalse);
  });
}
