import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';

/// The picker for a profile's initial color — `docs/SCREENS.md` H10 / A2 step
/// 1: the six colors of [AppColors.profileColors] (amber, mint, coral, blue,
/// lilac, white) as circles spread across the available width, a check on the
/// selected one.
///
/// Used by both onboarding's name step and "Edit profile" (H10), which share
/// "the same controls". The circles are at most [maxSwatch] wide and shrink (to
/// [minSwatch]) on a narrow screen so the six always fit one row.
class ProfileColorPicker extends StatelessWidget {
  const ProfileColorPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  /// A 32-bit ARGB int — see `UserProfile.initialColor`'s doc comment
  /// for why this is an int, not a `Color`.
  final int? selected;
  final ValueChanged<int> onChanged;

  static const double maxSwatch = 48;
  static const double minSwatch = 32;
  static const double _checkRatio = 0.42;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.profileColors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final gaps = AppSpacing.sm * (colors.length - 1);
        final swatch = math
            .min(maxSwatch, (constraints.maxWidth - gaps) / colors.length)
            .clamp(minSwatch, maxSwatch);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final color in colors)
              Semantics(
                button: true,
                selected: selected == color.toARGB32(),
                child: GestureDetector(
                  onTap: () => onChanged(color.toARGB32()),
                  child: Container(
                    width: swatch,
                    height: swatch,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: selected == color.toARGB32()
                        ? Icon(
                            AppIcons.check,
                            color: AppColors.onAccent,
                            size: swatch * _checkRatio,
                          )
                        : null,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
