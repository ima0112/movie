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

/// Locale-aware one-decimal formatting for a rating (e.g. "7.9" in
/// English, "7,9" in Spanish — a decimal comma, not a decimal point).
/// A fixed `'0.0'` pattern, not `decimalPattern`, so a whole-number
/// rating still shows its one decimal place (e.g. "8.0"), matching
/// `toStringAsFixed(1)`'s own behavior before this replaced it.
extension LocalizedRating on double {
  String localizedRating(AppLocalizations l10n) =>
      NumberFormat('0.0', l10n.localeName).format(this);
}
