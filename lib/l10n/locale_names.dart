import 'package:flutter/widgets.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

/// Localized display names for ISO codes, from `flutter_localized_locales`
/// (CLAUDE.md rule 15: no hard-coded names). Both fall back to the upper-case
/// code when the delegate isn't installed or has no entry, so a screen never
/// shows nothing.

/// The language's name in the app's language: `en` → "English" / "Inglés".
String languageDisplayName(BuildContext context, String isoCode) {
  final code = isoCode.trim();
  if (code.isEmpty) return '';
  final name = LocaleNames.of(context)?.nameOf(code.toLowerCase());
  return name == null ? code.toUpperCase() : _capitalized(name);
}

/// The country's name in the app's language: `US` → "United States" /
/// "Estados Unidos".
///
/// The package names *locales*, not bare countries, so the name is read from
/// the territory part of any locale for that country (`en_US` →
/// "English (United States)" → "United States"). A country with no locale in
/// the package shows its code.
String countryDisplayName(BuildContext context, String isoCode) {
  final code = isoCode.trim().toUpperCase();
  if (code.isEmpty) return '';
  final names = LocaleNames.of(context);
  if (names == null) return code;
  for (final entry in names.sortedByCode) {
    if (!entry.key.endsWith('_$code')) continue;
    final territory = territoryFromLocaleName(entry.value);
    if (territory != null) return territory;
  }
  return code;
}

/// "English (United States)" → "United States";
/// "Chinese (Simplified, China)" → "China"; no parentheses → `null`.
String? territoryFromLocaleName(String localeName) {
  final open = localeName.lastIndexOf('(');
  final close = localeName.lastIndexOf(')');
  if (open == -1 || close <= open) return null;
  final inside = localeName.substring(open + 1, close);
  final territory = inside.split(',').last.trim();
  return territory.isEmpty ? null : territory;
}

String _capitalized(String name) =>
    name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);
