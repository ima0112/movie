/// TMDB's own `language` query parameter (an IETF tag, e.g. `es-ES`) for
/// a `SettingsRepository`'s plain `languageCode`/`regionCode` pair —
/// pure, no network, easily unit-tested on its own.
///
/// TMDB has no single "Latin American Spanish" tag; collapsing every
/// Spanish-speaking region outside Spain onto `es-MX` is a deliberate
/// simplification (a real per-country content difference isn't worth a
/// 20-country lookup table for this app), not an attempt at a complete
/// IETF mapping. [languageCode] is only ever `es`/`en` in practice (see
/// `AppSettings`'s own doc comment), so the final `en-US` branch below
/// is a defensive fallback, not a real code path.
String tmdbLanguageTag(String languageCode, String regionCode) {
  if (languageCode != 'es') return 'en-US';
  if (regionCode == 'ES') return 'es-ES';
  if (_spanishSpeakingLatAmRegions.contains(regionCode)) return 'es-MX';
  // Spanish, but neither Spain nor a recognized Latin American region
  // (e.g. a Spanish speaker whose region is 'US') — Spain's own tag is
  // the more neutral default of the two TMDB variants this app uses.
  return 'es-ES';
}

/// ISO 3166-1 alpha-2 codes for the Spanish-speaking countries of Latin
/// America and the Caribbean — everywhere `es-MX` stands in for.
const _spanishSpeakingLatAmRegions = {
  'MX',
  'AR',
  'CO',
  'CL',
  'PE',
  'VE',
  'EC',
  'GT',
  'CU',
  'BO',
  'DO',
  'HN',
  'PY',
  'SV',
  'NI',
  'CR',
  'PA',
  'UY',
  'PR',
};
