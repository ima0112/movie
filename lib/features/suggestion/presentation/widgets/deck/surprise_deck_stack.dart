import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../../../match_engine/domain/surprise_batch.dart';
import 'surprise_card_back.dart';
import 'surprise_flip_card.dart';
import 'surprise_suggestion_card.dart';

/// Acts on a [SurpriseDeckStack] from outside it (a screen-reader action).
class SurpriseDeckController {
  VoidCallback? _flip;
  VoidCallback? _swipeNext;

  /// Turns the top card over (or back).
  void flipTop() => _flip?.call();

  /// Passes the top card exactly as a swipe to the right would — the card flies
  /// off and the next one rises — for controls that can't swipe ("Next" for a
  /// screen reader). Does nothing with one card.
  void swipeNext() => _swipeNext?.call();

  void _attach(_SurpriseDeckStackState state) {
    _flip = state._toggleFlip;
    _swipeNext = state._swipeNext;
  }

  void _detach() {
    _flip = null;
    _swipeNext = null;
  }
}

/// The deck itself (`docs/SCREENS.md` E3): the card on top and the next one
/// behind it, smaller and lower, all cards in one circular order. The dragging,
/// the fly-off and the card behind rising come from the `flutter_card_swiper`
/// package ([CardSwiper]); everything of ours — the cards' faces and their 3D
/// turn, the zoom when a thumbnail brings another card up, the screen-reader
/// controls — is layered on top of it.
///
/// **Gestures on the top card:**
/// - drag **either way** past the package's threshold: *pass* ([onNext], told
///   when the card has left); a drag that stops short springs back;
/// - **double tap**: *choose* ([onChoose], a medium buzz); **tap**: turn the card
///   over to its back and, tapped again, back to the front ([onFlipped]). A card
///   goes back to its front when it leaves the top.
/// With one card there is nowhere to go, so dragging is off. With "reduce
/// motion" nothing turns or flies: the deck just changes.
class SurpriseDeckStack extends StatefulWidget {
  const SurpriseDeckStack({
    super.key,
    required this.suggestions,
    required this.index,
    required this.onNext,
    required this.onChoose,
    this.onFlipped,
    this.cardAction,
    this.controller,
  });

  final List<SurpriseSuggestion> suggestions;

  /// The card on top.
  final int index;
  final VoidCallback onNext;
  final VoidCallback onChoose;

  /// The top card was turned to its back (a taste signal: the user wanted to
  /// know more).
  final VoidCallback? onFlipped;

  /// The control in each card's top-right corner (Watch later), built once per
  /// card of the batch.
  final Widget Function(int index)? cardAction;

  /// Lets code outside the deck (a screen-reader action) turn the top card.
  final SurpriseDeckController? controller;

  /// The zoom when a thumbnail brings another card up.
  static const Duration zoomDuration = Duration(milliseconds: 300);

  @override
  State<SurpriseDeckStack> createState() => _SurpriseDeckStackState();
}

