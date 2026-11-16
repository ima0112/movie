import 'app_localizations.dart';
import 'full_date_format.dart';

/// The date lines of a My List row (`docs/SCREENS.md` B4) — CLAUDE.md rule 15.
extension LibraryDateLocalization on AppLocalizations {
  /// "Added today", "Added yesterday", "Added 3 days ago" (up to 6),
  /// "Added 2 weeks ago" (up to 4) and, past that, "Added 12 Jan, 2026".
  /// [now] is the day it is counted from (today unless a test says so).
  String addedLabel(DateTime added, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final days = DateTime(
      today.year,
      today.month,
      today.day,
    ).difference(DateTime(added.year, added.month, added.day)).inDays;
    return switch (days) {
      <= 0 => libraryRowAddedToday,
      1 => libraryRowAddedYesterday,
      < 7 => libraryRowAddedDaysAgo(days),
      < 35 => libraryRowAddedWeeksAgo(days ~/ 7),
      _ => libraryRowAddedOn(fullDate(added)),
    };
  }

  /// "Watched 8 Nov, 2026".
  String watchedLabel(DateTime watched) =>
      libraryRowWatchedOn(fullDate(watched));
}
