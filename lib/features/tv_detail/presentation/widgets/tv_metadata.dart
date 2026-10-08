import '../../../../core/domain/entities/media_detail.dart';
import '../../../../l10n/app_localizations.dart';

/// D2's own metadata-line formatting — "2022–2024 · 3 seasons · 24
/// episodes · TV-14" (`docs/SCREENS.md` D2; `media_detail_title_block
/// .dart`'s own doc comment already quotes this exact shape). Kept here,
/// not in the shared header, for the same reason `movieMetadataLine`
/// isn't either — each screen formats its own per-field logic.
///
/// `episodeRuntimeMinutes`/"≈ 45 min per episode" (D2's other metadata
/// bullet) isn't folded into this line: `MediaDetailTitleBlock`'s own
/// doc comment already fixes this line's exact shape with no runtime
/// token in it, and `TvShowDetail.estimatedHours` already owns that
/// same "45 min fallback" idea for C4 (Stats) — duplicating it here
/// would just be a second, inconsistent place for the same number.
String tvMetadataLine(TvShowDetail detail, AppLocalizations l10n) {
  final firstYear = detail.firstAirDate?.year;
  final lastYear = detail.lastAirDate?.year;
  final yearRange = switch (firstYear) {
    null => null,
    final f when lastYear == null || lastYear == f => '$f',
    final f => '$f–$lastYear',
  };
  final seasonCount = detail.seasons.length;
  final episodeCount = detail.numberOfEpisodes;
  return [
    ?yearRange,
    if (seasonCount > 0) l10n.myListSeasonsCount(seasonCount),
    if (episodeCount > 0) l10n.tvEpisodeCount(episodeCount),
    ?detail.certification,
  ].join(' · ');
}
