import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/comet_border.dart';
import 'taste_card_posters.dart';

/// The look of B1's taste card (`docs/SCREENS.md` B1): a dark card with a soft
/// amber glow in its top-left corner; on the left a "FOR YOU" eyebrow, the
/// title and the one action — the button; on the right three tilted posters; and
/// an amber comet running round its border (a lap every 5 s, still with reduce
/// motion). The card itself isn't tappable: the button is the action.
class DiscoverTasteCardBody extends StatelessWidget {
  const DiscoverTasteCardBody({super.key, required this.onPickTastes});

  final VoidCallback onPickTastes;

  static const double _radius = AppSpacing.radiusXl;
  static const double _sparkle = 14;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CometBorder(
      radius: _radius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: AppColors.lineStrong),
          color: AppColors.surfaceRaised,
          // The soft amber glow in the top-left corner, fading into the dark.
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.1,
            colors: [
              AppColors.accentDeep.withValues(alpha: 0.75),
              AppColors.surfaceRaised.withValues(alpha: 0),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          AppIcons.match,
                          size: _sparkle,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            l10n.discoverTasteCardEyebrow.toUpperCase(),
                            style: AppTextStyles.overline.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(l10n.discoverTasteCardTitle, style: AppTextStyles.h2),
                    const SizedBox(height: AppSpacing.lg),
                    PrimaryButton(
                      label: l10n.discoverTasteCardCta,
                      fullWidth: false,
                      onTap: onPickTastes,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const TasteCardPosters(),
            ],
          ),
        ),
      ),
    );
  }
}
