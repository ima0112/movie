import 'package:flutter/material.dart';

/// Fades the top (and optionally bottom) edge of a scrolling [child] out to
/// transparent over [top] / [bottom] px, so content that scrolls up under a
/// fixed header dissolves into whatever is behind it (a halo, a gradient, the
/// page color) instead of being cut by a hard line.
///
/// A mask on alpha, not a painted overlay: it works over any background and
/// needs no color. The child still receives all touches.
///
/// The widget tree is the same whatever [top] and [bottom] are — including
/// both 0, when the mask is simply all-opaque. Returning the bare child in
/// that case would change the tree's structure whenever a fade appears or
/// goes (the recent searches' bottom fade goes at the end of the list), and
/// Flutter would then rebuild the child from scratch: a scrolling list under
/// it would lose its position and jump back to the start.
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

  static const Color _opaque = Color(0xFFFFFFFF);
  static const Color _clear = Color(0x00FFFFFF);

  @override
  Widget build(BuildContext context) {
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
          // An edge with no fade is opaque all the way to it.
          colors: [
            top > 0 ? _clear : _opaque,
            _opaque,
            _opaque,
            bottom > 0 ? _clear : _opaque,
          ],
          stops: [0, topStop, bottomStop, 1],
        ).createShader(bounds);
      },
      child: child,
    );
  }
}
