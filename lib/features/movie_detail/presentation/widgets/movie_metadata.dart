import '../../../../core/domain/entities/media_detail.dart';
import '../../../../l10n/app_localizations.dart';

/// D1's metadata-line formatting — "2019 · 2 h 10 min · PG-13". D1's info
/// card itself now shows just the year before the genres plus
/// [movieInfoChips] (runtime, certification) as chips; this combined line
/// stays for places that want the whole thing in one string. Kept here, not
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

/// The info card's extra chips after the rating: runtime ("2 h 28 min") and
/// the certification ("PG-13"), whichever exist.
List<String> movieInfoChips(MovieDetail detail, AppLocalizations l10n) {
  final runtime = detail.runtimeMinutes;
  return [
    if (runtime != null) _formatRuntime(runtime, l10n),
    ?detail.certification,
  ];
}
