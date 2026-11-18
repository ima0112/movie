import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// A tour marker: a circle with a label ("1×", "2×") and rings that widen and
/// fade in a loop — where and how many times to tap. It lets touches through.
/// With "reduce motion" on, the rings are drawn still.
class SurpriseTapMarker extends StatefulWidget {
  const SurpriseTapMarker({super.key, required this.label});

  /// What the circle says: "1×" (tap) or "2×" (double tap).
  final String label;

  static const Duration cycle = Duration(milliseconds: 1800);

  @override
  State<SurpriseTapMarker> createState() => _SurpriseTapMarkerState();
}

class _SurpriseTapMarkerState extends State<SurpriseTapMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SurpriseTapMarker.cycle,
  );

  static const double _core = 56;
  static const double _ringReach = 56;
  static const int _rings = 2;
  static const double _ringStroke = 1.5;

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
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return SizedBox(
                width: _core + 2 * _ringReach,
                height: _core + 2 * _ringReach,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    for (var i = 0; i < _rings; i++)
                      _ring(still ? 0.3 + 0.3 * i : _phase(i)),
                    DecoratedBox(
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(
                        width: _core,
                        height: _core,
                        child: Center(
                          child: Text(
                            widget.label,
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.onAccent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Ring [i]'s progress 0 → 1, each half a cycle behind the one before.
  double _phase(int i) => (_controller.value + i / _rings) % 1;

  Widget _ring(double t) {
    final size = _core + 2 * _ringReach * t;
    return Opacity(
      opacity: 1 - t,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.accent, width: _ringStroke),
        ),
        child: SizedBox(width: size, height: size),
      ),
    );
  }
}
