import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';

/// C4's "'Activity over the last 12 months': strip of 12 cells with
/// intensity" (`docs/SCREENS.md` C4). No existing shared widget for
/// this shape, so built fresh here.
///
/// Each cell's opacity scales with its count relative to the busiest
/// month in [monthlyActivity] (`LibraryStats.monthlyActivity` — already
/// oldest-first, ending at the current month, so this widget doesn't
/// need to know today's date at all). Amber (`AppColors.accent`) is the
/// intensity color: DESIGN_SYSTEM.md's closed list of where the accent
/// is allowed explicitly names "bars and cells of Estadísticas".
///
/// Pure presentation — no Cubit here; the screen that assembles C4 reads
/// `StatsCubit`'s state and passes `stats.monthlyActivity` in.
class StatsActivityStrip extends StatelessWidget {
  const StatsActivityStrip({super.key, required this.monthlyActivity})
    : assert(
        monthlyActivity.length == 12,
        'monthlyActivity must have exactly 12 values',
      );

  final List<int> monthlyActivity;

  @override
  Widget build(BuildContext context) {
    final maxCount = monthlyActivity.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.statsActivityStripTitle, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            for (final count in monthlyActivity)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _cellColor(count, maxCount),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  static Color _cellColor(int count, int maxCount) {
    if (maxCount == 0 || count == 0) return AppColors.surfaceRaised;
    // Floor of 0.15 so a low-but-nonzero month still reads as "some
    // activity" against the empty-cell background, not near-invisible.
    final intensity = (count / maxCount).clamp(0.15, 1.0);
    return AppColors.accent.withValues(alpha: intensity);
  }
}
