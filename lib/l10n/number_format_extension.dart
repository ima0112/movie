import 'package:intl/intl.dart';

import 'app_localizations.dart';

/// Locale-aware digit grouping for a plain count (e.g. "1,234" in
/// English, "1.234" in Spanish) — the integer counterpart of this
/// project's own text-localization rule: never hardcode a raw
/// `'$value'` interpolation for a count that could grow large enough
/// to need grouping.
extension LocalizedCount on int {
  String localizedCount(AppLocalizations l10n) =>
      NumberFormat.decimalPattern(l10n.localeName).format(this);
}
