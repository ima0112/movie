import 'package:flutter/widgets.dart';

import '../../../../core/domain/entities/media_detail.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/locale_names.dart';

/// D1's metadata-line formatting — "2019 · 2 h 10 min · PG-13". D1's info
/// card shows the year and country before the genres, and the runtime and
/// certification live in the stat cards; this combined line stays for places
/// that want the whole thing in one string. Kept here, not
/// in the shared `shared/widgets/media_detail/` widgets: each screen
/// formats its own per-field logic (D2's differs), rather than the shared
/// widgets switching on media type.
String movieMetadataLine(MovieDetail detail, AppLocalizations l10n) {
  final year = detail.releaseDate?.year;
  final runtime = detail.runtimeMinutes;
  final certification = detail.certification;
  return [
    if (year != null) '$year',
    if (runtime != null) _formatRuntime(runtime, l10n),
    ?certification,
  ].join(' · ');
}

String _formatRuntime(int minutes, AppLocalizations l10n) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return h > 0
      ? l10n.myListRuntimeHoursMinutes(h, m)
      : l10n.myListRuntimeMinutesOnly(m);
}

/// The runtime as shown in D1's "Duration" stat card: "2 h 28 min".
String movieRuntimeLabel(int minutes, AppLocalizations l10n) =>
    _formatRuntime(minutes, l10n);

/// The info card's text before the genres: "2010 · United States" — the
/// release year and the main production country's name in the app's language
/// (`flutter_localized_locales`; the bare code if it has no name for it).
String movieMetaPrefix(BuildContext context, MovieDetail detail) => [
  ?detail.releaseDate?.year,
  if (detail.countryCodes.isNotEmpty)
    countryDisplayName(context, detail.countryCodes.first),
].join(' · ');
