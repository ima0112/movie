import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'poster_wall_geometry.dart';
import 'poster_wall_tiles.dart';

/// One of `PosterWall`'s 4 columns — a self-contained "screen" of its
/// own drift: a single linear, looping `AnimationController` (40–60s,
/// one *per column*, never shared), continuously translating 3 stacked
/// copies of this column's own poster set so the visible window always
/// sits inside the middle/last copy, never touching the edges of the
/// rendered content. That's what keeps the loop seam invisible and the
/// column gap-free at *every* point in the cycle — not just most of it.
///
/// [startPhase] staggers columns against each other — the *only*
/// stagger mechanism. There is deliberately no added top/bottom padding
/// or offset anywhere in this file: an earlier version used a static
/// `Padding(top: ...)` per column, which ate into the column's own
/// height, leaving a permanent empty gap at the top with a hard-clipped
/// edge right where the padding started — confirmed as the actual root
/// cause of that bug, not assumed. [goesUp] reverses the same drift
/// formula by reversing the phase fed into it, rather than needing a
/// mirrored copy layout for the other direction.
class PosterWallColumn extends StatefulWidget {
  const PosterWallColumn({
    super.key,
    required this.urls,
    required this.startPhase,
    required this.goesUp,
    required this.speed,
  });

  final List<String?> urls;
  final double startPhase;
  final bool goesUp;

  /// Logical pixels/second — see `PosterWallConfig.columnSpeeds`'s own
  /// doc comment. The controller's own `duration` is derived from this
  /// and the column's real, measured `loopHeight` (`driftDuration`),
  /// never a fixed, guessed `Duration`.
  final double speed;

  @override
  State<PosterWallColumn> createState() => _PosterWallColumnState();
}

class _PosterWallColumnState extends State<PosterWallColumn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const double _gap = AppSpacing.sm;

  @override
  void initState() {
    super.initState();
    // A placeholder — corrected in build(), the first time loopHeight
    // (and hence the real duration) is actually known.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Imperative, not setState-driven: .repeat()/.stop() don't themselves
  // trigger a rebuild, so calling this from inside build() is safe (no
  // "setState during build"), and AnimatedBuilder already scopes the
  // resulting per-frame rebuilds to just the Transform below, not this
  // whole method. re-calling .repeat() preserves the controller's
  // current value (it restarts the simulation, not the position), so
  // a duration correction here never causes a visible jump.
  void _syncAnimation(Duration duration, bool reduceMotion) {
    if (reduceMotion) {
      if (_controller.isAnimating) _controller.stop();
      return;
    }
    if (!_controller.isAnimating || _controller.duration != duration) {
      _controller.duration = duration;
      _controller.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return RepaintBoundary(
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardHeight = constraints.maxWidth * 1.5;
            // loopHeight >= screenHeight + cardHeight, always — padded
            // with extra placeholder slots (never a duplicated real
            // poster) if this column's own pool is too small to reach
            // it alone.
            final minSlots =
                ((constraints.maxHeight + cardHeight) / (cardHeight + _gap))
                    .ceil();
            final slots = widget.urls.length >= minSlots
                ? widget.urls
                : [
                    ...widget.urls,
                    ...List<String?>.filled(
                      minSlots - widget.urls.length,
                      null,
                    ),
                  ];
            final loopHeight = slots.length * (cardHeight + _gap);
            _syncAnimation(
              driftDuration(loopHeight: loopHeight, speed: widget.speed),
              reduceMotion,
            );

            return OverflowBox(
              alignment: Alignment.topCenter,
              maxHeight: double.infinity,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final dy = driftOffset(
                    startPhase: widget.startPhase,
                    t: reduceMotion ? 0.0 : _controller.value,
                    goesUp: widget.goesUp,
                    loopHeight: loopHeight,
                  );
                  return Transform.translate(
                    offset: Offset(0, dy),
                    child: child,
                  );
                },
                child: PosterWallTiles(
                  slots: slots,
                  copies: posterWallCopies,
                  cardHeight: cardHeight,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
