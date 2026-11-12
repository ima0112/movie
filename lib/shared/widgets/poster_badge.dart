import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// A small pill laid over a poster's corner: an optional amber [icon] and a
/// [label] — "NEW", "★ 8.7". Amber-filled when [amber], else a dark scrim so
/// it reads on any artwork. Decorative; carries no touch handling.
class PosterBadge extends StatelessWidget {
  const PosterBadge({
    super.key,
    required this.label,
    this.icon,
    this.amber = false,
  });

  /// "★ 8.7": the rating, with the star.
  const PosterBadge.rating({super.key, required this.label})
    : icon = AppIcons.starFill,
      amber = false;

  final String label;
  final IconData? icon;
  final bool amber;

  static const double _iconSize = 12;

  @override
  Widget build(BuildContext context) {
    final background = amber
        ? AppColors.accent
        : AppColors.surface.withValues(alpha: 0.72);
    final foreground = amber ? AppColors.onAccent : AppColors.ink;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: _iconSize,
              color: amber ? AppColors.onAccent : AppColors.accent,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          // Shrinks (with an ellipsis) instead of overflowing a narrow poster
          // or a large text scale.
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.captionStrong.copyWith(color: foreground),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
