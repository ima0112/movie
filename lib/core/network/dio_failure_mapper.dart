import 'package:dio/dio.dart';

import '../domain/entities/result.dart';

/// The one place a [DioException] becomes a [Failure] — CLAUDE.md rule 7:
/// "Sealed `Result<T>`, never exceptions crossing from `data` to
/// `presentation`." Every repository in `data/` that calls
/// `ApiClient`/`Dio` must catch its [DioException]s and run them through
/// this, not invent its own mapping — a `DioException` must never
/// propagate past `data/` itself. Only a [FailureReason] comes out of
/// this, never a message string (rule 15) — the exception's own detail
/// (status code, URI, `exception.message`) is real, useful information,
/// but it's diagnostic, not something to show a user, so it's dropped
/// here rather than smuggled into `Failure` under a different name.
Failure<T> mapDioExceptionToFailure<T>(DioException exception) {
  final statusCode = exception.response?.statusCode;

  if (statusCode == 404) {
    return Failure<T>(FailureReason.notFound);
  }

  if (statusCode == 429) {
    return Failure<T>(FailureReason.quota);
  }

  if (statusCode != null && statusCode >= 500) {
    return Failure<T>(FailureReason.server);
  }

  switch (exception.type) {
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return Failure<T>(FailureReason.network);
    case DioExceptionType.badCertificate:
    case DioExceptionType.badResponse:
    case DioExceptionType.cancel:
    case DioExceptionType.unknown:
      if (statusCode != null) {
        return Failure<T>(FailureReason.server);
      }
      return Failure<T>(FailureReason.unknown);
  }
}
