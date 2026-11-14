import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/network/interceptors/network_status_interceptor.dart';
import 'package:movies/core/network/network_status.dart';

/// A Dio whose every request ends as [outcome] says, with no network.
Dio _dio(NetworkStatus status, Future<ResponseBody> Function() outcome) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
    ..interceptors.add(NetworkStatusInterceptor(status))
    ..httpClientAdapter = _Adapter(outcome);
  return dio;
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.outcome);
  final Future<ResponseBody> Function() outcome;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) => outcome();

  @override
  void close({bool force = false}) {}
}

Future<void> _get(Dio dio) async {
  try {
    await dio.get<dynamic>('/x');
  } on DioException {
    // The status is what is under test.
  }
}

void main() {
  test('starts online, and only emits when it flips', () async {
    final status = NetworkStatus();
    final seen = <bool>[];
    status.changes.listen(seen.add);

    expect(status.isOnline, isTrue);
    status
      ..reportReachable()
      ..reportUnreachable()
      ..reportUnreachable()
      ..reportReachable();
    await Future<void>.delayed(Duration.zero);

    expect(seen, [false, true]);
  });

  group('NetworkStatusInterceptor', () {
    test('a connection error makes the app offline; the next answer clears '
        'it', () async {
      final status = NetworkStatus();
      var reachable = false;
      final dio = _dio(status, () async {
        if (!reachable) {
          throw DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionError,
          );
        }
        return ResponseBody.fromString('{}', 200);
      });

      await _get(dio);
      expect(status.isOnline, isFalse);

      reachable = true;
      await _get(dio);
      expect(status.isOnline, isTrue);
    });

    test('a timeout is offline too', () async {
      final status = NetworkStatus();
      final dio = _dio(status, () async {
        throw DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.receiveTimeout,
        );
      });

      await _get(dio);

      expect(status.isOnline, isFalse);
    });

    test('an HTTP error is still an answer: online', () async {
      final status = NetworkStatus()..reportUnreachable();
      final dio = _dio(status, () async => ResponseBody.fromString('{}', 500));

      await _get(dio);

      expect(status.isOnline, isTrue);
    });
  });
}
