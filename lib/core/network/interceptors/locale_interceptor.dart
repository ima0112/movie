import 'package:dio/dio.dart';

/// Adds TMDB's `language`/`region` query parameters to every request.
///
/// `docs/DECISIONS.md` §2: "Localization | `language` and `region`
/// parameters on every call." [language]/[region] are read lazily (a
/// function, not a plain value) and called fresh on every request —
/// `ApiClient` passes functions that read `SettingsRepository.current`,
/// so a `save()` made between two requests is picked up by the very
/// next one, with no interceptor re-creation needed. [_defaultLanguage]
/// /[_defaultRegion] only matter when no function is passed at all
/// (e.g. a test building this interceptor directly) — they mirror
/// `SettingsRepository`'s own `en`/`US` fallback, not a real TMDB
/// default.
class LocaleInterceptor extends Interceptor {
  LocaleInterceptor({String Function()? language, String Function()? region})
    : _language = language ?? _defaultLanguage,
      _region = region ?? _defaultRegion;

  final String Function() _language;
  final String Function() _region;

  static String _defaultLanguage() => 'en-US';
  static String _defaultRegion() => 'US';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters.putIfAbsent('language', _language);
    options.queryParameters.putIfAbsent('region', _region);
    handler.next(options);
  }
}
