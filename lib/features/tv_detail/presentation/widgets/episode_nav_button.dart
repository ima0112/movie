import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// "‹ Previous" / "Next · E2 ›" at the foot of the episode sheet: an outlined
/// pill with a chevron on the side it goes. With a null [onTap] it is dimmed
/// and does nothing (the first episode's Previous, the last one's Next).
class EpisodeNavButton extends StatelessWidget {
  const EpisodeNavButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.forward,
  });

  final String label;
  final VoidCallback? onTap;

  /// `true` puts the chevron after the label (Next), `false` before it.
  final bool forward;

  static const double height = 48;
  static const double _iconSize = 20;
  static const double _disabledOpacity = 0.3;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final chevron = Icon(
      forward ? AppIcons.chevronRight : AppIcons.chevronLeft,
      size: _iconSize,
      color: AppColors.ink,
    );
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : _disabledOpacity,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              border: Border.all(color: AppColors.lineStrong),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!forward) ...[
                  chevron,
                  const SizedBox(width: AppSpacing.sm),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyStrong,
                  ),
                ),
                if (forward) ...[const SizedBox(width: AppSpacing.sm), chevron],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
