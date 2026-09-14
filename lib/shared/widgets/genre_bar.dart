import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Horizontal bar row for "Genres you watch most": a label on the left, an
/// amber bar sized relative to the top genre's count, and the count on
/// the right.
///
/// Source of truth: `docs/DESIGN_SYSTEM.md` section 5.6 and
/// `docs/SCREENS.md` C4 ("'Genres you watch most': list of 5 horizontal
/// bars with name and count.").
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter.
class GenreBar extends StatelessWidget {
  const GenreBar({
    super.key,
    required this.label,
    required this.count,
    required this.maxCount,
    this.labelWidth = 88,
  });

  final String label;
  final int count;

  /// The top genre's count in the list — this bar's width is
  /// `count / maxCount`, so the most-watched genre fills the full track.
  final int maxCount;

  /// Fixed width for [label] so a list of bars lines up.
  final double labelWidth;

  static const double _barHeight = AppSpacing.sm;

  @override
  Widget build(BuildContext context) {
    final fraction = maxCount <= 0 ? 0.0 : (count / maxCount).clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: labelWidth,
          child: Text(
            label,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.ink),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Stack(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: const SizedBox(height: _barHeight),
              ),
              FractionallySizedBox(
                widthFactor: fraction,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusPill,
                    ),
                  ),
                  child: const SizedBox(height: _barHeight),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$count',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
        ),
      ],
    );
  }
}
