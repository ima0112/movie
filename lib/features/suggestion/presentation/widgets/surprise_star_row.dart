import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';

/// The row of five outlined four-point stars under E3a's text: each pulses
/// (opacity 0.25 → 1 → 0.25, scale 1 → 1.4 → 1) a little after its
/// neighbour, so a wave runs along the row. With "reduce motion" on, they
/// stay still at full opacity.
///
/// Pure presentation — it owns only its animation.
class SurpriseStarRow extends StatefulWidget {
  const SurpriseStarRow({super.key});

  static const Duration cycle = Duration(milliseconds: 1200);

  /// How far each star's loop is ahead (a fraction of the cycle), left to
  /// right: the wave runs from the right-hand star to the left.
  static const List<double> _phase = [0.333, 0.458, 0.583, 0.708, 0.833];

  @override
  State<SurpriseStarRow> createState() => _SurpriseStarRowState();
}

class _SurpriseStarRowState extends State<SurpriseStarRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SurpriseStarRow.cycle,
  );

  static const double _size = 12;
  static const double _gap = 10;
  static const double _minOpacity = 0.25;
  static const double _maxScale = 1.4;

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
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < SurpriseStarRow._phase.length; i++) ...[
                if (i > 0) const SizedBox(width: _gap),
                _star(still ? 1 : _pulse(i), still ? 1 : _scale(i)),
              ],
            ],
          );
        },
      ),
    );
  }

  /// 0 → 1 → 0 over the cycle for star [i], eased.
  double _wave(int i) {
    final p = (_controller.value + SurpriseStarRow._phase[i]) % 1;
    return Curves.easeInOut.transform(p < 0.5 ? p * 2 : (1 - p) * 2);
  }

  double _pulse(int i) => _minOpacity + (1 - _minOpacity) * _wave(i);

  double _scale(int i) => 1 + (_maxScale - 1) * _wave(i);

  Widget _star(double opacity, double scale) {
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: const Icon(
          AppIcons.shining,
          size: _size,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
