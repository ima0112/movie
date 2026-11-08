import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs each request/response/error in debug builds only — never in
/// release (the usual `kDebugMode` guard, not `assert`, since logging
/// must not depend on whether assertions are enabled).
///
/// **Never logs the `Authorization` header** — it carries the TMDB
/// bearer token (`BearerInterceptor`) and this project's a public repo.
class TmdbLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('→ ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '← ${response.statusCode} ${response.requestOptions.uri}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '✗ ${err.response?.statusCode} ${err.requestOptions.uri}: '
        '${err.message}',
      );
    }
    handler.next(err);
  }
}
