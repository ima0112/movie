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
/// When it appears the arc **fills** from empty to the rating (the same run as
/// the closing screen's affinity ring: a short wait, then about a second of
/// easing out); with "reduce motion" it is drawn full at once. The number is
/// there from the start.
///
/// It is a fixed-size badge: the number and the label ignore the system's text
/// scale (the ring would otherwise outgrow its circle), and the whole thing is
/// one semantics node reading "Rating 9.0 out of 10".
class RatingRing extends StatefulWidget {
  const RatingRing({super.key, required this.rating});

  /// TMDB's vote average, 0–10.
  final double rating;

  static const double size = 56;
  static const double _stroke = 4;

  /// The whole animation, wait included.
  static const Duration duration = Duration(milliseconds: 1600);

  @override
  State<RatingRing> createState() => _RatingRingState();
}

class _RatingRingState extends State<RatingRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: RatingRing.duration,
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
    final l10n = context.l10n;
    final value = widget.rating.localizedRating(l10n);
    return Semantics(
      label: l10n.mediaDetailRatingSemantics(value),
      excludeSemantics: true,
      child: MediaQuery.withNoTextScaling(
        child: SizedBox(
          width: RatingRing.size,
          height: RatingRing.size,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => CustomPaint(
              painter: _RingPainter(
                widget.rating / 10 * _fill.transform(_controller.value),
              ),
              child: child,
            ),
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
