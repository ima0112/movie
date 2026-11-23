import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// A row of big numbers with their labels under them, split by hairline
/// dividers — the look of You's stats card's strips (the library's four, and
/// Surprise me's two). Each entry is `(value, label)`, already localized.
class YouMetricRow extends StatelessWidget {
  const YouMetricRow({super.key, required this.metrics});

  final List<(String value, String label)> metrics;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          for (final (i, (value, label)) in metrics.indexed) ...[
            if (i > 0)
              const VerticalDivider(
                width: 1,
                thickness: 1,
                color: AppColors.line,
              ),
            Expanded(
              child: _Metric(value: value, label: label),
            ),
          ],
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: AppTextStyles.h1),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
        ),
      ],
    );
  }
}
