import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// The "P" monogram: PakoTV's brand mark now that the app has no mascot
/// (see the "Marca sin Pako" design). An amber rounded square with a
/// Manrope "P", proportional at any [size].
class AppMonogram extends StatelessWidget {
  const AppMonogram({super.key, this.size = 104});

  final double size;

  // Proportions taken from the design (104 px: 26 px radius, 64 px glyph).
  static const double _radiusRatio = 0.25;
  static const double _glyphRatio = 0.615;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(size * _radiusRatio),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.28),
              blurRadius: size * 0.38,
              offset: Offset(0, size * 0.115),
            ),
          ],
        ),
        // CLAUDE.md: brand glyph, never translated.
        child: Text(
          'P', // l10n-exempt: brand-name
          style: AppTextStyles.h1.copyWith(
            fontSize: size * _glyphRatio,
            height: 1,
            color: AppColors.onAccent,
          ),
        ),
      ),
    );
  }
}
