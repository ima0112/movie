import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';

/// Small four-point stars scattered over the closing screen's chosen card,
/// twinkling in a loop. Two layers: the [SurpriseSparkles.behind] stars sit
/// around the card — the ones in the margins show, the rest hide behind it —
/// and the [SurpriseSparkles.front] ones are drawn over the card itself, a bit
/// fainter and smaller so they never get in the way of the text. With "reduce
/// motion" they sit still. Decoration only: no semantics, no touches.
class SurpriseSparkles extends StatefulWidget {
  const SurpriseSparkles.behind({super.key}) : front = false;

  const SurpriseSparkles.front({super.key}) : front = true;

  /// Over the card (true) or behind it (false).
  final bool front;

  static const Duration cycle = Duration(milliseconds: 2400);

  /// (x, y as fractions of the box, size, phase of the twinkle).
  static const List<(double, double, double, double)> behindStars = [
    (0.08, 0.04, 18, 0.0),
    (0.90, 0.02, 14, 0.3),
    (0.97, 0.20, 12, 0.85),
    (0.96, 0.36, 20, 0.6),
    (0.03, 0.30, 14, 0.5),
    (0.04, 0.56, 12, 0.15),
    (0.98, 0.58, 12, 0.7),
    (0.02, 0.78, 16, 0.4),
    (0.92, 0.80, 12, 0.45),
    (0.96, 0.96, 18, 0.2),
    (0.12, 0.97, 14, 0.75),
    (0.50, 0.01, 10, 0.55),
  ];

  /// Over the card: kept to the poster's open areas, small.
  static const List<(double, double, double, double)> frontStars = [
    (0.30, 0.30, 14, 0.1),
    (0.72, 0.46, 18, 0.5),
    (0.20, 0.58, 12, 0.8),
  ];

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
    final stars = widget.front
        ? SurpriseSparkles.frontStars
        : SurpriseSparkles.behindStars;
    final scale = widget.front ? _frontAlpha : 1.0;
    return IgnorePointer(
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, c) => AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Stack(
              clipBehavior: Clip.none,
              children: [
                for (final (x, y, size, phase) in stars)
                  Positioned(
                    left: c.maxWidth * x - size / 2,
                    top: c.maxHeight * y - size / 2,
                    child: Opacity(
                      opacity:
                          scale *
                          (still
                              ? 0.8
                              : _twinkle((_controller.value + phase) % 1)),
                      child: Icon(
                        AppIcons.shiningFill,
                        size: size,
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
