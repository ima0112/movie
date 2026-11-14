import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// A small bar chart of [counts] (one bar per value, oldest first) — You's
/// "last 12 months". Bars scale to the largest count; an empty month is a
/// short `surfaceRaised2` stub so the row still reads as twelve, and the last
/// bar (the current period) is the brightest.
///
/// Pure presentation — everything comes in by parameter.
class ActivityBars extends StatelessWidget {
  const ActivityBars({super.key, required this.counts, this.height = 56});

  final List<int> counts;
  final double height;

  static const double _stub = AppSpacing.xs;
  static const double _pastIntensity = 0.5;

  @override
  Widget build(BuildContext context) {
    final max = counts.fold<int>(0, (a, b) => a > b ? a : b);
    return SizedBox(
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
