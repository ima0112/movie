import 'package:flutter/material.dart';

/// Fades the top (and optionally bottom) edge of a scrolling [child] out to
/// transparent over [top] / [bottom] px, so content that scrolls up under a
/// fixed header dissolves into whatever is behind it (a halo, a gradient, the
/// page color) instead of being cut by a hard line.
///
/// A mask on alpha, not a painted overlay: it works over any background and
/// needs no color. The child still receives all touches.
class ScrollEdgeFade extends StatelessWidget {
  const ScrollEdgeFade({
    super.key,
    required this.child,
    this.top = 28,
    this.bottom = 0,
  });

  final Widget child;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    if (top <= 0 && bottom <= 0) return child;
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) {
        final height = bounds.height;
        if (height <= 0) {
          return const LinearGradient(
            colors: [Colors.white, Colors.white],
          ).createShader(bounds);
        }
        final topStop = (top / height).clamp(0.0, 0.5);
        final bottomStop = 1 - (bottom / height).clamp(0.0, 0.5);
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0x00FFFFFF),
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF),
            Color(0x00FFFFFF),
          ],
          stops: [0, topStop, bottomStop, 1],
        ).createShader(bounds);
      },
      child: child,
    );
  }
}
