import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/domain/stats/library_insights.dart';
import '../../../../core/domain/stats/stats_period.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/number_format_extension.dart';
import '../../../../shared/widgets/activity_bars.dart';
import '../../../../shared/widgets/type_split_bar.dart';
import 'stats_delta_chip.dart';

/// C4's lead card (`docs/SCREENS.md` C4): the hours watched in large type
/// ("312 h", "≈ 13 days"), the titles count with its comparison to the
/// period before, the activity bars with a caption under each (a month's
/// initial, or the day of the month at the ends and the middle), and the
/// movies / TV split with the hours of each.
///
/// Pure presentation — everything comes in as [insights].
class StatsHeroCard extends StatelessWidget {
  const StatsHeroCard({super.key, required this.insights});

  final LibraryInsights insights;

  static const double _hoursPerDay = 24;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted);
    final days = (insights.totalHours / _hoursPerDay).round();
    final previous = insights.previousCount;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.statsHoursValue(
                          insights.totalHours.round().localizedCount(l10n),
                        ),
                        style: AppTextStyles.display,
                      ),
                      if (days >= 1)
                        Text(l10n.youStatsDaysOfScreen(days), style: muted),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.statsTitlesCount(insights.watchedCount),
                      style: AppTextStyles.h3,
                    ),
                    if (previous != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      StatsDeltaChip(
                        delta: insights.watchedCount - previous,
                        previousLabel: insights.period == StatsPeriod.thisYear
                            ? l10n.statsVsLastYear
                            : l10n.statsVsLastMonth,
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            ActivityBars(
              counts: insights.activity.counts,
              labels: _labels(insights.activity, l10n),
            ),
            const SizedBox(height: AppSpacing.xl),
            TypeSplitBar(
              firstCount: insights.moviesWatched,
              firstLabel:
                  '${l10n.youStatsMovies(insights.moviesWatched)} · '
                  '${_hours(insights.movieHours, l10n)}',
              secondCount: insights.showsWatched,
              secondLabel:
                  '${l10n.youStatsShows(insights.showsWatched)} · '
                  '${_hours(insights.tvHours, l10n)}',
            ),
          ],
        ),
      ),
    );
  }

  static String _hours(double hours, AppLocalizations l10n) =>
      l10n.statsHoursValue(hours.round().localizedCount(l10n));

  /// A caption per bar: each month's initial; or, for days, the day number at
  /// the first, the middle and the last.
  static List<String> _labels(ActivitySeries series, AppLocalizations l10n) {
    final n = series.counts.length;
    switch (series.unit) {
      case ActivityUnit.month:
        return [
          for (var i = 0; i < n; i++)
            DateFormat.MMM(l10n.localeName)
                .format(DateTime(series.start.year, series.start.month + i))
                .characters
                .first
                .toUpperCase(),
        ];
      case ActivityUnit.day:
        return [
          for (var i = 0; i < n; i++)
            (i == 0 || i == n ~/ 2 || i == n - 1) ? '${i + 1}' : '',
        ];
    }
  }
}
