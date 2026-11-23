import 'package:flutter/material.dart';

import '../../../../core/domain/entities/season_summary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/still_image.dart';
import 'episode_meta_line.dart';

/// One episode in D2c's list: a small still, the title, one muted line with
/// "date · runtime · ★ rating" (the date in amber if it hasn't aired yet,
/// "TBA" with no date; the runtime and the rating left out when unknown), a
/// 1-line synopsis, and the episode's number big and dim at the right ("01",
/// two digits at least). Hairline divider underneath.
class SeasonEpisodeRow extends StatelessWidget {
  const SeasonEpisodeRow({super.key, required this.episode, this.onTap});

  final Episode episode;
  final VoidCallback? onTap;

  static const double _stillWidth = 72;
  static const double _stillHeight = 48;
  static const double _starSize = 12;

  /// "01", "12", "103": two digits at least, the number as is beyond that.
  static String numberLabel(int number) => number < 10 ? '0$number' : '$number';

  @override
  Widget build(BuildContext context) {
    final muted = AppTextStyles.caption.copyWith(color: AppColors.inkMuted);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
                  Text(
                    episode.name,
                    style: AppTextStyles.h3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  EpisodeMetaLine(
                    episode: episode,
                    style: muted,
                    starSize: _starSize,
                  ),
                  if (episode.overview.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      episode.overview,
                      style: muted,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // A number at the right edge, fixed to the text scale 1 so it
            // never squeezes the text beside it.
            MediaQuery.withNoTextScaling(
              child: Text(
                numberLabel(episode.episodeNumber),
                style: AppTextStyles.episodeNumber,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
