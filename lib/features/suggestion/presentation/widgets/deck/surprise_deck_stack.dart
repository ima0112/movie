import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../../../match_engine/domain/surprise_batch.dart';
import 'surprise_double_tap_hint.dart';
import 'surprise_edge_bubbles.dart';
import 'surprise_suggestion_card.dart';

/// The deck itself (`docs/SCREENS.md` E3): the card on top and two behind it —
/// smaller, lower, turned a few degrees in opposite directions and fainter —
/// all cards living in one circular order, so the top one that leaves goes to
/// the back.
///
/// **Gestures on the top card:**
/// - drag **left** past a third of the width (or a fast flick): *save and pass*
///   ([onSaveAndNext], a light buzz); drag **right**: *pass* ([onNext]); a drag
///   that stops short springs back;
/// - **double tap**: *choose* ([onChoose], a medium buzz); **tap**: open the
///   detail ([onOpenDetail]) — the tap waits a moment to tell them apart.
/// While dragged the card follows the finger with a turn proportional to how far
/// it went, and the bubble on that edge grows ([SurpriseEdgeBubbles]). With one
/// card there is nowhere to go, so dragging is off.
///
/// With "reduce motion" nothing turns or flies: the deck just changes.
class SurpriseDeckStack extends StatefulWidget {
  const SurpriseDeckStack({
    super.key,
    required this.suggestions,
    required this.index,
    required this.onNext,
    required this.onSaveAndNext,
    required this.onChoose,
    required this.onOpenDetail,
    this.showHint = false,
    this.onHintDismissed,
  });

  final List<SurpriseSuggestion> suggestions;

  /// The card on top.
  final int index;
  final VoidCallback onNext;
  final VoidCallback onSaveAndNext;
  final VoidCallback onChoose;
  final VoidCallback onOpenDetail;

  /// The first-time "2×" overlay; [onHintDismissed] fires at the first touch.
  final bool showHint;
  final VoidCallback? onHintDismissed;

  /// A drag confirms past this fraction of the card's width…
  static const double confirmFraction = 1 / 3;

  /// …or a flick faster than this (logical px / s).
  static const double flickVelocity = 700;

  static const Duration exitDuration = Duration(milliseconds: 220);
  static const Duration bounceDuration = Duration(milliseconds: 250);

  @override
  State<SurpriseDeckStack> createState() => _SurpriseDeckStackState();
}

