import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// A small bar chart of [counts] (one bar per value, oldest first) — You's
/// "last 12 months". Bars scale to the largest count; an empty month is a
/// short `surfaceRaised2` stub so the row still reads as twelve, and the last
/// bar (the current period) is the brightest.
///
/// Pure presentation — everything comes in by parameter.
class ActivityBars extends StatelessWidget {
  const ActivityBars({
    super.key,
    required this.counts,
    this.height = 56,
    this.labels,
  });

  final List<int> counts;
  final double height;

  /// A caption under each bar (same length as [counts]; an empty string for
  /// none), drawn in a row that lines up with the bars. `null` draws none.
  final List<String>? labels;

  static const double _stub = AppSpacing.xs;
  static const double _pastIntensity = 0.5;

  @override
  Widget build(BuildContext context) {
    final max = counts.fold<int>(0, (a, b) => a > b ? a : b);
    final bars = SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (i, count) in counts.indexed)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                child: _Bar(
                  fraction: max == 0 ? 0 : count / max,
                  height: height,
                  isCurrent: i == counts.length - 1,
                  isEmpty: count == 0,
                ),
              ),
            ),
        ],
      ),
    );
    final captions = labels;
    if (captions == null) return bars;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        bars,
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            for (final label in captions)
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  softWrap: false,
                  style: AppTextStyles.micro.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.fraction,
    required this.height,
    required this.isCurrent,
    required this.isEmpty,
  });

  final double fraction;
  final double height;
  final bool isCurrent;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    final barHeight = isEmpty
        ? ActivityBars._stub
        : (height * fraction).clamp(ActivityBars._stub * 2, height);
    return Align(
      alignment: Alignment.bottomCenter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isEmpty
              ? AppColors.surfaceRaised2
              : AppColors.accent.withValues(
                  alpha: isCurrent ? 1 : ActivityBars._pastIntensity,
                ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm / 2),
        ),
        child: SizedBox(height: barHeight, width: double.infinity),
      ),
    );
  }
}
