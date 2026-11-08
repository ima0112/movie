import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';

/// The 4-color picker for a profile's initial — `docs/SCREENS.md` H10 /
/// A2 step 1: "typing reveals a circular initial and a 4-color picker
/// (amber, coral, mint, lilac)". [AppColors.profileColors] is exactly
/// that fixed 4-value, ordered palette.
///
/// Lives in `shared/widgets/`, not under `features/you/`, because H10
/// and onboarding step 1 use "the same controls" (H10's own doc entry)
/// — this is one of them, built for H10 first and meant to be reused
/// as-is once onboarding exists, not duplicated.
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

  static const double _swatchSize = 40;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final color in AppColors.profileColors)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: GestureDetector(
              onTap: () => onChanged(color.toARGB32()),
              child: Container(
                width: _swatchSize,
                height: _swatchSize,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: selected == color.toARGB32()
                    ? const Icon(
                        AppIcons.check,
                        color: AppColors.onAccent,
                        size: 20,
                      )
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}
