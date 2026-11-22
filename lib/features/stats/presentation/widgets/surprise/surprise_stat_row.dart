import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// A label on the left and its value on the right, on one line that gives way
/// (the label wraps) at a large text size.
class SurpriseStatRow extends StatelessWidget {
  const SurpriseStatRow({super.key, required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(child: value),
        ],
      ),
    );
  }
}

/// A [SurpriseStatRow]'s value as text.
class SurpriseStatValue extends StatelessWidget {
  const SurpriseStatValue(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, textAlign: TextAlign.end, style: AppTextStyles.bodySmStrong);
}
