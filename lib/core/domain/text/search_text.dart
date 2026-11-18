/// Search-friendly text: what the app compares when it matches what the user
/// typed against names it has (countries, platforms, cast, a person's exact
/// name). Typing "jose" finds "José", "espana" finds "España", "ZOË" finds
/// "zoe". Pure Dart — no Flutter, no network.
///
/// (TMDB's own `/search/multi` already ignores accents on its side; this is for
/// everything the app filters or ranks by itself.)
library;

/// [text] lower-cased, without accents or other diacritics (á→a, ñ→n, ç→c,
/// ö→o, ø→o, ł→l…, and ß→ss, æ→ae, œ→oe), with runs of white space turned into
/// one space and the ends trimmed.
String foldForSearch(String text) {
  final out = StringBuffer();
  for (final rune in text.toLowerCase().runes) {
    // Combining marks (an accent typed or pasted as its own character).
    if (rune >= 0x0300 && rune <= 0x036F) continue;
    out.write(_fold[rune] ?? String.fromCharCode(rune));
  }
  return out.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Whether [text] contains [query] once both are folded ([foldForSearch]). An
/// empty (or blank) [query] matches everything.
bool matchesSearch(String text, String query) {
  final needle = foldForSearch(query);
  return needle.isEmpty || foldForSearch(text).contains(needle);
}

/// Whether [text] and [query] are the same once both are folded.
bool equalsSearch(String text, String query) =>
    foldForSearch(text) == foldForSearch(query);

final Map<int, String> _fold = _buildFold();

Map<int, String> _buildFold() {
  const groups = <String, String>{
    'a': 'àáâãäåāăąǎ',
    'c': 'çćĉċč',
    'd': 'ďđ',
    'e': 'èéêëēĕėęěǝ',
    'g': 'ĝğġģ',
    'h': 'ĥħ',
    'i': 'ìíîïĩīĭįıǐ',
    'j': 'ĵ',
    'k': 'ķ',
    'l': 'ĺļľŀł',
    'n': 'ñńņňŉ',
    'o': 'òóôõöōŏőøǒ',
    'r': 'ŕŗř',
    's': 'śŝşšș',
    't': 'ţťŧț',
    'u': 'ùúûüũūŭůűųǔ',
    'w': 'ŵ',
    'y': 'ýÿŷ',
    'z': 'źżž',
  };
  final map = <int, String>{};
  groups.forEach((base, chars) {
    for (final rune in chars.runes) {
      map[rune] = base;
    }
  });
  map[0x00DF] = 'ss'; // ß
  map[0x00E6] = 'ae'; // æ
  map[0x0153] = 'oe'; // œ
  return map;
}
