import 'package:flutter/material.dart';

import '../../../../../core/domain/stats/surprise_insights.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/genre_icons.dart';
import '../../../../../l10n/genre_localization.dart';
import '../../../../../l10n/l10n_extension.dart';
import '../../../../../shared/widgets/type_split_bar.dart';
import 'surprise_stat_card.dart';

/// "Your picks by genre": per genre, how many of the cards shown were chosen
/// (a bar of chosen over shown), the top [rows]; and the movies/shows split of
/// what was chosen.
class SurpriseGenresCard extends StatelessWidget {
  const SurpriseGenresCard({
    super.key,
    required this.genres,
    required this.split,
  });

  final List<SurpriseGenreStat> genres;
  final SurpriseTypeSplit split;

  static const int rows = 5;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SurpriseStatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statsSurpriseGenresHint,
            style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final g in genres.take(rows)) _Row(stat: g),
          if (split.total > 0) ...[
            const SizedBox(height: AppSpacing.lg),
            TypeSplitBar(
              firstCount: split.movies,
              firstLabel: l10n.youStatsMovies(split.movies),
              secondCount: split.shows,
              secondLabel: l10n.youStatsShows(split.shows),
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.stat});

  final SurpriseGenreStat stat;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(genreIconOf(stat.genre), color: AppColors.accent),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 4,
            child: Text(
              stat.genre.localizedName(l10n),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySm,
            ),
          ),
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              child: LinearProgressIndicator(
                value: stat.shown == 0 ? 0 : stat.chosen / stat.shown,
                minHeight: AppSpacing.xs,
                color: AppColors.accent,
                backgroundColor: AppColors.surfaceRaised2,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: AppSpacing.xxl * 2,
            child: Text(
              l10n.statsSurpriseOfTotal(stat.chosen, stat.shown),
              textAlign: TextAlign.end,
              style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
            ),
          ),
        ],
      ),
    );
  }
}
