import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';

/// A few small four-point stars scattered behind and around the chosen card,
/// twinkling in a loop. With "reduce motion" they sit still. Decoration only:
/// no semantics, no touches.
class SurpriseSparkles extends StatefulWidget {
  const SurpriseSparkles({super.key});

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

  /// (x, y as fractions of the box, size, phase of the twinkle).
  static const List<(double, double, double, double)> _stars = [
    (0.08, 0.10, 18, 0.0),
    (0.90, 0.06, 14, 0.3),
    (0.96, 0.34, 20, 0.6),
    (0.04, 0.56, 12, 0.15),
    (0.92, 0.78, 12, 0.45),
    (0.12, 0.90, 14, 0.75),
  ];

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
    return IgnorePointer(
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, c) => AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Stack(
              children: [
                for (final (x, y, size, phase) in _stars)
                  Positioned(
                    left: c.maxWidth * x - size / 2,
                    top: c.maxHeight * y - size / 2,
                    child: Opacity(
                      opacity: still
                          ? 0.8
                          : _twinkle((_controller.value + phase) % 1),
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
