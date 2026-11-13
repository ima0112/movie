import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// A chip's visual state.
///
/// Source of truth: `docs/DESIGN_SYSTEM.md` section 5.2 ("Chip — default /
/// seleccionado (fondo accent) / con borde punteado (sugerencia)").
enum ChipState {
  /// Unselected: `surfaceRaised` fill with a `lineStrong` border.
  normal,

  /// Selected: a dark amber tint ([AppColors.accentSoft]) with an amber
  /// hairline ([AppColors.accentLine]) and `accent` text/icon.
  selected,

  /// Dashed `lineStrong` border, no fill — a suggestion the user can tap
  /// to add (e.g. a suggested genre).
  suggestion,

  /// An avoided option (C5's "Genres you never want"): `danger` border
  /// and tint, struck-through semibold label.
  vetoed,
}

/// Generic chip used for genres, recent searches, and active filters.
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.state = ChipState.normal,
    this.onTap,
    this.icon,
    this.trailingIcon,
    this.leading,
  });

  final String label;
  final ChipState state;
  final VoidCallback? onTap;
  final IconData? icon;

  /// An icon after the label — the "×" of a removable active-filter chip.
  final IconData? trailingIcon;

  /// A widget before the label — a streaming service's logo.
  final Widget? leading;

  // docs/DESIGN_SYSTEM.md section 4: "20: chips, campos, elementos
  // secundarios" — an icon size, not part of the AppSpacing scale.
  static const double _iconSize = 20;
  static const double _vetoedTint = 0.16;

  @override
  Widget build(BuildContext context) {
    final isSelected = state == ChipState.selected;
    final isVetoed = state == ChipState.vetoed;
    final textColor = isSelected ? AppColors.accent : AppColors.ink;

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.sm),
          ],
          if (icon != null) ...[
            Icon(icon, size: _iconSize, color: textColor),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style:
                (isVetoed ? AppTextStyles.captionStrong : AppTextStyles.caption)
                    .copyWith(
                      color: textColor,
                      decoration: isVetoed ? TextDecoration.lineThrough : null,
                      decorationColor: textColor,
                    ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(trailingIcon, size: _iconSize, color: textColor),
          ],
        ],
      ),
    );

    final chip = switch (state) {
      ChipState.normal => DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(color: AppColors.lineStrong),
        ),
        child: content,
      ),
      ChipState.selected => DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.accentSoft,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(color: AppColors.accentLine),
        ),
        child: content,
      ),
      ChipState.vetoed => DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: _vetoedTint),
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(color: AppColors.danger),
        ),
        child: content,
      ),
      ChipState.suggestion => CustomPaint(
        painter: const _DashedBorderPainter(
          color: AppColors.lineStrong,
          radius: AppSpacing.radiusPill,
        ),
        child: content,
      ),
    };

    return GestureDetector(onTap: onTap, child: chip);
  }
}

/// Paints a dashed rounded-rect border — Flutter has no built-in dashed
/// `BoxBorder`, and we'd rather draw one than pull in a dependency for it.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const double _strokeWidth = 1;
  static const double _dashWidth = 4;
  static const double _gapWidth = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    ).deflate(_strokeWidth / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;

    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + _dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + _gapWidth;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
