import 'package:intl/intl.dart';

import 'app_localizations.dart';

/// The one format of a **full date** across the app (CLAUDE.md rule 15): day,
/// abbreviated month, comma, year — "12 Jan, 2026" in English, "12 ene, 2026"
/// in Spanish (`intl` gives each locale its own month names). Every screen that
/// shows a full date goes through this, so a date reads the same everywhere —
/// never `2026-5-25`, never "Jan 12, 2026".
///
/// Short forms ("Today", "3 days ago", "Mar 5" in My List) are a different
/// thing and keep their own wording.
extension FullDateLocalization on AppLocalizations {
  String fullDate(DateTime date) =>
      DateFormat(fullDatePattern, localeName).format(date);

  /// The `intl` pattern behind [fullDate].
  static const String fullDatePattern = 'd MMM, y';
}
