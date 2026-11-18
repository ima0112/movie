import 'app_localizations.dart';

/// A runtime in the user's language: "45 min", "2 h", "2 h 30 min" — the quiz's
/// max-duration slider and a Surprise-me card's "2024 · 2 h 46 min".
String formatRuntime(int minutes, AppLocalizations l10n) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return l10n.discoverRangeFiltersMinutes(m);
  if (m == 0) return l10n.quizDurationHours(h);
  return l10n.quizDurationHoursMinutes(h, m);
}
