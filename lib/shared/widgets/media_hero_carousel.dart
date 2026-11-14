import 'package:flutter/material.dart';

import '../../core/domain/entities/media_item.dart';
import '../../core/theme/app_spacing.dart';
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

/// The Discover hero (`docs/SCREENS.md` B1): big snapping cards in a row that
/// **loops** — after the last banner the first comes back — with the banner in
/// focus **centered and in full size** and its neighbours peeking in on both
/// sides, smaller ([neighborScale]) and dimmer ([neighborOpacity]).
///
/// The zoom follows the scroll: each card's scale and opacity are worked out
/// from its distance to the page being shown (`PageController.page`), so it
/// grows as it nears the center and shrinks as it leaves, in step with the
/// finger — not a timed animation. With the system's "reduce motion" on, the
/// scale stays 1 for every card (the dimming, which moves nothing, stays).
/// Neighbours are shrunk, not the center enlarged, so the hero's height is
/// always [MediaCardSize.hero]'s and nothing below it shifts.
///
/// Layout: the card is 78% of the page's width (at most [MediaCardSize.hero]'s
/// 330 px) and [AppSpacing.md] apart from the next; every card opens its detail
/// on tap, the neighbours included.
///
/// Pure presentation, no Bloc: [saveButtonBuilder] lets the caller put a
/// button (with its own narrow subscription) on each card without this
/// carousel, or any other card, rebuilding for it (CLAUDE.md rule 9). Only the
/// hero itself repaints as it scrolls. Give it a `ValueKey` that changes with
/// the content (the segment) so a new list starts again at its first banner.
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

  /// How much smaller a card one page away from the center is.
  static const double neighborScale = 0.88;

  /// How opaque a card one page away from the center is.
  static const double neighborOpacity = 0.7;

  /// The card's width over the screen's.
  static const double _cardFraction = 0.78;

  /// How many laps' worth of pages there are before and after the start, so
  /// the carousel can be swiped far in either direction.
  static const int _laps = 1000;

  @override
  State<MediaHeroCarousel> createState() => _MediaHeroCarouselState();
}

class _MediaHeroCarouselState extends State<MediaHeroCarousel> {
  PageController? _controller;
  double? _fraction;

  bool get _loops => widget.items.length > 1;

  int get _initialPage =>
      _loops ? widget.items.length * MediaHeroCarousel._laps : 0;

  /// A controller for [fraction] (the page width over the viewport's),
  /// replaced only when the screen width changes.
  PageController _controllerFor(double fraction) {
    if (_controller == null || _fraction != fraction) {
      _controller?.dispose();
      _fraction = fraction;
      _controller = PageController(
        viewportFraction: fraction,
        initialPage: _initialPage,
      );
    }
    return _controller!;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// The page being shown (fractional while swiping); the first page until
  /// the controller has been laid out.
  double _currentPage(PageController controller) {
    if (controller.hasClients && controller.position.haveDimensions) {
      return controller.page ?? _initialPage.toDouble();
    }
    return _initialPage.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final still = MediaQuery.disableAnimationsOf(context);
    final cardWidth = (width * MediaHeroCarousel._cardFraction).clamp(
      0.0,
      MediaCardSize.hero.width,
    );
    final controller = _controllerFor((cardWidth + AppSpacing.md) / width);

    final items = widget.items;
    final onSave = widget.onSaveTap;
    final buildSaveButton = widget.saveButtonBuilder;
    final onTap = widget.onItemTap;

    return SizedBox(
      height: MediaCardSize.hero.height,
      child: PageView.builder(
        controller: controller,
        clipBehavior: Clip.none,
        itemCount: _loops ? null : items.length,
        itemBuilder: (context, index) {
          final item = items[index % items.length];
          final card = SizedBox(
            width: cardWidth,
            child: MediaCard(
              size: MediaCardSize.hero,
              width: cardWidth,
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
          return AnimatedBuilder(
            animation: controller,
            // The card itself is built once; only its scale/opacity follow
            // the scroll.
            child: Center(child: card),
            builder: (context, child) {
              final distance = (_currentPage(controller) - index).abs().clamp(
                0.0,
                1.0,
              );
              final scale = still
                  ? 1.0
                  : _lerp(1, MediaHeroCarousel.neighborScale, distance);
              return Opacity(
                opacity: _lerp(1, MediaHeroCarousel.neighborOpacity, distance),
                child: Transform.scale(scale: scale, child: child),
              );
            },
          );
        },
      ),
    );
  }

  static double _lerp(double from, double to, double t) =>
      from + (to - from) * t;
}
