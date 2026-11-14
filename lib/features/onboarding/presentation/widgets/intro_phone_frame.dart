import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// The amber-outlined phone the intro slides draw their mock screens in
/// ([child] is the mock). Drawn at the design's fixed 250×640; `IntroVisual`
/// scales it to the screen and fades the rest out.
class IntroPhoneFrame extends StatelessWidget {
  const IntroPhoneFrame({super.key, required this.child});

  final Widget child;

  static const double width = 250;
  static const double height = 640;
  static const double _radius = 38;
  static const double _border = 3;
  static const double _glowAlpha = 0.25;

  @override
  Widget build(BuildContext context) {
    // Decorative illustration: not part of the accessibility tree.
    return ExcludeSemantics(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: AppColors.accent, width: _border),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: _glowAlpha),
              blurRadius: 40,
            ),
          ],
        ),
        // Clipped with the radius *inside* the border: clipping with the outer
        // one let the mock's square corners paint over the amber stroke.
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_radius - _border),
          child: child,
        ),
      ),
    );
  }
}
