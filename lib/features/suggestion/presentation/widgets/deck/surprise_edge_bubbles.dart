import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';

/// The two big bubbles at the deck's edges, almost entirely off screen — only
/// a fragment shows. **Left: Save** (a bookmark, in the accent colour); **right:
/// Next** (an arrow on a dark fill). They hint at the gestures and never take
/// a touch ([IgnorePointer]).
///
/// While a card is dragged toward a side, that side's bubble grows into view:
/// [saveProgress] and [nextProgress] (0 at rest → 1 at the point where
/// releasing would confirm) fill the Save bubble with the accent and make the
/// Next one more visible. With [showNext] false (a one-card deck, nowhere to
/// go) the right bubble is left out.
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

  static const double size = 168;

  /// How much of a bubble shows at rest, and how much more once fully pulled.
  static const double _restVisible = 0.2;
  static const double _pulledVisible = 0.5;

  static const double _iconSize = 24;
  static const double _restOpacity = 0.55;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _bubble(
            left: true,
            progress: saveProgress,
            color: Color.lerp(
              AppColors.surfaceRaised2,
              AppColors.accent,
              saveProgress,
            )!,
            icon: AppIcons.watchLaterFill,
            iconColor: Color.lerp(
              AppColors.accent,
              AppColors.onAccent,
              saveProgress,
            )!,
          ),
          if (showNext)
            _bubble(
              left: false,
              progress: nextProgress,
              color: AppColors.surface.withValues(
                alpha: _restOpacity + (1 - _restOpacity) * nextProgress,
              ),
              icon: AppIcons.next,
              iconColor: AppColors.ink,
            ),
        ],
      ),
    );
  }

  Widget _bubble({
    required bool left,
    required double progress,
    required Color color,
    required IconData icon,
    required Color iconColor,
  }) {
    final visible =
        _restVisible + (_pulledVisible - _restVisible) * progress.clamp(0, 1);
    final offset = -size * (1 - visible);
    return Positioned(
      left: left ? offset : null,
      right: left ? null : offset,
      top: 0,
      bottom: 0,
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.lineStrong),
          ),
          child: SizedBox(
            width: size,
            height: size,
            child: Align(
              alignment: left ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  left: left ? 0 : size * 0.1,
                  right: left ? size * 0.1 : 0,
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
