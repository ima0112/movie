import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../app/environments.dart';
import '../config/env.dart';
import '../data/tmdb/tmdb_language_tag.dart';
import '../domain/repositories/settings_repository.dart';
import 'interceptors/bearer_interceptor.dart';
import 'interceptors/locale_interceptor.dart';
import 'interceptors/tmdb_logging_interceptor.dart';

/// The single HTTP entry point for TMDB — CLAUDE.md rule 2: "no widget or
/// repository builds a TMDB URL by hand." Every `data/repositories/*`
/// implementation takes this (not a bare `Dio`) and calls [get]/[dio]
/// directly; nothing else in the app constructs a `Dio` instance.
///
/// Only registered in the `real` environment (`app/environments.dart`) —
/// the `fake` environment's repositories don't touch the network at all,
/// so there's nothing for this to do there.
@real
@LazySingleton()
class ApiClient {
  ApiClient(SettingsRepository settingsRepository)
    : dio = Dio(BaseOptions(baseUrl: Env.tmdbBaseUrl)) {
    dio.interceptors.addAll([
      BearerInterceptor(Env.tmdbToken),
      LocaleInterceptor(
        language: () => tmdbLanguageTag(
          settingsRepository.current.languageCode,
          settingsRepository.current.regionCode,
        ),
        region: () => settingsRepository.current.regionCode,
      ),
      TmdbLoggingInterceptor(),
    ]);
  }

  /// Exposed (not hidden behind `get`/`post` wrappers) so callers can use
  /// Dio's own `queryParameters`/`options` features directly — this
  /// class's job is just "one configured client," not re-inventing Dio's
  /// own request API.
  final Dio dio;
}
