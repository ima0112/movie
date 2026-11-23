import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// The small amber "JustWatch" badge at the foot of the Where-to-watch card,
/// next to the hint line. Decorative: it isn't tappable (the services are), and
/// it ignores the system's text scale (a small fixed badge, so the hint beside
/// it keeps the room at large text).
class JustWatchBadge extends StatelessWidget {
  const JustWatchBadge({super.key});

  static const double _height = 28;
  static const double _iconSize = 12;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withNoTextScaling(
      child: Container(
        height: _height,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: AppColors.accentSoft,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(AppIcons.play, size: _iconSize, color: AppColors.accent),
            const SizedBox(width: AppSpacing.xs + 2),
            Text(
              'JustWatch', // l10n-exempt: brand-name
              style: AppTextStyles.captionStrong.copyWith(
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
