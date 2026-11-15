import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/domain/stats/library_insights.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_section.dart';
import 'stats_disagreements.dart';

/// C4's "Your ratings": the average with TMDB's beside it, how far the user
/// rates from TMDB, a 5★→1★ histogram and, when any, the titles rated
/// furthest from TMDB. Absent when nothing in the period is rated
/// (`docs/SCREENS.md` C4). Pure presentation.
class StatsRatingsSection extends StatelessWidget {
  const StatsRatingsSection({super.key, required this.insights});

  final LibraryInsights insights;

  @override
  Widget build(BuildContext context) {
    final average = insights.averageRating;
    if (average == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final fmt = NumberFormat('0.0', locale);
    final gap = insights.ratingGap;
    final tmdb = insights.tmdbAverage;
    final muted = AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted);
    return AppSection(
      title: l10n.statsRatingsTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        AppIcons.starFill,
                        color: AppColors.accent,
                        size: AppSpacing.xxl,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.statsRatingAverage(fmt.format(average)),
                          style: AppTextStyles.h3,
                        ),
                      ),
                      if (tmdb != null)
                        Text(
                          l10n.statsRatingTmdb(fmt.format(tmdb)),
                          style: muted,
                        ),
                    ],
                  ),
                  if (gap != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(_gapText(gap, fmt, context), style: muted),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  _Histogram(counts: insights.ratingCounts),
                ],
              ),
            ),
          ),
          if (insights.disagreements.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.cardGap),
            StatsDisagreements(disagreements: insights.disagreements),
          ],
        ],
      ),
    );
  }

  static String _gapText(double gap, NumberFormat fmt, BuildContext context) {
    final l10n = context.l10n;
    if (gap.abs() < 0.1) return l10n.statsRatingInLine;
    final text = fmt.format(gap.abs());
    return gap > 0 ? l10n.statsRatingHigher(text) : l10n.statsRatingLower(text);
  }
}

/// Five rows, 5★ on top: the star count, a bar scaled to the fullest row and
/// the number of titles.
class _Histogram extends StatelessWidget {
  const _Histogram({required this.counts});

  final List<int> counts;

  static const double _barHeight = AppSpacing.sm;

  @override
  Widget build(BuildContext context) {
    final max = counts.fold<int>(0, (a, b) => a > b ? a : b);
    final muted = AppTextStyles.caption.copyWith(color: AppColors.inkMuted);
    return Column(
      children: [
        for (var stars = 5; stars >= 1; stars--)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                SizedBox(
                  width: AppSpacing.lg,
                  child: Text('$stars', style: muted),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final n = counts[stars - 1];
                      final w = max == 0 ? 0.0 : c.maxWidth * n / max;
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: n == 0
                                ? AppColors.surfaceRaised2
                                : AppColors.accent,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusPill,
                            ),
                          ),
                          child: SizedBox(
                            width: n == 0 ? _barHeight : w,
                            height: _barHeight,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: AppSpacing.xxxl,
                  child: Text(
                    '${counts[stars - 1]}',
                    textAlign: TextAlign.end,
                    style: muted,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
