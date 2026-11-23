import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// The round marker of one node of D2b's timeline, with the thin line that
/// runs down from it to the next node: a dashed ring for what is still to come
/// ([upcoming]), a solid amber dot for what already aired. The line fills the
/// height it is given.
class TimelineMarker extends StatelessWidget {
  const TimelineMarker({super.key, required this.upcoming});

  final bool upcoming;

  static const double size = 16;
  static const double width = 2;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: upcoming
              ? const CustomPaint(painter: _DashedRingPainter())
              : const Center(
                  child: SizedBox(
                    width: size - 4,
                    height: size - 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
        ),
        Expanded(
          child: Container(width: width, color: AppColors.lineStrong),
        ),
      ],
    );
  }
}

class _DashedRingPainter extends CustomPainter {
  const _DashedRingPainter();

  static const int _dashes = 8;
  static const double _stroke = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_stroke / 2 + 1);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.inkMuted;
    const step = 2 * math.pi / _dashes;
    for (var i = 0; i < _dashes; i++) {
      canvas.drawArc(rect, i * step, step * 0.55, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter old) => false;
}
