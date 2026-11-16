import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'overline_label.dart';

/// One end of a release range: a rounded card with a small capitalised
/// [label] ("FROM") over the [value] in large type ("2010", "Today").
///
/// Pure presentation — everything comes in by parameter.
class YearBoundCard extends StatelessWidget {
  const YearBoundCard({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.lineStrong),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            OverlineLabel(label),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: AppTextStyles.h1, maxLines: 1),
          ],
        ),
      ),
    );
  }
}
