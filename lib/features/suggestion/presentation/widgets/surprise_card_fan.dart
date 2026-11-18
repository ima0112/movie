import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'surprise_deck_card.dart';

/// The shuffling fan of five "?" cards (E3a): open at rest (offsets −96 … +96,
/// tilts −18° … +18°), each card slides to the centre and back in a loop, the
/// next one a little later, which reads as a shuffle. The middle card is on
/// top. With "reduce motion" on, nothing moves: the fan stays open.
///
/// Pure presentation — it owns only its animation.
class SurpriseCardFan extends StatefulWidget {
  const SurpriseCardFan({super.key});

  /// Left to right.
  static const List<double> _restX = [-96, -48, 0, 48, 96];
  static const List<double> _restTilt = [-18, -9, 0, 9, 18];
  static const List<double> _restY = [8, 4, 0, -4, -8];

  /// How far each card's loop is ahead (a fraction of the cycle), left to
  /// right: +12 % per card.
  static const List<double> _phase = [0.125, 0.175, 0.225, 0.275, 0.325];

  /// Paint order, back to front: the outer cards, then the next two, then the
  /// middle one on top.
  static const List<int> _paintOrder = [0, 4, 1, 3, 2];

  static const Duration cycle = Duration(milliseconds: 2400);

  /// The fan's box: the card plus the widest offset on each side.
  static const double _boxWidth = SurpriseDeckCard.width + 2 * 96 + 40;
  static const double _boxHeight = SurpriseDeckCard.height + 40;

  @override
  State<SurpriseCardFan> createState() => _SurpriseCardFanState();
}

class _SurpriseCardFanState extends State<SurpriseCardFan>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SurpriseCardFan.cycle,
  );

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

  /// 0 = open (rest), 1 = gathered at the centre, for card [i] at cycle time
  /// [t]: toward the centre in the first half, back in the second, each half
  /// eased, so the loop is symmetric.
  static double _gathered(double t, int i, bool still) {
    if (still) return 0;
    final p = (t + SurpriseCardFan._phase[i]) % 1;
    final half = p < 0.5 ? p * 2 : (1 - p) * 2;
    return Curves.easeInOut.transform(half);
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return ExcludeSemantics(
      child: SizedBox(
        width: SurpriseCardFan._boxWidth,
        height: SurpriseCardFan._boxHeight,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              alignment: Alignment.center,
              children: [
                for (final i in SurpriseCardFan._paintOrder)
                  Transform.translate(
                    offset: Offset(
                      SurpriseCardFan._restX[i] *
                          (1 - _gathered(_controller.value, i, still)),
                      SurpriseCardFan._restY[i],
                    ),
                    child: Transform.rotate(
                      angle:
                          SurpriseCardFan._restTilt[i] *
                          (1 - _gathered(_controller.value, i, still)) *
                          math.pi /
                          180,
                      child: SurpriseDeckCard(
                        key: ValueKey('surprise-card-$i'),
                        colors: AppColors.surpriseCardGradients[i],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
