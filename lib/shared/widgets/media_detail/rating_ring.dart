import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../l10n/number_format_extension.dart';

/// D1/D2's rating ring, at the right of the title: TMDB's vote average (0–10)
/// as an amber arc over a `lineStrong` track, with the number in the middle
/// ("9,0") and the source under it ("TMDB").
///
/// It is a fixed-size badge: the number and the label ignore the system's text
/// scale (the ring would otherwise outgrow its circle), and the whole thing is
/// one semantics node reading "Rating 9.0 out of 10".
class RatingRing extends StatelessWidget {
  const RatingRing({super.key, required this.rating});

  /// TMDB's vote average, 0–10.
  final double rating;

  static const double size = 56;
  static const double _stroke = 4;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final value = rating.localizedRating(l10n);
    return Semantics(
      label: l10n.mediaDetailRatingSemantics(value),
      excludeSemantics: true,
      child: MediaQuery.withNoTextScaling(
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(rating / 10),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(value, style: AppTextStyles.ratingValue),
                  Text(
                    l10n.mediaDetailRatingSource,
                    style: AppTextStyles.micro.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
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
    final arcRect = (Offset.zero & size).deflate(RatingRing._stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = RatingRing._stroke;
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
  bool shouldRepaint(_RingPainter old) => old.fraction != fraction;
}
