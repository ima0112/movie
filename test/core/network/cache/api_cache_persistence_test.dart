import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/network/cache/api_cache.dart';
import 'package:movies/core/persistence/app_database.dart';

class _Adapter implements HttpClientAdapter {
  final requests = <Uri>[];
  bool offline = false;

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
      jsonEncode({'path': options.path}),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// An app "run": its own memory cache over the shared database.
Dio _run(AppDatabase db, _Adapter adapter) =>
    Dio(BaseOptions(baseUrl: 'https://api.example'))
      ..httpClientAdapter = adapter
      ..interceptors.addAll(ApiCache(db).interceptors);

void main() {
  late AppDatabase db;
  late _Adapter adapter;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    adapter = _Adapter();
  });
  tearDown(() => db.close());

  test(
    'an answer survives the app closing: the next run does not ask',
    () async {
      await _run(db, adapter).get<dynamic>('/movie/603');
      expect(adapter.requests, hasLength(1));

      final nextRun = _run(db, adapter); // a fresh memory, the same database
      final again = await nextRun.get<dynamic>('/movie/603');

      expect(adapter.requests, hasLength(1));
      expect((again.data as Map)['path'], '/movie/603');
    },
  );

  test('with no network the next run still opens what it saw', () async {
    await _run(db, adapter).get<dynamic>('/trending/all/week');
    adapter.offline = true;

    final offline = await _run(db, adapter).get<dynamic>('/trending/all/week');

    expect((offline.data as Map)['path'], '/trending/all/week');
  });

  test('search and unlisted routes are never written to disk', () async {
    final dio = _run(db, adapter);
    await dio.get<dynamic>('/search/multi', queryParameters: {'query': 'a'});
    await dio.get<dynamic>('/genre/movie/list');

    expect(await db.select(db.apiResponseCacheTable).get(), isEmpty);
  });

  test('nothing saved holds the bearer token', () async {
    final dio = _run(db, adapter);
    await dio.get<dynamic>(
      '/movie/603',
      options: Options(headers: {'Authorization': 'Bearer secret-token'}),
    );

    final rows = await db.select(db.apiResponseCacheTable).get();
    expect(rows, hasLength(1));
    final saved =
        utf8.decode(rows.single.headers ?? const []) +
        rows.single.url +
        utf8.decode(rows.single.content ?? const []);
    expect(saved, isNot(contains('secret-token')));
  });

  test('"Clear cache" empties memory and disk', () async {
    final cache = ApiCache(db);
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example'))
      ..httpClientAdapter = adapter
      ..interceptors.addAll(cache.interceptors);
    await dio.get<dynamic>('/movie/603');
    expect(await db.select(db.apiResponseCacheTable).get(), hasLength(1));

    await cache.clear();

    expect(await db.select(db.apiResponseCacheTable).get(), isEmpty);
    await dio.get<dynamic>('/movie/603');
    expect(adapter.requests, hasLength(2));
  });
}
