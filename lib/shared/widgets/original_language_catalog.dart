/// The original languages H8 offers, as `(ISO 639-1 code, the language's own
/// name)`. A language is always written in itself ("Español", "日本語"), the
/// way every language picker does, so these names are not translated (they
/// are not copy of the app) — only the "Any" option is.
const List<(String, String)> originalLanguages = [
  ('en', 'English'),
  ('es', 'Español'),
  ('fr', 'Français'),
  ('de', 'Deutsch'),
  ('it', 'Italiano'),
  ('pt', 'Português'),
  ('ja', '日本語'),
  ('ko', '한국어'),
  ('zh', '中文'),
  ('hi', 'हिन्दी'),
  ('ru', 'Русский'),
  ('tr', 'Türkçe'),
];

/// [code]'s own name, or the code itself when it isn't in the list.
String originalLanguageName(String code) {
  for (final (c, name) in originalLanguages) {
    if (c == code) return name;
  }
  return code;
}
