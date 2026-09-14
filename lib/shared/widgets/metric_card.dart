import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Metric card for Stats: a large number over a small label.
///
/// Source of truth: `docs/DESIGN_SYSTEM.md` section 5.6 and
/// `docs/SCREENS.md` C4 ("Four metric cards in a 2×2 grid... 'Your
/// most-watched year': one large number + subtitle.").
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter.
class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.value, required this.label});

  /// The big number, pre-formatted by the caller (e.g. "128", "312 h").
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: AppTextStyles.h1),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
