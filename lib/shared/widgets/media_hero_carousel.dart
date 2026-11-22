import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../core/domain/entities/media_item.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/genre_localization.dart';
import '../../l10n/l10n_extension.dart';
import '../../l10n/media_type_localization.dart';
import 'media_card.dart';

/// "2019 · Mystery, Comedy · Movie" — the hero's metadata line, per
/// `docs/SCREENS.md` B1.
String _heroMetadata(MediaItem item, AppLocalizations l10n) {
  final parts = <String>[
    if (item.releaseDate != null) '${item.releaseDate!.year}',
    if (item.genres.isNotEmpty)
      item.genres.map((genre) => genre.localizedName(l10n)).join(', '),
    item.type.localizedSingular(l10n),
  ];
  return parts.join(' · ');
}

/// The Discover hero (`docs/SCREENS.md` B1): a **looping carousel with depth**.
/// The banner in focus is big, centered and in front; the ones either side sit
/// **behind** it — smaller ([neighborScale]), dimmer ([neighborOpacity]), lower
/// and tucked under its edges, only a sliver showing.
///
/// Swiping **rotates** them: the banner that was behind comes forward, growing
/// and rising over the one it replaces, while that one shrinks, dims and slides
/// back to its place at the side — in step with the finger, and also when
/// swiping the other way (the stacking order follows each card's distance to
/// the focus, not its index). The swipe is the carousel's own drag and spring,
/// not a `PageView`, because a `PageView` cannot reorder its pages in depth.
///
/// With the system's "reduce motion" on, the cards do not scale or sink (they
/// keep their dimming and place). The hero's height is always
/// [MediaCardSize.hero]'s, so nothing below it shifts.
///
/// Layout: the card is [_cardFraction] of the page's width (at most
/// [_maxCardWidth]); every visible card opens its detail on tap, the neighbours
/// included.
///
/// Pure presentation, no Bloc: [saveButtonBuilder] lets the caller put a
/// button (with its own narrow subscription) on each card without this
/// carousel, or any other card, rebuilding for it (CLAUDE.md rule 9). Only the
/// hero itself repaints as it moves. Give it a `ValueKey` that changes with the
/// content (the segment) so a new list starts again at its first banner.
class MediaHeroCarousel extends StatefulWidget {
  const MediaHeroCarousel({
    super.key,
    required this.items,
    this.saveButtonBuilder,
    this.onSaveTap,
    this.onItemTap,
  });

  final List<MediaItem> items;

  /// Replaces the built-in save button on the card for that item.
  final Widget Function(MediaItem item)? saveButtonBuilder;

  /// Used for the built-in save button when [saveButtonBuilder] is `null`.
  final void Function(MediaItem item)? onSaveTap;
  final void Function(MediaItem item)? onItemTap;

  /// How big a card one place behind the focus is, against the focused one.
  static const double neighborScale = 0.8;

  /// How opaque a card one place behind the focus is.
  static const double neighborOpacity = 0.55;

  /// The card's width over the screen's.
  static const double _cardFraction = 0.86;

  /// The widest a card gets (a tablet does not stretch it further).
  static const double _maxCardWidth = 360;

  /// How much of a neighbour shows beside the focused card.
  static const double _peek = 36;

  /// How far a neighbour sits lower than the focused card, for depth.
  static const double _sink = 12;

  /// The cards drawn on each side of the focus.
  static const int _reach = 2;

  @override
  State<MediaHeroCarousel> createState() => _MediaHeroCarouselState();
}

