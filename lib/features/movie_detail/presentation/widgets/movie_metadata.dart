import '../../../../core/domain/entities/media_detail.dart';
import '../../../../l10n/app_localizations.dart';

/// D1's own metadata-line formatting — "2019 · 2 h 10 min · PG-13"
/// (`docs/SCREENS.md` D1). Kept here, not in the now-generic
/// `MediaDetailHeader`/`MediaDetailTitleBlock` (`shared/widgets/
/// media_detail/`): D2's own line ("2022–2024 · 3 seasons · 24
/// episodes · TV-14") is different enough per-field logic that each
/// screen formats its own string and hands the header an already-built
/// one, rather than the shared widget switching on media type itself.
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
