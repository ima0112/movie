import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Turns a card over: [front] while [flipped] is false, [back] while it is
/// true, with a 3D turn around the vertical axis (about 450 ms; the face
/// changes when the card is edge-on, and the back is drawn the right way round).
/// With "reduce motion" the faces swap at once.
///
/// [flipped] is a [ValueListenable] so that turning one card rebuilds only
/// that card: the deck builds its cards once per batch and flips them through
/// this.
class SurpriseFlipCard extends StatefulWidget {
  const SurpriseFlipCard({
    super.key,
    required this.flipped,
    required this.front,
    required this.back,
  });

  final ValueListenable<bool> flipped;
  final Widget front;
  final Widget back;

  static const Duration duration = Duration(milliseconds: 450);

  /// How strong the 3D perspective is.
  static const double _perspective = 0.0012;

  @override
  State<SurpriseFlipCard> createState() => _SurpriseFlipCardState();
}

class _SurpriseFlipCardState extends State<SurpriseFlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SurpriseFlipCard.duration,
    value: widget.flipped.value ? 1 : 0,
  );

  @override
  void initState() {
    super.initState();
    widget.flipped.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(SurpriseFlipCard old) {
    super.didUpdateWidget(old);
    if (old.flipped != widget.flipped) {
      old.flipped.removeListener(_onChanged);
      widget.flipped.addListener(_onChanged);
      _controller.value = widget.flipped.value ? 1 : 0;
    }
  }

  void _onChanged() {
    final target = widget.flipped.value ? 1.0 : 0.0;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = target;
    } else {
      _controller.animateTo(target, curve: Curves.easeInOut);
    }
  }

  @override
  void dispose() {
    widget.flipped.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final showBack = t > 0.5;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, SurpriseFlipCard._perspective)
            ..rotateY(t * math.pi),
          child: showBack
              // Seen from behind the card is mirrored: turn it back.
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: widget.back,
                )
              : widget.front,
        );
      },
    );
  }
}
