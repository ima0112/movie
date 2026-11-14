import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n_extension.dart';

/// Persistent thin "Offline" banner.
///
/// Source of truth: `docs/SCREENS.md` G ("Offline: persistent top banner
/// 'Offline' + screens use local data when available."). Uses a neutral
/// treatment (`surfaceRaised2` / `inkMuted`) rather than `danger` — being
/// offline isn't an error here, the app keeps working from cached data.
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter (there are none: the copy is fixed by the doc above).
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  static const double _height = 48;
  static const double _iconSize = 18;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: _height),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised2,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.lineStrong),
      ),
      child: Row(
        children: [
          const Icon(
            AppIcons.wifiOff,
            size: _iconSize,
            color: AppColors.inkMuted,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              context.l10n.offlineBannerMessage,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
            ),
          ),
        ],
      ),
    );
  }
}
