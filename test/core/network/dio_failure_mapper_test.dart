import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/network/dio_failure_mapper.dart';

void main() {
  final requestOptions = RequestOptions(path: '/movie/123');

  DioException withStatus(int code) => DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: requestOptions, statusCode: code),
  );

  group('mapDioExceptionToFailure', () {
    test('404 -> NotFoundFailure', () {
      final failure = mapDioExceptionToFailure<int>(withStatus(404));

      expect(failure.reason, FailureReason.notFound);
    });

    test('429 -> QuotaFailure', () {
      final failure = mapDioExceptionToFailure<int>(withStatus(429));

      expect(failure.reason, FailureReason.quota);
    });

    test('500 -> ServerFailure', () {
      final failure = mapDioExceptionToFailure<int>(withStatus(500));

      expect(failure.reason, FailureReason.server);
    });

    test('503 -> ServerFailure (any 5xx, not just 500)', () {
      final failure = mapDioExceptionToFailure<int>(withStatus(503));

      expect(failure.reason, FailureReason.server);
    });

    for (final type in [
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    ]) {
      test('$type with no response -> NetworkFailure', () {
        final failure = mapDioExceptionToFailure<int>(
          DioException(requestOptions: requestOptions, type: type),
        );

        expect(failure.reason, FailureReason.network);
      });
    }

    test('cancel with no response -> unknown, not network/server', () {
      final failure = mapDioExceptionToFailure<int>(
        DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.cancel,
        ),
      );

      expect(failure.reason, FailureReason.unknown);
    });
  });
}
