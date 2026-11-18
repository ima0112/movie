import 'package:flutter/material.dart';

import 'surprise_edge_arrows.dart';

/// The first tour step's picture: the two edge arrows showing in turn — left,
/// then right — as they do while a card is dragged, looping. With "reduce
/// motion" both sit at rest, visible. Decoration only.
class SurpriseTourSwipeDemo extends StatefulWidget {
  const SurpriseTourSwipeDemo({super.key});

  static const Duration cycle = Duration(milliseconds: 2400);

  @override
  State<SurpriseTourSwipeDemo> createState() => _SurpriseTourSwipeDemoState();
}

class _SurpriseTourSwipeDemoState extends State<SurpriseTourSwipeDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SurpriseTourSwipeDemo.cycle,
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

  /// A 0 → 1 → 0 swell over [from, to] of the cycle.
  static double _swell(double t, double from, double to) {
    if (t <= from || t >= to) return 0;
    final x = (t - from) / (to - from);
    return Curves.easeInOut.transform(x < 0.5 ? x * 2 : (1 - x) * 2);
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          return SurpriseEdgeArrows(
            leftProgress: still ? 1 : _swell(t, 0.05, 0.5),
            rightProgress: still ? 1 : _swell(t, 0.55, 1),
          );
        },
      ),
    );
  }
}
