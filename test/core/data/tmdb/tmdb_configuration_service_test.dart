import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/tmdb/tmdb_configuration_service.dart';
import 'package:movies/core/network/api_client.dart';

/// A minimal `HttpClientAdapter` double — no mocking package involved,
/// just the smallest thing satisfying Dio's own adapter contract (see
/// `dio`'s `ResponseBody.fromString`). Returns [response] for every
/// request unconditionally; [requests] records the attempted calls so
/// tests can assert `/configuration` was only hit once.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.response);

  final ResponseBody Function() response;
  final List<RequestOptions> requests = [];
  int fetchCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    fetchCount++;
    requests.add(options);
    return response();
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  const configurationJson = '''
  {
    "images": {
      "secure_base_url": "https://image.tmdb.org/t/p/",
      "poster_sizes": ["w92", "w342", "original"],
      "backdrop_sizes": ["w780", "original"],
      "profile_sizes": ["w185", "original"],
      "still_sizes": ["w300", "original"]
    },
    "change_keys": []
  }
  ''';

  test('current starts at the fallback before load() ever runs', () {
    final apiClient = ApiClient();
    final service = TmdbConfigurationService(apiClient);

    expect(service.current.secureBaseUrl, 'https://image.tmdb.org/t/p/');
  });

  test('load() fetches /configuration and updates current', () async {
    final apiClient = ApiClient();
    final adapter = _FakeAdapter(
      () => ResponseBody.fromString(
        configurationJson,
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
    apiClient.dio.httpClientAdapter = adapter;
    final service = TmdbConfigurationService(apiClient);

    final config = await service.load();

    expect(config.posterSizes, ['w92', 'w342', 'original']);
    expect(service.current.posterSizes, ['w92', 'w342', 'original']);
    expect(adapter.requests.single.path, '/configuration');
  });

  test('load() only ever fetches once, even when called repeatedly', () async {
    final apiClient = ApiClient();
    final adapter = _FakeAdapter(
      () => ResponseBody.fromString(
        configurationJson,
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
    apiClient.dio.httpClientAdapter = adapter;
    final service = TmdbConfigurationService(apiClient);

    await Future.wait([service.load(), service.load(), service.load()]);

    expect(adapter.fetchCount, 1);
  });

  test('a failed fetch keeps current at whatever it already was', () async {
    final apiClient = ApiClient();
    final adapter = _FakeAdapter(
      () => ResponseBody.fromString('not json', 500),
    );
    apiClient.dio.httpClientAdapter = adapter;
    final service = TmdbConfigurationService(apiClient);

    final config = await service.load();

    expect(config.secureBaseUrl, 'https://image.tmdb.org/t/p/');
    expect(service.current.posterSizes, isNotEmpty);
  });
}
