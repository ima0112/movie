import 'package:flutter/material.dart';

import '../../../../core/domain/entities/season_summary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../l10n/full_date_format.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/number_format_extension.dart';

/// An episode's one muted line, "20 Jan 2008 · 59 min · ★ 8.9": the air date
/// ("TBA" with no date, amber when it is still ahead), the runtime and the ★
/// rating — each of the last two left out when unknown. Shared by D2c's rows
/// and the episode sheet; they differ only in [style] and [starSize].
class EpisodeMetaLine extends StatelessWidget {
  const EpisodeMetaLine({
    super.key,
    required this.episode,
    required this.style,
    required this.starSize,
    this.maxLines = 1,
  });

  final Episode episode;

  /// The base text style (muted); the future date overrides its colour.
  final TextStyle style;
  final double starSize;

  /// `null` lets the line wrap.
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final airDate = episode.airDate;
    final hasAired = airDate == null || !airDate.isAfter(DateTime.now());
    final runtime = episode.runtimeMinutes;
    final rating = episode.voteAverage;
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(
            text: airDate == null ? l10n.tvEpisodeTba : l10n.fullDate(airDate),
            style: hasAired ? null : style.copyWith(color: AppColors.accent),
          ),
          if (runtime != null)
            TextSpan(text: ' · ${l10n.myListRuntimeMinutesOnly(runtime)}'),
          if (rating != null) ...[
            const TextSpan(text: ' · '),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                AppIcons.starFill,
                size: starSize,
                color: AppColors.accent,
              ),
            ),
            TextSpan(text: ' ${rating.localizedRating(l10n)}'),
          ],
        ],
      ),
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }
}
