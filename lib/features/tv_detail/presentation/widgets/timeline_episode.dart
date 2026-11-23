import 'package:flutter/material.dart';

import '../../../../core/domain/entities/season_summary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/full_date_format.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/number_format_extension.dart';
import '../../../../shared/widgets/still_image.dart';

/// One episode inside D2b's timeline card: the 92×56 still, "S5 · E16 · Name"
/// and a plain muted line with the air date and (when TMDB has one) the ★
/// rating — "29 Sep 2013 · ★ 9.9".
class TimelineEpisode extends StatelessWidget {
  const TimelineEpisode({super.key, required this.episode});

  final EpisodeRef episode;

  static const double _stillWidth = 92;
  static const double _stillHeight = 56;
  static const double _starSize = 12;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = episode.seasonNumber == 0
        ? l10n.tvEpisodeCodeSpecialsAndName(episode.episodeNumber, episode.name)
        : l10n.tvEpisodeCodeAndName(
            episode.seasonNumber,
            episode.episodeNumber,
            episode.name,
          );
    final airDate = episode.airDate;
    final rating = episode.voteAverage;
    final muted = AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted);
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd - 2),
          child: SizedBox(
            width: _stillWidth,
            height: _stillHeight,
            child: StillImage(stillPath: episode.stillPath),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.h3, maxLines: 2),
              const SizedBox(height: AppSpacing.xs),
              Text.rich(
                TextSpan(
                  style: muted,
                  children: [
                    TextSpan(
                      text: airDate == null
                          ? l10n.tvEpisodeTba
                          : l10n.fullDate(airDate),
                    ),
                    if (rating != null) ...[
                      const TextSpan(text: ' · '),
                      const WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(
                          AppIcons.starFill,
                          size: _starSize,
                          color: AppColors.accent,
                        ),
                      ),
                      TextSpan(text: ' ${rating.localizedRating(l10n)}'),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
