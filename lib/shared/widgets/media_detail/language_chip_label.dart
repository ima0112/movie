/// The info chip's text for an original language: its ISO 639-1 code in
/// capitals ("EN"). Language names would need a translation per locale, a
/// code needs none. `null` for a missing or empty code, so callers can drop
/// the chip with `?languageChipLabel(code)`.
String? languageChipLabel(String? isoCode) {
  final code = isoCode?.trim();
  if (code == null || code.isEmpty) return null;
  return code.toUpperCase();
}
