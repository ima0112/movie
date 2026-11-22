import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/domain/stats/surprise_insights.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../l10n/l10n_extension.dart';
import '../../../../../shared/widgets/activity_bars.dart';
import 'surprise_stat_card.dart';

/// "Your rhythm": sessions per month (the last 12), per day of the week, and
/// the weekly streak.
class SurpriseHabitCard extends StatelessWidget {
  const SurpriseHabitCard({super.key, required this.habit});

  final SurpriseHabit habit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String initial(DateFormat f, DateTime d) =>
        f.format(d).characters.first.toUpperCase();
    final monthFormat = DateFormat.MMM(l10n.localeName);
    final weekdayFormat = DateFormat.E(l10n.localeName);
    // A Monday, to name the weekdays from.
    final monday = DateTime(2024, 1, 1);
    return SurpriseStatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.statsSurpriseByMonth, style: AppTextStyles.bodySm),
          const SizedBox(height: AppSpacing.md),
          ActivityBars(
            counts: [for (final (_, n) in habit.byMonth) n],
            labels: [
              for (final (m, _) in habit.byMonth) initial(monthFormat, m),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.statsSurpriseByWeekday, style: AppTextStyles.bodySm),
          const SizedBox(height: AppSpacing.md),
          ActivityBars(
            counts: habit.byWeekday,
            labels: [
              for (var i = 0; i < 7; i++)
                initial(
                  weekdayFormat,
                  DateTime(monday.year, monday.month, monday.day + i),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.statsSurpriseStreak(habit.weeklyStreak),
            style: AppTextStyles.bodySmStrong,
          ),
          if (habit.bestWeeklyStreak > habit.weeklyStreak)
            Text(
              l10n.statsBestStreak('${habit.bestWeeklyStreak}'),
              style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
            ),
        ],
      ),
    );
  }
}
