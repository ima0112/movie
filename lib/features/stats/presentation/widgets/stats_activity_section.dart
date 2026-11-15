import 'package:flutter/material.dart';

import '../../../../core/domain/stats/library_insights.dart';
import '../../../../core/domain/stats/stats_period.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/activity_calendar.dart';
import '../../../../shared/widgets/app_section.dart';

/// C4's "Activity": a calendar card of the period — the last 26 weeks (all
/// time), the weeks of this year, or the days of this month — each day shaded
/// by how many titles were watched, with a Less → More legend
/// (`docs/SCREENS.md` C4).
///
/// Pure presentation — everything comes in as [insights] ([today] anchors
/// which days are in the future).
class StatsActivitySection extends StatelessWidget {
  const StatsActivitySection({
    super.key,
    required this.insights,
    required this.today,
  });

  final LibraryInsights insights;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final period = insights.period;
    return AppSection(
      title: l10n.statsActivityTitle,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ActivityCalendar(
                start: insights.calendarStart,
                end: insights.calendarEnd,
                today: today,
                dayCounts: insights.dayCounts,
                dense: period != StatsPeriod.thisMonth,
                monthLabelLength: period == StatsPeriod.thisYear ? 1 : 3,
              ),
              const SizedBox(height: AppSpacing.lg),
              const _Legend(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  static const double _swatch = 12;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = AppTextStyles.caption.copyWith(color: AppColors.inkMuted);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(l10n.statsActivityLess, style: muted),
        const SizedBox(width: AppSpacing.sm),
        for (final count in [0, 1, 2, 3]) ...[
          DecoratedBox(
            decoration: BoxDecoration(
              color: activityCellColor(count),
              borderRadius: BorderRadius.circular(AppSpacing.xxs),
            ),
            child: const SizedBox(width: _swatch, height: _swatch),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
        const SizedBox(width: AppSpacing.xs),
        Text(l10n.statsActivityMore, style: muted),
      ],
    );
  }
}
