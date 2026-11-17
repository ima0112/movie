import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// A progress ring with the affinity in the middle ("88%"): an accent arc over
/// a `lineStrong` track. Used on the closing screen's chosen card. When it
/// appears the arc **fills** from empty to [percent] of the circle (about 1.1 s
/// after a short wait, easing out); with "reduce motion" it is drawn full at
/// once. The number itself is there from the start.
class SurpriseAffinityRing extends StatefulWidget {
  const SurpriseAffinityRing({super.key, required this.percent});

  /// 0–100.
  final int percent;

  static const double size = 64;
  static const double _stroke = 5;

  /// The whole animation, wait included.
  static const Duration duration = Duration(milliseconds: 1600);

  @override
  State<SurpriseAffinityRing> createState() => _SurpriseAffinityRingState();
}

class _SurpriseAffinityRingState extends State<SurpriseAffinityRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SurpriseAffinityRing.duration,
  );

  /// The first part of the run is the wait (the card is still settling in).
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
      width: SurpriseAffinityRing.size,
      height: SurpriseAffinityRing.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => CustomPaint(
          painter: SurpriseRingPainter(
            widget.percent / 100 * _fill.transform(_controller.value),
          ),
          child: child,
        ),
        child: Center(
          child: Text.rich(
            TextSpan(
              text: '${widget.percent}',
              style: AppTextStyles.h3,
              children: [
                TextSpan(text: '%', style: AppTextStyles.captionStrong),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Draws the ring: the track and the arc filled to [fraction] (0–1).
class SurpriseRingPainter extends CustomPainter {
  const SurpriseRingPainter(this.fraction);

  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = SurpriseAffinityRing._stroke / 2;
    final arcRect = rect.deflate(inset);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = SurpriseAffinityRing._stroke
      ..color = AppColors.lineStrong;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = SurpriseAffinityRing._stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.accent;
    canvas.drawArc(arcRect, 0, 2 * math.pi, false, track);
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      2 * math.pi * fraction.clamp(0.0, 1.0),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(SurpriseRingPainter old) => old.fraction != fraction;
}
