import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';

/// One star of the closing screen: where it is (fractions of the box), how big,
/// where it is in the twinkle cycle, and whether it is drawn over the card
/// ([front]) or behind it.
class SurpriseSparkle {
  const SurpriseSparkle({
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
    required this.front,
  });

  final double x;
  final double y;
  final double size;
  final double phase;
  final bool front;

  static const int minCount = 3;
  static const int maxCount = 5;
  static const double _minSize = 10;
  static const double _maxSize = 20;

  /// At most this many over the card; the rest around it.
  static const int _maxFront = 2;

  /// A fresh set for one showing of the screen: [minCount] to [maxCount] stars
  /// (3, 4 or 5) of random size and position. The ones behind the card sit near
  /// its edges, where they show; the (up to two) over the card keep to the
  /// poster's open middle so they never land on the text.
  static List<SurpriseSparkle> random(math.Random random) {
    final count = minCount + random.nextInt(maxCount - minCount + 1);
    final frontCount = random.nextInt(_maxFront + 1).clamp(0, count - 1);
    double between(double a, double b) => a + random.nextDouble() * (b - a);
    return [
      for (var i = 0; i < count; i++)
        if (i < frontCount)
          SurpriseSparkle(
            x: between(0.2, 0.8),
            y: between(0.2, 0.55),
            size: between(_minSize, _maxSize),
            phase: random.nextDouble(),
            front: true,
          )
        else
          () {
            // Around the card: a side margin, or the strip above/below it.
            final side = random.nextBool();
            return SurpriseSparkle(
              x: side
                  ? (random.nextBool()
                        ? between(0.01, 0.07)
                        : between(0.93, 0.99))
                  : between(0.05, 0.95),
              y: side
                  ? between(0.02, 0.98)
                  : (random.nextBool()
                        ? between(0.0, 0.03)
                        : between(0.97, 1.0)),
              size: between(_minSize, _maxSize),
              phase: random.nextDouble(),
              front: false,
            );
          }(),
    ];
  }
}

/// The closing screen's stars, twinkling in a loop: the ones of [stars] that are
/// [front] (over the card, a bit fainter) or not (behind it). Two instances —
/// one on each side of the card — draw a whole set. With "reduce motion" they
/// sit still. Decoration only: no semantics, no touches.
class SurpriseSparkles extends StatefulWidget {
  const SurpriseSparkles({super.key, required this.stars, required this.front});

  final List<SurpriseSparkle> stars;

  /// Draw the stars over the card (true) or the ones behind it (false).
  final bool front;

  static const Duration cycle = Duration(milliseconds: 2400);

  @override
  State<SurpriseSparkles> createState() => _SurpriseSparklesState();
}

class _SurpriseSparklesState extends State<SurpriseSparkles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SurpriseSparkles.cycle,
  );

  /// The stars over the card are a little fainter.
  static const double _frontAlpha = 0.8;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    final stars = [
      for (final s in widget.stars)
        if (s.front == widget.front) s,
    ];
    final scale = widget.front ? _frontAlpha : 1.0;
    return IgnorePointer(
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, c) => AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Stack(
              clipBehavior: Clip.none,
              children: [
                for (final s in stars)
                  Positioned(
                    left: c.maxWidth * s.x - s.size / 2,
                    top: c.maxHeight * s.y - s.size / 2,
                    child: Opacity(
                      opacity:
                          scale *
                          (still
                              ? 0.8
                              : _twinkle((_controller.value + s.phase) % 1)),
                      child: Icon(
                        AppIcons.shiningFill,
                        size: s.size,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 0.25 → 1 → 0.25 over one cycle.
  static double _twinkle(double t) {
    final wave = t < 0.5 ? t * 2 : (1 - t) * 2;
    return 0.25 + 0.75 * Curves.easeInOut.transform(wave);
  }
}
