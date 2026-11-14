import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/stats/library_stats.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/activity_bars.dart';
import '../../../../shared/widgets/skeleton_block.dart';
import '../../../../shared/widgets/type_split_bar.dart';
import '../cubit/you_stats_cubit.dart';
import 'you_metric_strip.dart';
import 'you_stats_insights.dart';

/// B5's stats card (`docs/SCREENS.md` B5): the four numbers, the insight
/// lines, the last twelve months as bars, the movies / TV split and the
/// amber "See stats" link → C4. With nothing watched it is an invitation
/// instead of a row of zeros.
///
/// This card is the only part of the page that needs the whole
/// [LibraryStats], so its `BlocBuilder` is as large as it is (rule 9); the
/// other sections of You select their own slice.
class YouStatsCard extends StatelessWidget {
  const YouStatsCard({super.key, required this.onSeeStats});

  /// → C4 ("Stats").
  final VoidCallback onSeeStats;

  static const double _skeletonHeight = 220;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: BlocBuilder<YouStatsCubit, LibraryStats?>(
          builder: (context, stats) {
            if (stats == null) {
              return const SkeletonBlock(
                width: double.infinity,
                height: _skeletonHeight,
              );
            }
            return stats.watchedCount == 0
                ? const _Invitation()
                : _Body(stats: stats, onSeeStats: onSeeStats);
          },
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.stats, required this.onSeeStats});

  final LibraryStats stats;
  final VoidCallback onSeeStats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        YouMetricStrip(stats: stats),
        const SizedBox(height: AppSpacing.lg),
        YouStatsInsights(stats: stats),
        const SizedBox(height: AppSpacing.lg),
        ActivityBars(counts: stats.monthlyActivity),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.youStatsLast12Months,
          style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: AppSpacing.lg),
        TypeSplitBar(
          firstCount: stats.moviesWatched,
          firstLabel: l10n.youStatsMovies(stats.moviesWatched),
          secondCount: stats.tvShowsWatched,
          secondLabel: l10n.youStatsShows(stats.tvShowsWatched),
        ),
        const SizedBox(height: AppSpacing.lg),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onSeeStats,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.yourActivitySeeStats,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.accent),
              ),
              const Icon(
                AppIcons.chevronRight,
                size: 16,
                color: AppColors.accent,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Invitation extends StatelessWidget {
  const _Invitation();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Text(
          l10n.statsEmptyTitle,
          style: AppTextStyles.h3,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.statsEmptyBody,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
