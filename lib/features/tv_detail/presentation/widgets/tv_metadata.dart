import '../../../../core/domain/entities/media_detail.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/media_detail/language_chip_label.dart';

/// D2's metadata-line formatting — "2022–2024 · 3 seasons · 24 episodes ·
/// TV-14" (`docs/SCREENS.md` D2), shown in the info card before the genres.
/// Kept here, not in the shared widgets, for the same reason
/// `movieMetadataLine` is: each screen formats its own per-field logic.
///
/// `episodeRuntimeMinutes`/"≈ 45 min per episode" isn't folded into this
/// line: `TvShowDetail.estimatedHours` already owns that "45 min fallback"
/// idea for C4 (Stats) — duplicating it here would just be a second,
/// inconsistent place for the same number.
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

/// D2's info-card chips after the rating: the original language ("EN").
List<String> tvInfoChips(TvShowDetail detail) => [
  ?languageChipLabel(detail.originalLanguage),
];
