import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// A floating callout that overlaps the phone frame in the intro
/// slides — a circle ([IntroBadge.circle]) or a pill ([IntroBadge.pill])
/// on `surface` with an amber outline.
class IntroBadge extends StatelessWidget {
  const IntroBadge.circle({
    super.key,
    required double diameter,
    required this.child,
  }) : width = diameter,
       height = diameter,
       borderWidth = 3;

  const IntroBadge.pill({super.key, required this.height, required this.child})
    : width = null,
      borderWidth = 2;

  /// `null` for a pill, which sizes itself to [child].
  final double? width;
  final double height;
  final double borderWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: width == null
          ? const EdgeInsets.symmetric(horizontal: AppSpacing.lg)
          : null,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: AppColors.accent, width: borderWidth),
      ),
      child: child,
    );
  }
}
