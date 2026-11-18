import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';

/// The two round bubbles at the deck's edges, mostly off screen — just enough
/// shows for the whole icon to be seen. **Left: Save** (a bookmark); **right:
/// Next** (an arrow). They hint at the gestures and never take a touch
/// ([IgnorePointer]).
///
/// At rest each is a dark disc with a hairline border and an outline icon.
/// While a card is dragged toward a side, that side's bubble slides further in
/// and changes with [saveProgress] / [nextProgress] (0 at rest → 1 where
/// releasing would confirm):
/// - **Save** loses its border, gains an amber halo, fills with amber, and its
///   bookmark turns solid and dark;
/// - **Next** loses its border and becomes solid, its arrow staying white.
/// With [showNext] false (a one-card deck, nowhere to go) the right bubble is
/// left out.
class SurpriseEdgeBubbles extends StatelessWidget {
  const SurpriseEdgeBubbles({
    super.key,
    this.saveProgress = 0,
    this.nextProgress = 0,
    this.showNext = true,
  });

  final double saveProgress;
  final double nextProgress;
  final bool showNext;

  static const double size = 112;

  /// How much of a bubble shows at rest (enough for a whole icon and its
  /// margin) and once fully pulled.
  static const double _restVisible = 0.42;
  static const double _pulledVisible = 0.66;

  static const double _iconSize = 22;
  static const double _haloBlur = 28;
  static const double _haloSpread = 4;
  static const double _haloAlpha = 0.45;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _bubble(
            left: true,
            progress: saveProgress,
            fill: Color.lerp(
              AppColors.surfaceRaised2,
              AppColors.accent,
              saveProgress,
            )!,
            icon: saveProgress >= 0.5
                ? AppIcons.watchLaterFill
                : AppIcons.watchLater,
            iconColor: Color.lerp(
              AppColors.accent,
              AppColors.onAccent,
              saveProgress,
            )!,
            halo: AppColors.accent.withValues(alpha: _haloAlpha * saveProgress),
          ),
          if (showNext)
            _bubble(
              left: false,
              progress: nextProgress,
              fill: Color.lerp(
                AppColors.surfaceRaised2,
                AppColors.surfaceRaised,
                nextProgress,
              )!,
              icon: AppIcons.next,
              iconColor: AppColors.ink,
              halo: null,
            ),
        ],
      ),
    );
  }

  Widget _bubble({
    required bool left,
    required double progress,
    required Color fill,
    required IconData icon,
    required Color iconColor,
    required Color? halo,
  }) {
    final p = progress.clamp(0.0, 1.0);
    final visible = _restVisible + (_pulledVisible - _restVisible) * p;
    final shown = size * visible;
    final offset = -(size - shown);
    // The icon sits in the middle of the part that shows.
    final inset = (shown - _iconSize) / 2;
    return Positioned(
      left: left ? offset : null,
      right: left ? null : offset,
      top: 0,
      bottom: 0,
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.lineStrong.withValues(alpha: 1 - p),
            ),
            boxShadow: halo == null
                ? null
                : [
                    BoxShadow(
                      color: halo,
                      blurRadius: _haloBlur,
                      spreadRadius: _haloSpread,
                    ),
                  ],
          ),
          child: SizedBox(
            width: size,
            height: size,
            child: Align(
              alignment: left ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  left: left ? 0 : inset,
                  right: left ? inset : 0,
                ),
                child: Icon(icon, size: _iconSize, color: iconColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
