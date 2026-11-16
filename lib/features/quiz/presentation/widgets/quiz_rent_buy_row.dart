import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';

/// The platforms step's "Include rent and buy" row: a card with the label and
/// a switch — on the picked services, or on any service of the region while
/// "All platforms" is on.
class QuizRentBuyRow extends StatelessWidget {
  const QuizRentBuyRow({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = context.l10n.quizPlatformRentBuy;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.lineStrong),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPadding,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppTextStyles.bodySm)),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.onAccent,
              activeTrackColor: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }
}
