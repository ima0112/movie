import 'package:flutter/material.dart';

import '../../../../core/domain/stats/library_stats.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';

/// The short lines under the numbers: the hours as days of screen time
/// ("≈ 13 days", from a full day on), the weekly streak ("3 weeks streak")
/// and this month's count ("4 this month"). Each shows only when it has
/// something to say; with none, nothing is drawn.
class YouStatsInsights extends StatelessWidget {
  const YouStatsInsights({super.key, required this.stats});

  final LibraryStats stats;

  static const double _hoursPerDay = 24;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final days = (stats.totalHours / _hoursPerDay).round();
    final insights = [
      if (days >= 1) (AppIcons.history, l10n.youStatsDaysOfScreen(days)),
      if (stats.weeklyStreak >= 1)
        (AppIcons.streak, l10n.youStatsStreak(stats.weeklyStreak)),
      if (stats.watchedThisMonth >= 1)
        (AppIcons.calendar, l10n.youStatsThisMonth(stats.watchedThisMonth)),
    ];
    if (insights.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.sm,
      children: [
        for (final (icon, text) in insights)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.inkMuted),
              const SizedBox(width: AppSpacing.xs),
              Text(
                text,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.inkMuted,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
