import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// The onboarding's pagination dots: [count] dots, the one at [activeIndex]
/// stretched into an amber pill. There is one dot per step after the welcome:
/// the name ([nameDot]), the two intro slides ([introDiscoverDot],
/// [introSurpriseDot]) and the two genre steps ([likedDot], [vetoedDot]) —
/// [total] in all.
///
/// Purely decorative (every step has a real button), so it is excluded from
/// semantics.
class OnboardingPagerDots extends StatelessWidget {
  const OnboardingPagerDots({
    super.key,
    required this.count,
    required this.activeIndex,
  });

  final int count;
  final int activeIndex;

  static const int nameDot = 0;
  static const int introDiscoverDot = 1;
  static const int introSurpriseDot = 2;
  static const int likedDot = 3;
  static const int vetoedDot = 4;
  static const int total = 5;

  static const double _dot = 6;
  static const double _activeWidth = 24;
  static const Duration _animation = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            AnimatedContainer(
              duration: _animation,
              width: i == activeIndex ? _activeWidth : _dot,
              height: _dot,
              decoration: BoxDecoration(
                color: i == activeIndex
                    ? AppColors.accent
                    : AppColors.sheetHandle,
                borderRadius: BorderRadius.circular(_dot / 2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