class _SurpriseDeckStackState extends State<SurpriseDeckStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _zoom = AnimationController(vsync: this);
  final CardSwiperController _swiper = CardSwiperController();

  /// The card the swiper has on top. It moves by itself when a card is swiped
  /// away; the deck's [SurpriseDeckStack.index] follows it (through `onNext`).
  late int _swiperIndex = widget.index;

  /// The card zooming out (a jump from the thumbnails) while the deck is
  /// already on the new one.
  int? _leavingIndex;

  /// Which way the last jump went: toward a higher number (true) or a lower one.
  bool _zoomForward = true;

  static const double _sideMargin = AppSpacing.screenMargin;

  /// How much smaller, and how much lower, the card behind is.
  static const double _behindScale = 0.94;
  static const double _behindShift = 14;

  /// The most the dragged card turns, in degrees.
  static const double _maxAngle = 11;

  /// How far (px) a drag must go to pass the card.
  static const int _threshold = 100;
  static const Duration _flyDuration = Duration(milliseconds: 220);

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

  /// Whether each card shows its back.
  List<ValueNotifier<bool>> _flips = [];

  bool get _canSwipe => widget.suggestions.length >= 2;
  bool get _still => MediaQuery.disableAnimationsOf(context);

  void _ensureCards() {
    if (identical(_cardsFor, widget.suggestions)) return;
    _cardsFor = widget.suggestions;
    for (final n in _flips) {
      n.dispose();
    }
    _flips = [for (final _ in widget.suggestions) ValueNotifier(false)];
    _cardWidgets = [
      for (var k = 0; k < widget.suggestions.length; k++)
        RepaintBoundary(
          child: SurpriseFlipCard(
            flipped: _flips[k],
            front: SurpriseSuggestionCard(
              suggestion: widget.suggestions[k],
              number: k + 1,
              total: widget.suggestions.length,
              topAction: widget.cardAction?.call(k),
            ),
            back: SurpriseCardBack(
              suggestion: widget.suggestions[k],
              number: k + 1,
              topAction: widget.cardAction?.call(k),
            ),
          ),
        ),
    ];
  }

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(SurpriseDeckStack old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller?._detach();
      widget.controller?._attach(this);
    }
    if (!identical(old.suggestions, widget.suggestions)) {
      // A new batch: a new swiper, starting at the deck's card.
      _swiperIndex = widget.index;
      _leavingIndex = null;
      return;
    }
    if (old.index == widget.index) return;
    // A card that left the top shows its front again.
    if (old.index < _flips.length) _flips[old.index].value = false;
    // The swiper already moved there by itself (a swipe).
    if (widget.index == _swiperIndex) return;

    // Another card was brought up from the thumbnails: the swiper jumps there,
    // and the two cards zoom — toward a higher number the old top comes toward
    // the viewer and fades; toward a lower one the new top arrives from the
    // front. Only the numbers count (card 5 is after card 1).
    _swiperIndex = widget.index;
    // After this frame: the swiper drops the controller's pending events when
    // it is rebuilt (it re-subscribes in its own didUpdateWidget), and it is
    // being rebuilt right now.
    final target = widget.index;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && target == _swiperIndex) _swiper.moveTo(target);
    });
    if (_still || !_canSwipe) return;
    _leavingIndex = old.index;
    _zoomForward = widget.index > old.index;
    _zoom
      ..duration = SurpriseDeckStack.zoomDuration
      ..forward(from: 0).whenComplete(() {
        if (!mounted) return;
        setState(() => _leavingIndex = null);
      });
  }

  @override
  void dispose() {
    widget.controller?._detach();
    for (final n in _flips) {
      n.dispose();
    }
    _zoom.dispose();
    _swiper.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    _ensureCards();
    final flip = _flips[_swiperIndex];
    flip.value = !flip.value;
    if (flip.value) widget.onFlipped?.call();
  }

  void _swipeNext() {
    if (!_canSwipe) return;
    _swiper.swipe(CardSwiperDirection.right);
  }

  /// The swiper finished passing card [from]: the deck moves on.
  bool _onSwipe(int from, int? to, CardSwiperDirection direction) {
    _swiperIndex = to ?? from;
    widget.onNext();
    return true;
  }

  /// The card for [index]: its faces, its taps (the top card only), and, during
  /// a thumbnail zoom, the pose the zoom puts it in.
  Widget _card(int index) {
    final isTop = index == _swiperIndex;
    final zooming = _leavingIndex != null;
    Widget card = _cardWidgets![index];
    if (isTop) {
      card = GestureDetector(
        onTap: _toggleFlip,
        onDoubleTap: () {
          HapticFeedback.mediumImpact();
          widget.onChoose();
        },
        child: card,
      );
      if (zooming) {
        card = AnimatedBuilder(
          animation: _zoom,
          child: card,
          builder: (context, child) {
            final t = Curves.easeOutCubic.transform(_zoom.value);
            // Forward: from small and far; backward: from large and near.
            final scale = _zoomForward
                ? 1 - _zoomShrink * (1 - t)
                : 1 + _zoomGrowth * (1 - t);
            return Opacity(
              opacity: _arrivingStart + (1 - _arrivingStart) * t,
              child: Transform.scale(scale: scale, child: child),
            );
          },
        );
      }
      return card;
    }
    // The cards behind take no touches, and the one that is zooming out is
    // hidden (a copy of it is drawn on top).
    return IgnorePointer(
      child: Opacity(
        opacity: zooming && index == _leavingIndex ? 0 : 1,
        child: card,
      ),
    );
  }

  /// The old top card, drawn over the deck while it zooms out.
  Widget _leaving() {
    return AnimatedBuilder(
      animation: _zoom,
      child: _cardWidgets![_leavingIndex!],
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_zoom.value);
        // Forward: toward the viewer, larger; backward: away, smaller. Fading
        // out either way.
        return Opacity(
          opacity: 1 - t,
          child: Transform.scale(
            scale: _zoomForward ? 1 + _zoomGrowth * t : 1 - _zoomShrink * t,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _ensureCards();
    final n = widget.suggestions.length;
    final padding = const EdgeInsets.symmetric(horizontal: _sideMargin);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // A new batch is a new swiper (keyed by the batch itself).
        CardSwiper(
          key: ValueKey(widget.suggestions),
          controller: _swiper,
          cardsCount: n,
          initialIndex: widget.index,
          numberOfCardsDisplayed: n < 2 ? 1 : 2,
          isLoop: true,
          isDisabled: !_canSwipe,
          allowedSwipeDirection: const AllowedSwipeDirection.symmetric(
            horizontal: true,
          ),
          padding: padding,
          scale: _behindScale,
          backCardOffset: const Offset(0, _behindShift),
          maxAngle: _maxAngle,
          threshold: _threshold,
          duration: _still ? const Duration(milliseconds: 1) : _flyDuration,
          onSwipe: _onSwipe,
          cardBuilder: (context, index, horizontalPercent, verticalPercent) =>
              _card(index),
        ),
        if (_leavingIndex != null)
          Positioned.fill(
            key: const ValueKey('leaving'),
            child: Padding(
              padding: padding,
              child: IgnorePointer(child: ExcludeSemantics(child: _leaving())),
            ),
          ),
      ],
    );
  }
}
