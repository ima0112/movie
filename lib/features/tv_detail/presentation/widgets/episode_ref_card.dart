import 'package:flutter/material.dart';

import '../../../../core/domain/entities/season_summary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/number_format_extension.dart';
import '../../../../shared/widgets/media_detail/info_chip.dart';
import '../../../../shared/widgets/still_image.dart';
import 'season_episode_row.dart';

/// One episode card on D2b ("Next episode" / "Last aired episode"): the
/// 92×56 still, "S5 · E16 · Name" and chips for the air date and (when TMDB
/// has one) the ★ rating. With no [episode] it shows [emptyTitle] and
/// [emptyBody] instead.
class EpisodeRefCard extends StatelessWidget {
  const EpisodeRefCard({
    super.key,
    required this.episode,
    required this.emptyTitle,
    required this.emptyBody,
  });

  final EpisodeRef? episode;
  final String emptyTitle;
  final String emptyBody;

  static const double _stillWidth = 92;
  static const double _stillHeight = 56;

  @override
  Widget build(BuildContext context) {
    final episode = this.episode;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: episode == null ? _empty() : _filled(context, episode),
    );
  }

  Widget _empty() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(emptyTitle, style: AppTextStyles.h3),
      const SizedBox(height: 2),
      Text(
        emptyBody,
        style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
      ),
    ],
  );

  Widget _filled(BuildContext context, EpisodeRef episode) {
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
              const SizedBox(height: AppSpacing.sm - 2),
              Wrap(
                spacing: AppSpacing.xs + 2,
                runSpacing: AppSpacing.xs + 2,
                children: [
                  InfoChip(
                    label: airDate == null
                        ? l10n.tvEpisodeTba
                        : formatEpisodeDate(airDate),
                  ),
                  if (rating != null)
                    InfoChip(
                      label: rating.localizedRating(l10n),
                      icon: AppIcons.starFill,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
