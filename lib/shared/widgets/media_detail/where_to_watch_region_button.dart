import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n_extension.dart';

/// The tappable country pill: globe, name and a chevron, so it reads as a
/// control (opens H6).
class WhereToWatchRegionButton extends StatelessWidget {
  const WhereToWatchRegionButton({
    super.key,
    required this.name,
    required this.onTap,
  });

  final String name;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Semantics(
        button: true,
        label: context.l10n.whereToWatchChangeRegion(name),
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            constraints: const BoxConstraints(minHeight: 36),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              border: Border.all(color: AppColors.lineStrong),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(AppIcons.globe, size: 16, color: AppColors.inkMuted),
                const SizedBox(width: AppSpacing.xs + 2),
                Flexible(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmStrong,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  AppIcons.chevronDown,
                  size: 16,
                  color: AppColors.inkMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
