import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../l10n/l10n_extension.dart';

/// The Match button: an amber circle with a sparkle, centered on the
/// floating tab bar. Tapping it opens the Match hub (B3) as a modal.
///
/// Source of truth: the "Barra inferior flotante" design (56 px amber
/// circle, sparkle icon, soft amber glow) and `docs/SCREENS.md` section B.
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter.
class MatchFab extends StatelessWidget {
  const MatchFab({super.key, this.hasActiveRoom = false, this.onTap});

  /// Shows the small white dot, top right, when a Matcher room is active.
  final bool hasActiveRoom;
  final VoidCallback? onTap;

  /// The button's own diameter — `app_tab_bar.dart` reserves a center gap
  /// wide enough for it.
  static const double diameter = 56;

  static const double _iconSize = 26;
  static const double _dotSize = 14;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.navMatchButton,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: diameter,
          height: diameter,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    AppIcons.match,
                    size: _iconSize,
                    color: AppColors.onAccent,
                  ),
                ),
              ),
              if (hasActiveRoom)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: _dotSize,
                    height: _dotSize,
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
