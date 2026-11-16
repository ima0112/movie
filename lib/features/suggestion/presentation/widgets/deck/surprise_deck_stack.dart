import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../../../match_engine/domain/surprise_batch.dart';
import 'surprise_double_tap_hint.dart';
import 'surprise_edge_bubbles.dart';
import 'surprise_suggestion_card.dart';

/// The deck itself (`docs/SCREENS.md` E3): the card on top and the next one behind it —
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

  static const Duration exitDuration = Duration(milliseconds: 200);

  /// The zoom when a thumbnail brings another card up.
  static const Duration zoomDuration = Duration(milliseconds: 300);
  static const Duration bounceDuration = Duration(milliseconds: 250);

  @override
  State<SurpriseDeckStack> createState() => _SurpriseDeckStackState();
}

class _SurpriseDeckStackState extends State<SurpriseDeckStack>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  late final AnimationController _zoom = AnimationController(vsync: this);

  /// The card that is flying off (a swipe) or zooming out toward the viewer (a
  /// jump to a higher number) while the deck has already moved on under it.
  int? _leavingIndex;

  /// Which way the last jump went: toward a higher number (true) or a lower one.
  bool _zoomForward = true;

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
  static const Duration _reorder = Duration(milliseconds: 200);

  /// The exit lasts as long as the finger's speed says, within these limits.
  static const double _minExitSpeed = 1400; // px / s
  static const Duration _minExit = Duration(milliseconds: 120);
  static const Duration _maxExit = Duration(milliseconds: 220);

  /// How far the zooming card grows toward the viewer.
  static const double _zoomGrowth = 0.28;

  /// How far a card shrinks when it goes back (or comes from the back).
  static const double _zoomShrink = 0.2;

  /// A card arriving from the front starts this faint.
  static const double _arrivingStart = 0.15;

  /// The cards, built once per batch: an animation frame moves them without
  /// rebuilding (or repainting) their poster, text and gradients.
  List<Widget>? _cardWidgets;
  List<SurpriseSuggestion>? _cardsFor;

  Widget _cardOf(int i) {
    if (!identical(_cardsFor, widget.suggestions)) {
      _cardsFor = widget.suggestions;
      _cardWidgets = [
        for (var k = 0; k < widget.suggestions.length; k++)
          RepaintBoundary(
            child: SurpriseSuggestionCard(
              suggestion: widget.suggestions[k],
              number: k + 1,
              total: widget.suggestions.length,
            ),
          ),
      ];
    }
    return _cardWidgets![i];
  }

  bool get _canSwipe => widget.suggestions.length >= 2;
  bool get _still => MediaQuery.disableAnimationsOf(context);

  @override
  void didUpdateWidget(SurpriseDeckStack old) {
    super.didUpdateWidget(old);
    final n = widget.suggestions.length;
    // A swipe leaves through its own animation; a new batch just appears.
    if (old.index == widget.index ||
        _leavingIndex != null ||
        !identical(old.suggestions, widget.suggestions) ||
        n < 2 ||
        _still) {
      return;
    }
    // Another card was brought up (a thumbnail, "Next"): toward a higher number
    // the old top comes toward the viewer and fades; toward a lower one the new
    // top arrives from the front. One step around the circle counts as forward.
    final step = (widget.index - old.index) % n;
    final forward = step == 1
        ? true
        : step == n - 1
        ? false
        : widget.index > old.index;
    _leavingIndex = old.index;
    _zoomForward = forward;
    _zoom
      ..duration = SurpriseDeckStack.zoomDuration
      ..forward(from: 0).whenComplete(() {
        if (!mounted) return;
        setState(() {
          _leavingIndex = null;
        });
      });
  }

  @override
  void dispose() {
    _zoom.dispose();
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
      _fling(-1, save: true, width: width, speed: v);
    } else if (_dx > 0 && (_dx > far || v > SurpriseDeckStack.flickVelocity)) {
      _fling(1, save: false, width: width, speed: v);
    } else {
      _run(0, SurpriseDeckStack.bounceDuration, Curves.easeOutBack);
    }
  }

  Future<void> _fling(
    int dir, {
    required bool save,
    required double width,
    required double speed,
  }) async {
    if (save) HapticFeedback.lightImpact();
    // The deck moves on at once — the next card rises while this one leaves —
    // instead of waiting for the exit to end.
    final leaving = widget.index;
    if (!_still) _leavingIndex = leaving;
    (save ? widget.onSaveAndNext : widget.onNext)();
    // Keep the finger's speed: the card does not slow down to start over.
    final target = dir * width * 1.3;
    final seconds =
        ((target - _dx).abs() / math.max(speed.abs(), _minExitSpeed)).clamp(
          _minExit.inMilliseconds / 1000,
          _maxExit.inMilliseconds / 1000,
        );
    await _run(
      target,
      Duration(milliseconds: (seconds * 1000).round()),
      Curves.easeOutCubic,
    );
    if (mounted && _leavingIndex == leaving) {
      setState(() => _leavingIndex = null);
    }
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
            animation: Listenable.merge([_controller, _zoom]),
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
                        if (_leavingIndex != null)
                          _leaving(_leavingIndex!, dx: dx, width: width),
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

  /// The card on its way out, drawn above the deck: flying off with the swipe,
  /// or growing toward the viewer and fading when another card was brought up.
  Widget _leaving(int i, {required double dx, required double width}) {
    final card = _cardOf(i);
    final Widget moving;
    if (_zoom.isAnimating) {
      final t = Curves.easeOutCubic.transform(_zoom.value);
      // Forward: toward the viewer, larger; backward: away, smaller. Fading
      // out either way.
      moving = Opacity(
        opacity: 1 - t,
        child: Transform.scale(
          scale: _zoomForward ? 1 + _zoomGrowth * t : 1 - _zoomShrink * t,
          child: card,
        ),
      );
    } else {
      moving = Transform.translate(
        offset: Offset(dx, 0),
        child: Transform.rotate(angle: dx / width * _maxTurn, child: card),
      );
    }
    return Positioned.fill(
      key: const ValueKey('leaving'),
      child: IgnorePointer(child: ExcludeSemantics(child: moving)),
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
    // Only the next card shows behind the top one: the ones past it would be
    // revealed while a card leaves and then hide again, which reads as a glitch.
    final visible = slot < 2;
    final side = slot.isOdd ? -1.0 : 1.0;
    final card = _cardOf(i);

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
              offset: Offset(_leavingIndex == null ? dx : 0, 0),
              child: Transform.rotate(
                angle: _still || _leavingIndex != null
                    ? 0
                    : dx / width * _maxTurn,
                child: card,
              ),
            ),
          )
        : IgnorePointer(child: card);
    final zooming = _zoom.isAnimating;
    final arriving = isTop && zooming;
    final t = Curves.easeOutCubic.transform(_zoom.value);
    final shown = arriving
        ? Opacity(
            opacity: _arrivingStart + (1 - _arrivingStart) * t,
            child: Transform.scale(
              // Forward: from small and far; backward: from large and near.
              scale: _zoomForward
                  ? 1 - _zoomShrink * (1 - t)
                  : 1 + _zoomGrowth * (1 - t),
              child: body,
            ),
          )
        : body;

    return Positioned.fill(
      key: ValueKey(suggestion.item.key),
      child: AnimatedOpacity(
        // (A zoom draws the two cards itself: the leaving one is hidden here and
        // the arriving one starts from its zoom pose, not from its old slot.)
        duration: _still || (zooming && (isTop || i == _leavingIndex))
            ? Duration.zero
            : _reorder,
        opacity: !visible || (zooming && i == _leavingIndex)
            ? 0
            : 1 - _behindFade * slot,
        child: AnimatedContainer(
          duration: _still || (zooming && isTop) ? Duration.zero : _reorder,
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
          child: shown,
        ),
      ),
    );
  }
}
