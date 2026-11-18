import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// A progress ring with the affinity in the middle ("88"): an accent arc over a
/// `lineStrong` track, filled to [percent] of the circle. Used on the closing
/// screen's chosen card. Pure presentation.
class SurpriseAffinityRing extends StatelessWidget {
  const SurpriseAffinityRing({super.key, required this.percent});

  /// 0–100.
  final int percent;

  static const double size = 64;
  static const double _stroke = 5;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(percent / 100),
        child: Center(
          child: Text.rich(
            TextSpan(
              text: '$percent',
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

class _RingPainter extends CustomPainter {
  const _RingPainter(this.fraction);

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
  bool shouldRepaint(_RingPainter old) => old.fraction != fraction;
}
