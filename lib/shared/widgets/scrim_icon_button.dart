import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'scrim_back_button.dart';

/// A translucent 40 px circle with one icon, top right — the detail screens'
/// action over the image (Share on D1/D2, Save on D3), the same circle as
/// [ScrimBackButton]. Drop it into a `Stack` like the back button: [Align]
/// and [SafeArea] keep it clear of the notch. [label] is its accessibility
/// label; [selected] marks a toggle that is on (and tints the icon amber).
class ScrimIconButton extends StatelessWidget {
  const ScrimIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// `null` for a plain button; otherwise whether the toggle is on.
  final bool? selected;

  static const double _iconSize = 20;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: SafeArea(
        child: Padding(
          // Lines up with the screen's content margin.
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenMargin,
            vertical: AppSpacing.lg,
          ),
          child: Semantics(
            button: true,
            toggled: selected,
            excludeSemantics: true,
            label: label,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: ScrimBackButton.diameter,
                height: ScrimBackButton.diameter,
                decoration: const BoxDecoration(
                  color: ScrimBackButton.scrim,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: selected == true ? AppColors.accent : AppColors.ink,
                  size: _iconSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
