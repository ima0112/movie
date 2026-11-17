import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../l10n/l10n_extension.dart';

/// The "In Watch later" pill in the top-right corner of the chosen card on the
/// closing screen: a solid amber bookmark and the label, amber on a dark fill
/// with an amber hairline. It says the card is already saved; it is not a
/// button. Pure presentation.
class SurpriseInWatchLaterBadge extends StatelessWidget {
  const SurpriseInWatchLaterBadge({super.key});

  static const double _iconSize = 16;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: AppColors.accentLine),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              AppIcons.watchLaterFill,
              size: _iconSize,
              color: AppColors.accent,
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                context.l10n.surpriseChosenInWatchLater,
                style: AppTextStyles.bodySmStrong.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
