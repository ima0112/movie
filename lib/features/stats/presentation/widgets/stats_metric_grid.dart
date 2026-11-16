import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/number_format_extension.dart';
import '../../../../shared/widgets/metric_card.dart';
import '../../../../core/domain/stats/library_stats.dart';

/// C4's "Four metric cards in a 2×2 grid: Movies watched · Hours of
/// movies · TV shows watched · Estimated TV hours" (`docs/SCREENS.md`
/// C4). Reuses [MetricCard] as-is — this widget is just the 2×2
/// arrangement and C4's own value formatting.
///
/// A plain `Column`/`Row` grid, not `GridView`: four fixed cards with no
/// scrolling of their own (they sit inside C4's overall scroll), so a
/// `GridView`'s aspect-ratio bookkeeping would be solving a problem this
/// layout doesn't have.
///
/// Pure presentation — no Cubit here; the screen that assembles C4 reads
/// `StatsCubit`'s state and passes `stats` in.
class StatsMetricGrid extends StatelessWidget {
  const StatsMetricGrid({super.key, required this.stats});

  final LibraryStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                value: stats.moviesWatched.localizedCount(l10n),
                label: l10n.statsMoviesWatchedLabel,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: MetricCard(
                value: _hours(stats.movieHours, l10n),
                label: l10n.statsHoursOfMoviesLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                value: stats.tvShowsWatched.localizedCount(l10n),
                label: l10n.statsTvShowsWatchedLabel,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: MetricCard(
                value: _hours(stats.estimatedTvHours, l10n),
                label: l10n.statsEstimatedTvHoursLabel,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // MetricCard's own doc comment gives "312 h" as its example format
  // for an hours value — matched here rather than a bare number.
  static String _hours(double hours, AppLocalizations l10n) =>
      l10n.statsHoursValue(hours.round().localizedCount(l10n));
}
