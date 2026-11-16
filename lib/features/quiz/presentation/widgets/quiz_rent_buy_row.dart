import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';

/// The platforms step's "Include rent and buy" row: a card with the label and
/// a switch. Dimmed and inert while [enabled] is false (no platform picked —
/// there is nothing to rent or buy it on); [value] is kept meanwhile.
class QuizRentBuyRow extends StatelessWidget {
  const QuizRentBuyRow({
    super.key,
    required this.enabled,
    required this.value,
    required this.onChanged,
  });

  final bool enabled;
  final bool value;
  final ValueChanged<bool> onChanged;

  static const double _disabledOpacity = 0.4;

  @override
  Widget build(BuildContext context) {
    final label = context.l10n.quizPlatformRentBuy;
    return Opacity(
      opacity: enabled ? 1 : _disabledOpacity,
      child: DecoratedBox(
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
                onChanged: enabled ? onChanged : null,
                activeThumbColor: AppColors.onAccent,
                activeTrackColor: AppColors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
