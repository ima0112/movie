import '../../../../l10n/full_date_format.dart';
import 'package:flutter/material.dart';

import '../../../../core/domain/entities/season_summary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/still_image.dart';

/// One episode in H4's list: a 112×64 still with its number in a small
/// badge, the title, "date · runtime" (amber if it hasn't aired yet, "TBA"
/// with no date), and a 2-line synopsis. Hairline divider underneath.
class SeasonEpisodeRow extends StatelessWidget {
  const SeasonEpisodeRow({super.key, required this.episode, this.onTap});

  final Episode episode;
  final VoidCallback? onTap;

  static const double _stillWidth = 112;
  static const double _stillHeight = 64;
  static const double _badgeHeight = 22;
  static const double _chevronSize = 20;

  @override
  Widget build(BuildContext context) {
    final airDate = episode.airDate;
    final hasAired = airDate == null || !airDate.isAfter(DateTime.now());
    final l10n = context.l10n;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: SizedBox(
                    width: _stillWidth,
                    height: _stillHeight,
                    child: StillImage(stillPath: episode.stillPath),
                  ),
                ),
                Positioned(
                  left: AppSpacing.xs + 2,
                  top: AppSpacing.xs + 2,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: _badgeHeight,
                      minHeight: _badgeHeight,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs + 2,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(_badgeHeight / 2),
                    ),
                    child: Text(
                      '${episode.episodeNumber}',
                      style: AppTextStyles.captionStrong,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    episode.name,
                    style: AppTextStyles.h3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: airDate == null
                              ? l10n.tvEpisodeTba
                              : context.l10n.fullDate(airDate),
                          style: AppTextStyles.caption.copyWith(
                            color: hasAired
                                ? AppColors.inkMuted
                                : AppColors.accent,
                          ),
                        ),
                        if (episode.runtimeMinutes != null)
                          TextSpan(
                            text:
                                ' · '
                                '${l10n.myListRuntimeMinutesOnly(episode.runtimeMinutes!)}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.inkMuted,
                            ),
                          ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (episode.overview.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      episode.overview,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.inkMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                AppIcons.chevronRight,
                size: _chevronSize,
                color: AppColors.inkMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
