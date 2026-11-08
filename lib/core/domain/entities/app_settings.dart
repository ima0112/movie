/// The user's own content and interface preferences — F11 ("Language
/// (es/en), region..."). [languageCode] is a single, unified value:
/// both `LocaleInterceptor`'s TMDB `language` parameter (via
/// `tmdbLanguageTag`) and `PakoTvApp`'s own `MaterialApp.router.locale`
/// read the same field — one Settings row, not two separate
/// "content language"/"app language" preferences.
class AppSettings {
  const AppSettings({required this.languageCode, required this.regionCode});

  /// ISO 639-1, e.g. `es`/`en` — feeds both `LocaleInterceptor`'s TMDB
  /// `language` query parameter (via `tmdbLanguageTag`) and the app's
  /// own UI `Locale` (CLAUDE.md rule 15).
  final String languageCode;

  /// ISO 3166-1 alpha-2, e.g. `ES`/`US` — the `region` half of the same
  /// parameter, and what `TmdbMediaRepository` resolves watch providers
  /// and certifications against.
  final String regionCode;

  AppSettings copyWith({String? languageCode, String? regionCode}) =>
      AppSettings(
        languageCode: languageCode ?? this.languageCode,
        regionCode: regionCode ?? this.regionCode,
      );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.languageCode == languageCode &&
      other.regionCode == regionCode;

  @override
  int get hashCode => Object.hash(languageCode, regionCode);

  @override
  String toString() =>
      'AppSettings(languageCode: $languageCode, regionCode: $regionCode)';
}
