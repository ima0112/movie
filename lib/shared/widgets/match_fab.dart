import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'pako_state.dart';

/// The Match button: a raised amber circle with Pako's face, centered in
/// the bottom tab bar. Tapping it opens the Match hub (B3) as a modal.
///
/// Source of truth: `docs/SCREENS.md` section B ("60 px amber circular
/// button raised 14 px in the center with Pako's face... White dot on the
/// button if a room is active.").
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter.
class MatchFab extends StatelessWidget {
  const MatchFab({super.key, this.hasActiveRoom = false, this.onTap});

  /// Shows the small white dot, top right, when a Matcher room is active.
  final bool hasActiveRoom;
  final VoidCallback? onTap;

  /// The button's own diameter — `app_tab_bar.dart` reserves a center gap
  /// this wide so the two line up.
  static const double diameter = 60;

  // Raises the button above the tab bar it sits on.
  static const double _raise = 14;

  // Pako fills most of the circle, with a little breathing room.
  static const double _pakoSize = 40;

  // White dot, top right, when a room is active.
  static const double _dotSize = 14;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -_raise),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: diameter,
          height: diameter,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: PakoState(mood: PakoMood.idle, size: _pakoSize),
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
