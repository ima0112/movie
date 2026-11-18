import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';

/// The two arrows at the deck's edges, in the style of the browser's
/// back/forward gesture: nothing at rest; while a card is dragged toward a side
/// that side's round arrow slides in from the edge and fades in as the drag
/// grows ([leftProgress] / [rightProgress], 0 → 1 where letting go would pass
/// the card), and it is gone again when the card leaves or springs back. They
/// never take a touch ([IgnorePointer]).
class SurpriseEdgeArrows extends StatelessWidget {
  const SurpriseEdgeArrows({
    super.key,
    this.leftProgress = 0,
    this.rightProgress = 0,
  });

  final double leftProgress;
  final double rightProgress;

  static const double size = 44;
  static const double _iconSize = 22;

  /// How far from the screen's edge the arrow comes to rest.
  static const double _restingGap = 8;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _arrow(left: true, progress: leftProgress),
          _arrow(left: false, progress: rightProgress),
        ],
      ),
    );
  }

  Widget _arrow({required bool left, required double progress}) {
    final p = progress.clamp(0.0, 1.0);
    if (p == 0) return const SizedBox.shrink();
    // From fully off screen to its resting gap.
    final offset = -size + (size + _restingGap) * Curves.easeOut.transform(p);
    return Positioned(
      left: left ? offset : null,
      right: left ? null : offset,
      top: 0,
      bottom: 0,
      child: Center(
        child: Opacity(
          opacity: p,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised2,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.lineStrong),
            ),
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(
                left ? AppIcons.back : AppIcons.next,
                size: _iconSize,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
