import 'package:flutter/material.dart';

import '../../../../core/domain/entities/season_summary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/poster_image.dart';

/// One season of D2b's grid: its poster (2:3, rounded) with a short tag in the
/// corner — "S1" / "T1", or "Specials" for season 0 —, and under it the year
/// in bold (when known) and "7 episodes" in muted text. Tapping opens the
/// season. The tag is only a visual shortcut: the whole tile reads as "Season
/// 1, 2008, 7 episodes".
class SeasonPosterTile extends StatelessWidget {
  const SeasonPosterTile({super.key, required this.season, this.onTap});

  final SeasonSummary season;
  final VoidCallback? onTap;

  static const double _posterRatio = 2 / 3;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final special = season.seasonNumber == 0;
    final badge = special
        ? l10n.tvSpecialsLabel
        : l10n.tvSeasonBadge(season.seasonNumber);
    final name = special
        ? l10n.tvSpecialsLabel
        : l10n.tvSeasonLabel(season.seasonNumber);
    final year = season.airDate?.year;
    final episodes = l10n.tvEpisodeCount(season.episodeCount);
    return Semantics(
      button: true,
      label: [name, if (year != null) '$year', episodes].join(', '),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: _posterRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PosterImage(posterPath: season.posterPath),
                    Positioned(
                      left: AppSpacing.sm,
                      bottom: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: _Badge(label: badge),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (year != null) Text('$year', style: AppTextStyles.bodyStrong),
            Text(
              episodes,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// The dark pill on the poster's corner. Fixed to the text scale 1: it is a
/// small tag over an image, and must not outgrow the poster.
class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withNoTextScaling(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 1,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmStrong,
        ),
      ),
    );
  }
}