class _MediaHeroCarouselState extends State<MediaHeroCarousel>
    with SingleTickerProviderStateMixin {
  /// The place in the loop being shown, fractional while moving: its value is
  /// the "page". Unbounded, so the loop has no end in either direction.
  late final AnimationController _page = AnimationController.unbounded(
    vsync: this,
  );

  final Map<int, Widget> _cards = {};
  double _cardWidth = 0;

  bool get _loops => widget.items.length > 1;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  /// Pixels of a drag that move the carousel one place.
  double get _spacing => _cardWidth * 0.6;

  void _onDrag(DragUpdateDetails details) {
    if (!_loops) return;
    _page.stop();
    _page.value -= details.delta.dx / _spacing;
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_loops) return;
    final velocity = -details.velocity.pixelsPerSecond.dx / _spacing;
    // A flick carries a little past where the finger let go, at most a place.
    final target = (_page.value + (velocity * 0.12).clamp(-1.0, 1.0)).round();
    _page.animateWith(
      SpringSimulation(
        SpringDescription.withDampingRatio(mass: 1, stiffness: 180, ratio: 1),
        _page.value,
        target.toDouble(),
        velocity,
      ),
    );
  }

  Widget _cardFor(int index, BuildContext context) {
    return _cards.putIfAbsent(index, () {
      final items = widget.items;
      final item = items[index % items.length];
      final onSave = widget.onSaveTap;
      final buildSaveButton = widget.saveButtonBuilder;
      final onTap = widget.onItemTap;
      return SizedBox(
        width: _cardWidth,
        child: MediaCard(
          size: MediaCardSize.hero,
          width: _cardWidth,
          title: item.title,
          posterUrl: item.posterUrl,
          metadata: _heroMetadata(item, context.l10n),
          saveButton: buildSaveButton?.call(item),
          onSaveTap: buildSaveButton == null && onSave != null
              ? () => onSave(item)
              : null,
          onTap: onTap == null ? null : () => onTap(item),
        ),
      );
    });
  }

  @override
  void didUpdateWidget(MediaHeroCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items ||
        oldWidget.saveButtonBuilder != widget.saveButtonBuilder) {
      _cards.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final still = MediaQuery.disableAnimationsOf(context);
    final cardWidth = (width * MediaHeroCarousel._cardFraction).clamp(
      0.0,
      MediaHeroCarousel._maxCardWidth,
    );
    if (cardWidth != _cardWidth) {
      _cardWidth = cardWidth;
      _cards.clear();
    }
    final items = widget.items;

    return SizedBox(
      height: MediaCardSize.hero.height,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: _onDrag,
        onHorizontalDragEnd: _onDragEnd,
        child: AnimatedBuilder(
          animation: _page,
          builder: (context, _) {
            final page = _loops ? _page.value : 0.0;
            final first = page.floor() - MediaHeroCarousel._reach;
            final last = page.ceil() + MediaHeroCarousel._reach;
            final visible = _loops
                ? [for (var i = first; i <= last; i++) i]
                : const [0];
            // The farthest from the focus first, so the nearest is on top.
            final ordered = [...visible]
              ..sort((a, b) => (b - page).abs().compareTo((a - page).abs()));
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                for (final index in ordered)
                  if (items.isNotEmpty)
                    _placed(index, index - page, still, context),
              ],
            );
          },
        ),
      ),
    );
  }

  /// [index]'s card at [offset] places from the focus: shifted, scaled, dimmed.
  Widget _placed(int index, double offset, bool still, BuildContext context) {
    final distance = offset.abs();
    final near = distance.clamp(0.0, 1.0);
    // Past the first place a card keeps drifting out and fades away.
    final far = (distance - 1).clamp(0.0, 1.0);
    final scale = still
        ? 1.0
        : _lerp(1, MediaHeroCarousel.neighborScale, near) - 0.06 * far;
    // The first neighbour's centre: just far enough that only [_peek] of it
    // shows beyond the focused card's edge, whatever its scale.
    final neighbourWidth =
        _cardWidth * (still ? 1 : MediaHeroCarousel.neighborScale);
    final firstShift =
        _cardWidth / 2 + MediaHeroCarousel._peek - neighbourWidth / 2;
    final dx = offset.sign * (firstShift * near + 18 * far);
    final dy = MediaHeroCarousel._sink * near;
    final opacity =
        (_lerp(1, MediaHeroCarousel.neighborOpacity, near) * (1 - far)).clamp(
          0.0,
          1.0,
        );
    return Transform.translate(
      // Keyed by its place in the loop, so a card keeps its state when the
      // stacking order changes.
      key: ValueKey(index),
      offset: Offset(dx, dy),
      child: Transform.scale(
        scale: scale,
        child: IgnorePointer(
          // A card faded out entirely is out of the way of taps too.
          ignoring: opacity <= 0,
          child: Opacity(opacity: opacity, child: _cardFor(index, context)),
        ),
      ),
    );
  }

  static double _lerp(double from, double to, double t) =>
      from + (to - from) * t;
}
