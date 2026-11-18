import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../l10n/l10n_extension.dart';

/// The line under the deck — a touch icon and "Double-tap to choose", centred,
/// in the accent colour. Text, not a button; it stays for good (the first-time
/// "2×" overlay goes away, this does not).
class SurpriseHelpRow extends StatelessWidget {
  const SurpriseHelpRow({super.key});

  static const double _iconSize = 18;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const ExcludeSemantics(
          child: Icon(AppIcons.touch, size: _iconSize, color: AppColors.accent),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            context.l10n.surpriseHelpDoubleTap,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.accent),
          ),
        ),
      ],
    );
  }
}
