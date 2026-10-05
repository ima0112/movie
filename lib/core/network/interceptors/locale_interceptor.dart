import 'package:dio/dio.dart';

/// Adds TMDB's `language`/`region` query parameters to every request.
///
/// `docs/DECISIONS.md` §2: "Localization | `language` and `region`
/// parameters on every call." These should ultimately come from the
/// user's own settings (F11: "Language (es/en), region"), but no
/// settings repository exists yet — [language]/[region] are read lazily
/// (a function, not a plain value) so a real preferences source can be
/// plugged in later without reshaping this interceptor; for now they
/// always resolve to the fixed `es-ES`/`ES` defaults this task asked for.
class LocaleInterceptor extends Interceptor {
  LocaleInterceptor({
    String Function()? language,
    String Function()? region,
  }) : _language = language ?? _defaultLanguage,
       _region = region ?? _defaultRegion;

  final String Function() _language;
  final String Function() _region;

  static String _defaultLanguage() => 'es-ES';
  static String _defaultRegion() => 'ES';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters.putIfAbsent('language', _language);
    options.queryParameters.putIfAbsent('region', _region);
    handler.next(options);
  }
}
