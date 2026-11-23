import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A progress ring: an accent arc over a `lineStrong` track, with [child] in
/// the middle. The one ring both the closing screen's affinity ("88%") and
/// D1/D2's rating ("9,0 TMDB") are drawn with.
///
/// When it appears the arc **fills** from empty to [fraction] (a short wait,
/// then about a second of easing out, [duration] in all); with "reduce motion"
/// it is drawn full at once. [child] is there from the start. It sizes itself
/// to [size] × [size].
class ProgressRing extends StatefulWidget {
  const ProgressRing({
    super.key,
    required this.fraction,
    required this.size,
    required this.strokeWidth,
    required this.child,
  });

  /// How much of the circle the arc covers, 0–1.
  final double fraction;
  final double size;
  final double strokeWidth;

  /// What sits in the middle of the ring.
  final Widget child;

  /// The whole animation, wait included.
  static const Duration duration = Duration(milliseconds: 1600);

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: ProgressRing.duration,
  );

  /// The first part of the run is the wait (the page is still settling in).
  static const Curve _fill = Interval(0.3, 1, curve: Curves.easeOutCubic);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (_controller.status == AnimationStatus.dismissed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => CustomPaint(
          painter: ProgressRingPainter(
            fraction: widget.fraction * _fill.transform(_controller.value),
            strokeWidth: widget.strokeWidth,
          ),
          child: child,
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}

/// Draws the ring: the track and the arc filled to [fraction] (0–1).
class ProgressRingPainter extends CustomPainter {
  const ProgressRingPainter({
    required this.fraction,
    required this.strokeWidth,
  });

  final double fraction;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final arcRect = (Offset.zero & size).deflate(strokeWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(
      arcRect,
      0,
      2 * math.pi,
      false,
      paint..color = AppColors.lineStrong,
    );
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      2 * math.pi * fraction.clamp(0.0, 1.0),
      false,
      paint
        ..strokeCap = StrokeCap.round
        ..color = AppColors.accent,
    );
  }

  @override
  bool shouldRepaint(ProgressRingPainter old) =>
      old.fraction != fraction || old.strokeWidth != strokeWidth;
}
