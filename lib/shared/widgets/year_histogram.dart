import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// A row of bars, one per [width]-year bucket from [minYear] (see
/// `yearBuckets`): the bars whose years fall inside the chosen [from]–[to]
/// range are amber, the rest `surfaceRaised2`. Heights scale to the fullest
/// bucket; an empty bucket is a short stub so the row always reads as a
/// whole span.
///
/// Pure presentation — everything comes in by parameter.
class YearHistogram extends StatelessWidget {
  const YearHistogram({
    super.key,
    required this.counts,
    required this.minYear,
    required this.from,
    required this.to,
    this.width = 2,
    this.height = 64,
  });

  final List<int> counts;
  final int minYear;
  final int from;
  final int to;
  final int width;
  final double height;

  static const double _stub = AppSpacing.xs;

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
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _inRange(i) ? AppColors.accent : AppColors.line,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusSm / 2,
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: count == 0 || max == 0
                          ? _stub
                          : (height * count / max).clamp(_stub * 2, height),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Whether bucket [i] overlaps the chosen range.
  bool _inRange(int i) {
    final first = minYear + i * width;
    final last = first + width - 1;
    return last >= from && first <= to;
  }
}
