import 'package:dio/dio.dart';

/// Adds TMDB's v4 bearer token to every request.
///
/// `docs/DECISIONS.md` §2: "Auth | Bearer token (v4 read access token).
/// Do not use the v3 key as a query string." — the token itself is read
/// once at construction (`core/config/env.dart`'s `Env.tmdbToken`, a
/// compile-time `--dart-define` value), not re-read per request.
class BearerInterceptor extends Interceptor {
  BearerInterceptor(this._token);

  final String _token;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Authorization'] = 'Bearer $_token';
    handler.next(options);
  }
}
