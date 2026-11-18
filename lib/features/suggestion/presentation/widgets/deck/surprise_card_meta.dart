import '../../../../../core/domain/entities/media_detail.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../l10n/runtime_format.dart';

/// The line under a Surprise-me card's title (`docs/SCREENS.md` E3):
/// - a **movie**: "2024 · 2 h 46 min" (a part TMDB doesn't know is left out);
/// - a **series**: "2017–2020 · 3 seasons", or, still airing, "since 2021 · 4
///   seasons". No duration (an episode's length isn't the show's).
///
/// `null` when there is nothing to say. Pure function of the details.
String? surpriseMetaLine(MediaDetail detail, AppLocalizations l10n) {
  final parts = switch (detail) {
    MovieDetail(:final runtimeMinutes) => [
      if (detail.item.releaseDate?.year case final year?) '$year',
      if (runtimeMinutes != null && runtimeMinutes > 0)
        formatRuntime(runtimeMinutes, l10n),
    ],
    TvShowDetail(
      :final firstAirDate,
      :final lastAirDate,
      :final inProduction,
      :final seasons,
    ) =>
      () {
        final first = (firstAirDate ?? detail.item.releaseDate)?.year;
        final last = lastAirDate?.year;
        final count = seasons.where((s) => s.seasonNumber > 0).length;
        return [
          if (first != null)
            inProduction
                ? l10n.surpriseCardSince(first)
                : (last == null || last == first ? '$first' : '$first–$last'),
          if (count > 0) l10n.surpriseCardSeasons(count),
        ];
      }(),
  };
  return parts.isEmpty ? null : parts.join(' · ');
}
