/// The user's own TMDB content preferences — F11 ("Language (es/en),
/// region..."). Deliberately narrow: this only ever changes which
/// language/region TMDB's own content comes back in, never the app's
/// own UI language (that's a separate, later localization step — see
/// `docs/DECISIONS.md` §F11's own scope note).
class AppSettings {
  const AppSettings({required this.languageCode, required this.regionCode});

  /// ISO 639-1, e.g. `es`/`en` — the `language` half of
  /// `LocaleInterceptor`'s TMDB query parameter.
  final String languageCode;

  /// ISO 3166-1 alpha-2, e.g. `ES`/`US` — the `region` half of the same
  /// parameter, and what `TmdbMediaRepository` resolves watch providers
  /// and certifications against.
  final String regionCode;

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
