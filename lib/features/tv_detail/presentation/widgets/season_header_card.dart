import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/poster_image.dart';

/// H4's header: the season's poster, the show's name in small muted text,
/// the season title, and an info chip (the episode count) — the
/// "Temporada" design's top card.
class SeasonHeaderCard extends StatelessWidget {
  const SeasonHeaderCard({
    super.key,
    required this.title,
    required this.episodeCountLabel,
    this.showTitle,
    this.posterPath,
  });

  final String title;
  final String episodeCountLabel;
  final String? showTitle;
  final String? posterPath;

  static const double _posterWidth = 76;
  static const double _posterHeight = 114;

  @override
  Widget build(BuildContext context) {
    final showTitle = this.showTitle;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        // Darker than the sheet around it (as in the design) — which also
        // keeps an empty poster's placeholder visible.
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: SizedBox(
              width: _posterWidth,
              height: _posterHeight,
              child: PosterImage(posterPath: posterPath),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showTitle != null)
                  Text(
                    showTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                Text(title, style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [AppChip(label: episodeCountLabel)],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
