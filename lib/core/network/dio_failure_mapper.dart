import 'package:dio/dio.dart';

import '../domain/entities/result.dart';

/// The one place a [DioException] becomes a [Failure] — CLAUDE.md rule 7:
/// "Sealed `Result<T>`, never exceptions crossing from `data` to
/// `presentation`." Every repository in `data/` that calls
/// `ApiClient`/`Dio` must catch its [DioException]s and run them through
/// this, not invent its own mapping — a `DioException` must never
/// propagate past `data/` itself.
Failure<T> mapDioExceptionToFailure<T>(DioException exception) {
  final statusCode = exception.response?.statusCode;

  if (statusCode == 404) {
    return Failure<T>(
      'Not found: ${exception.requestOptions.uri}',
      reason: FailureReason.notFound,
    );
  }

  if (statusCode == 429) {
    return Failure<T>(
      'Too many requests — try again in a moment.',
      reason: FailureReason.quota,
    );
  }

  if (statusCode != null && statusCode >= 500) {
    return Failure<T>(
      'TMDB is having trouble (HTTP $statusCode).',
      reason: FailureReason.server,
    );
  }

  switch (exception.type) {
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return Failure<T>(
        'No connection — check your internet and try again.',
        reason: FailureReason.network,
      );
    case DioExceptionType.badCertificate:
    case DioExceptionType.badResponse:
    case DioExceptionType.cancel:
    case DioExceptionType.unknown:
      if (statusCode != null) {
        return Failure<T>(
          'TMDB request failed (HTTP $statusCode).',
          reason: FailureReason.server,
        );
      }
      return Failure<T>(
        exception.message ?? 'Something went wrong.',
        reason: FailureReason.unknown,
      );
  }
}
