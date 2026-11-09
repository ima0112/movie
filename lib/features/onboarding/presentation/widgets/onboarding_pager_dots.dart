import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// The intro slides' pagination dots: [count] dots, the one at
/// [activeIndex] stretched into an amber pill.
///
/// Purely decorative (the slides have a real "Next" button), so it is
/// excluded from semantics.
class OnboardingPagerDots extends StatelessWidget {
  const OnboardingPagerDots({
    super.key,
    required this.count,
    required this.activeIndex,
  });

  final int count;
  final int activeIndex;

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