class _SurpriseDeckStackState extends State<SurpriseDeckStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);

  /// The top card's horizontal offset while a finger is on it.
  double _dx = 0;
  double _from = 0;
  double _to = 0;
  Curve _curve = Curves.easeOut;
  bool _animating = false;
  bool _hintDismissed = false;

  static const double _sideMargin = AppSpacing.xxxl;
  static const double _maxTurn = 0.2; // radians at a full card width
  static const double _behindShift = 14;
  static const double _behindScale = 0.06;
  static const double _behindFade = 0.35;
  static const double _behindTurn = 0.05;
  static const Duration _reorder = Duration(milliseconds: 250);

  bool get _canSwipe => widget.suggestions.length >= 2;
  bool get _still => MediaQuery.disableAnimationsOf(context);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismissHint() {
    if (widget.showHint && !_hintDismissed) {
      _hintDismissed = true;
      widget.onHintDismissed?.call();
      setState(() {});
    }
  }

  double _offset() => _animating
      ? _from + (_to - _from) * _curve.transform(_controller.value)
      : _dx;

  void _onDragUpdate(DragUpdateDetails d) {
    if (!_canSwipe || _animating) return;
    setState(() => _dx += d.delta.dx);
  }

  void _onDragEnd(DragEndDetails d, double width) {
    if (!_canSwipe || _animating) return;
    final v = d.primaryVelocity ?? 0;
    final far = width * SurpriseDeckStack.confirmFraction;
    if (_dx < 0 && (-_dx > far || v < -SurpriseDeckStack.flickVelocity)) {
      _fling(-1, save: true, width: width);
    } else if (_dx > 0 && (_dx > far || v > SurpriseDeckStack.flickVelocity)) {
      _fling(1, save: false, width: width);
    } else {
      _run(0, SurpriseDeckStack.bounceDuration, Curves.easeOutBack);
    }
  }

  Future<void> _fling(
    int dir, {
    required bool save,
    required double width,
  }) async {
    if (save) HapticFeedback.lightImpact();
    await _run(
      dir * width * 1.3,
      SurpriseDeckStack.exitDuration,
      Curves.easeOut,
      then: save ? widget.onSaveAndNext : widget.onNext,
    );
  }

  /// Slides the top card from where it is to [to], then runs [then] (the deck
  /// moves on) and puts the offset back to zero — the next card is on top by
  /// then, so nothing jumps.
  Future<void> _run(
    double to,
    Duration duration,
    Curve curve, {
    VoidCallback? then,
  }) async {
    _from = _dx;
    _to = to;
    _curve = curve;
    _animating = true;
    if (_still) {
      _controller.value = 1;
    } else {
      _controller.duration = duration;
      await _controller.forward(from: 0);
    }
    if (!mounted) return;
    then?.call();
    setState(() {
      _animating = false;
      _dx = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.suggestions;
    final n = cards.length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - 2 * _sideMargin;
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => _dismissHint(),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final dx = _offset();
              final p = (dx.abs() / (width * SurpriseDeckStack.confirmFraction))
                  .clamp(0.0, 1.0);
              // Back to front: the farthest slot first, the top card last.
              final order = [for (var i = 0; i < n; i++) i]
                ..sort((a, b) => _slot(b).compareTo(_slot(a)));
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    left: _sideMargin,
                    right: _sideMargin,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        for (final i in order)
                          _slotted(i, cards[i], dx: dx, width: width),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: SurpriseEdgeBubbles(
                      saveProgress: dx < 0 ? p : 0,
                      nextProgress: dx > 0 ? p : 0,
                      showNext: _canSwipe,
                    ),
                  ),
                  if (widget.showHint && !_hintDismissed)
                    const Positioned.fill(child: SurpriseDoubleTapHint()),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// 0 = the top card, 1 = the next one…, around the circular order.
  int _slot(int i) => (i - widget.index) % widget.suggestions.length;

  Widget _slotted(
    int i,
    SurpriseSuggestion suggestion, {
    required double dx,
    required double width,
  }) {
    final slot = _slot(i);
    final isTop = slot == 0;
    final visible = slot < 3;
    final side = slot.isOdd ? -1.0 : 1.0;
    final card = SurpriseSuggestionCard(
      suggestion: suggestion,
      number: i + 1,
      total: widget.suggestions.length,
    );

    final body = isTop
        ? GestureDetector(
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: (d) => _onDragEnd(d, width),
            onTap: _animating ? null : widget.onOpenDetail,
            onDoubleTap: _animating
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    widget.onChoose();
                  },
            child: Transform.translate(
              offset: Offset(dx, 0),
              child: Transform.rotate(
                angle: _still ? 0 : dx / width * _maxTurn,
                child: card,
              ),
            ),
          )
        : IgnorePointer(child: card);

    return Positioned.fill(
      key: ValueKey(suggestion.item.key),
      child: AnimatedOpacity(
        duration: _still ? Duration.zero : _reorder,
        opacity: !visible ? 0 : 1 - _behindFade * slot,
        child: AnimatedContainer(
          duration: _still ? Duration.zero : _reorder,
          curve: Curves.easeOut,
          transformAlignment: Alignment.center,
          transform: Matrix4.identity()
            ..translateByDouble(0, isTop ? 0 : _behindShift * slot, 0, 1)
            ..rotateZ(
              _still || isTop ? 0 : side * _behindTurn * math.min(slot, 2),
            )
            ..scaleByDouble(
              1 - _behindScale * math.min(slot, 3),
              1 - _behindScale * math.min(slot, 3),
              1,
              1,
            ),
          child: body,
        ),
      ),
    );
  }
}
