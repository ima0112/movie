import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// E2's "'Step X of 4' indicator" (`docs/SCREENS.md` E2), shown here as
/// 4 equal segments rather than (or alongside) the text — no explicit
/// visual spec exists for this in `docs/DESIGN_SYSTEM.md`'s own
/// component sheet, so this reuses the same "filled = ink, unfilled =
/// lineStrong" treatment already established for other progress-like
/// bars in this codebase (e.g. skeleton blocks' own neutral palette).
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter.
class QuizProgressBar extends StatelessWidget {
  const QuizProgressBar({super.key, required this.currentStep});

  /// 1–4.
  final int currentStep;

  static const int _stepCount = 4;
  static const double _height = 4;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var step = 1; step <= _stepCount; step++) ...[
          if (step > 1) const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: step <= currentStep
                    ? AppColors.ink
                    : AppColors.lineStrong,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
              child: const SizedBox(height: _height),
            ),
          ),
        ],
      ],
    );
  }
}
