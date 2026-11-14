import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// A thin two-part bar — how much of the whole is [first] and how much
/// [second] (You's movies vs TV shows) — with a legend under it. A part with
/// nothing in it takes no room; with both empty, nothing is drawn.
///
/// Pure presentation — the labels arrive formatted ("38 movies").
class TypeSplitBar extends StatelessWidget {
  const TypeSplitBar({
    super.key,
    required this.firstCount,
    required this.firstLabel,
    required this.secondCount,
    required this.secondLabel,
  });

  final int firstCount;
  final String firstLabel;
  final int secondCount;
  final String secondLabel;

  static const double _barHeight = AppSpacing.sm;

  @override
  Widget build(BuildContext context) {
    if (firstCount + secondCount == 0) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: SizedBox(
            height: _barHeight,
            child: Row(
              children: [
                if (firstCount > 0)
                  Expanded(
                    flex: firstCount,
                    child: const ColoredBox(color: AppColors.accent),
                  ),
                if (firstCount > 0 && secondCount > 0)
                  const SizedBox(width: AppSpacing.xxs),
                if (secondCount > 0)
                  Expanded(
                    flex: secondCount,
                    child: const ColoredBox(color: AppColors.inkMuted),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _Legend(color: AppColors.accent, label: firstLabel),
            const SizedBox(width: AppSpacing.lg),
            _Legend(color: AppColors.inkMuted, label: secondLabel),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  static const double _dot = AppSpacing.sm;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: const SizedBox(width: _dot, height: _dot),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
        ),
      ],
    );
  }
}
