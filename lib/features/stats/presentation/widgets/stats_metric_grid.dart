import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/metric_card.dart';
import '../../domain/library_stats.dart';

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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                value: '${stats.moviesWatched}',
                label: 'Movies watched',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: MetricCard(
                value: _hours(stats.movieHours),
                label: 'Hours of movies',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                value: '${stats.tvShowsWatched}',
                label: 'TV shows watched',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: MetricCard(
                value: _hours(stats.estimatedTvHours),
                label: 'Estimated TV hours',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // MetricCard's own doc comment gives "312 h" as its example format
  // for an hours value — matched here rather than a bare number.
  static String _hours(double hours) => '${hours.round()} h';
}
