import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/stats/library_stats.dart';
import '../../../../core/domain/stats/surprise_summary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/activity_bars.dart';
import '../../../../shared/widgets/skeleton_block.dart';
import '../../../../shared/widgets/type_split_bar.dart';
import '../cubit/you_stats_cubit.dart';
import '../cubit/you_surprise_cubit.dart';
import 'you_metric_strip.dart';
import 'you_stats_insights.dart';
import 'you_stats_mode.dart';
import 'you_surprise_summary.dart';

/// B5's stats card (`docs/SCREENS.md` B5). It exists only when there is
/// something to show — a title watched, or a Surprise me session (the two
/// places C4's numbers come from) — and then it is: the library's four
/// numbers, the insight lines, the last twelve months as bars and the movies /
/// TV split; Surprise me's mini summary (sessions and picks); and the amber
/// "See stats" link → C4. With only one of the two sources, only its part.
/// With neither it is not drawn at all, and neither is its gap
/// ([YouStatsMode.hidden]).
///
/// This card is the only part of the page that needs the whole
/// [LibraryStats], so its `BlocBuilder` is as large as it is (rule 9); the
/// other sections of You select their own slice. It owns the gap above it, so
/// a hidden card leaves no hole.
class YouStatsCard extends StatelessWidget {
  const YouStatsCard({super.key, required this.onSeeStats});

  /// → C4 ("Stats").
  final VoidCallback onSeeStats;

  static const double _skeletonHeight = 220;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YouStatsCubit, LibraryStats?>(
      builder: (context, library) =>
          BlocBuilder<YouSurpriseCubit, SurpriseSummary?>(
            builder: (context, surprise) {
              final mode = youStatsMode(library: library, surprise: surprise);
              if (mode == YouStatsMode.hidden) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sectionGap),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    child: mode == YouStatsMode.loading
                        ? const SkeletonBlock(
                            width: double.infinity,
                            height: _skeletonHeight,
                          )
                        : _Body(
                            library: mode == YouStatsMode.surprise
                                ? null
                                : library,
                            surprise: mode == YouStatsMode.library
                                ? null
                                : surprise,
                            onSeeStats: onSeeStats,
                          ),
                  ),
                ),
              );
            },
          ),
    );
  }
}

/// The card's content: the library's part ([library], when there is one), then
/// Surprise me's ([surprise], when there is one), then the link.
class _Body extends StatelessWidget {
  const _Body({
    required this.library,
    required this.surprise,
    required this.onSeeStats,
  });

  final LibraryStats? library;
  final SurpriseSummary? surprise;
  final VoidCallback onSeeStats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stats = library;
    final summary = surprise;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (stats != null) ...[
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
        ],
        if (summary != null) ...[
          YouSurpriseSummary(summary: summary),
          const SizedBox(height: AppSpacing.lg),
        ],
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
