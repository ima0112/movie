import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n_extension.dart';

/// The "No internet connection" banner (`docs/SCREENS.md` G): a rounded box in
/// the amber tint with a hairline, a wifi-off icon and the message in amber —
/// a notice that the app is working from what it has, not an error.
///
/// Pure presentation — the copy is fixed. `OfflineBannerSlot` decides when it
/// shows.
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
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.accentLine),
      ),
      child: Row(
        children: [
          const Icon(
            AppIcons.wifiOff,
            size: _iconSize,
            color: AppColors.accent,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              context.l10n.offlineBannerMessage,
              style: AppTextStyles.bodySmToggle(
                true,
              ).copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}
