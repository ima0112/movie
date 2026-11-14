import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Reads an ARB file's own message keys (every key except `@@locale`
/// and the `@key` metadata blocks) mapped to their raw ICU message
/// string.
Map<String, String> _messages(String path) {
  final json =
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return {
    for (final entry in json.entries)
      if (entry.key != '@@locale' && !entry.key.startsWith('@'))
        entry.key: entry.value as String,
  };
}

/// The set of named ICU placeholders/arguments a message actually
/// references — e.g. `{version}`/`{build}` in a plain substitution, or
/// `{count}` in `"{count, plural, =1{1 item} other{{count} items}}"`
/// (matched once per occurrence, including inside a plural/select
/// clause's own branches; duplicates collapse into the same set entry
/// either way). `other`/`=1`/etc. are ICU keywords, never matched —
/// the pattern only accepts a `{` immediately followed by a letter, and
/// neither "other" nor a bare `=1{...}` branch is preceded by one.
Set<String> _placeholders(String message) => RegExp(
  r'\{([a-zA-Z][a-zA-Z0-9_]*)',
).allMatches(message).map((m) => m.group(1)!).toSet();

void main() {
  test('app_en.arb and app_es.arb have exactly the same keys and the same '
      'placeholders per key', () {
    final en = _messages('lib/l10n/app_en.arb');
    final es = _messages('lib/l10n/app_es.arb');

    expect(
      en.keys.toSet(),
      es.keys.toSet(),
      reason:
          'app_en.arb and app_es.arb must declare exactly the same set '
          'of keys — a key missing from either file means a sentence '
          "the other locale can't ever show.",
    );

    for (final key in en.keys) {
      expect(
        _placeholders(es[key]!),
        _placeholders(en[key]!),
        reason:
            "'$key' has different placeholders between app_en.arb "
            '(${_placeholders(en[key]!)}) and app_es.arb '
            '(${_placeholders(es[key]!)}) — both must reference the '
            'exact same named arguments, e.g. both use {count} or '
            'neither does.',
      );
    }
  });
}
