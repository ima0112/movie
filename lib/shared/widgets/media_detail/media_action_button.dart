import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// One toggle of [MediaDetailActionRow] — D1/D2 both use it unchanged
/// (`docs/SCREENS.md`). A 44 px bordered rounded box: icon-only (a square,
/// for Favorite / Watch later) or, with [showLabel], a wide button with the
/// icon and a label (for Watched), as in the "Detalle" designs. Active =
/// filled icon and amber, outline = `ink`. Icon-only buttons keep their
/// [label] as the accessibility label.
class MediaActionButton extends StatelessWidget {
  const MediaActionButton({
    super.key,
    required this.iconOutline,
    required this.iconFill,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.showLabel = false,
  });

  final IconData iconOutline;
  final IconData iconFill;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool showLabel;

  static const double size = 44;
  static const double _iconSize = 20;
  static const double _activeTint = 0.14;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.accent : AppColors.ink;
    final icon = Icon(
      isActive ? iconFill : iconOutline,
      size: _iconSize,
      color: color,
    );
    return Semantics(
      button: true,
      toggled: isActive,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: size,
          width: showLabel ? null : size,
          padding: showLabel
              ? const EdgeInsets.symmetric(horizontal: AppSpacing.md)
              : null,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // Active = amber border on a faint amber tint (the "Vista"
            // state in the Detalle designs).
            color: isActive
                ? AppColors.accent.withValues(alpha: _activeTint)
                : null,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isActive ? AppColors.accent : AppColors.lineStrong,
            ),
          ),
          child: showLabel
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon,
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                )
              : icon,
        ),
      ),
    );
  }
}
