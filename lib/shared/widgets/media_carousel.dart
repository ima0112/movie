import 'package:flutter/material.dart';

import '../../core/domain/entities/media_item.dart';
import '../../core/domain/entities/media_type.dart';
import '../../core/theme/app_spacing.dart';
import 'media_card.dart';

/// A horizontal row of poster cards — the section carousels and the
/// Discover hero.
///
/// Source of truth: `docs/SCREENS.md` B1 (Discover) and
/// `docs/DECISIONS.md` section 9 ("110×165 posters with 12 px gaps, 3.2
/// visible... up to 8 cards, 330×440... with snap and a 24 px peek of the
/// next one.").
///
/// Pure presentation — no feature or Bloc dependency, everything comes in
/// by parameter. Per the project's CLAUDE.md rule 9, this widget has no
/// opinion on rebuild granularity itself (it doesn't touch a Cubit at
/// all) — whoever wires it to `DiscoverCubit` is responsible for scoping
/// its `BlocBuilder`/`BlocSelector` narrowly.
class MediaCarousel extends StatelessWidget {
  /// A section carousel: 110×165 cards, 12 px gaps, no snap, free scroll.
  /// [showTypeTag] applies only to TV items — movies never get the tag
  /// (see `docs/SCREENS.md` B1: "TV posters carry a small 'TV' pill in
  /// the corner; movies don't").
  const MediaCarousel.standard({
    super.key,
    required this.items,
    this.showTypeTag = false,
  }) : _isHero = false,
       onSaveTap = null;

  /// The Discover hero: 330×440 cards, snapping, a 24 px peek of the next
  /// card. [onSaveTap] is called with the item whose save button was
  /// tapped.
  const MediaCarousel.hero({super.key, required this.items, this.onSaveTap})
    : _isHero = true,
      showTypeTag = false;

  final List<MediaItem> items;
  final bool showTypeTag;
  final void Function(MediaItem item)? onSaveTap;
  final bool _isHero;

  // docs/SCREENS.md B1: "24 px peek of the next one".
  static const double _heroPeek = 24;

  @override
  Widget build(BuildContext context) {
    return _isHero ? _buildHero(context) : _buildStandard(context);
  }

  Widget _buildStandard(BuildContext context) {
    return SizedBox(
      height: MediaCardSize.carousel.height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : AppSpacing.md),
            child: MediaCard(
              size: MediaCardSize.carousel,
              title: item.title,
              posterUrl: item.posterUrl,
              showTypeTag: showTypeTag && item.type == MediaType.tvShow,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    // The PageView spans the full available width, so a fraction computed
    // from that same width — rather than a fixed literal — keeps the
    // rendered page exactly `card width + peek` wide on any device.
    final availableWidth = MediaQuery.sizeOf(context).width;
    final viewportFraction =
        (MediaCardSize.hero.width + _heroPeek) / availableWidth;

    return SizedBox(
      height: MediaCardSize.hero.height,
      child: PageView.builder(
        controller: PageController(viewportFraction: viewportFraction),
        // Without this, PageView adds a leading/trailing gap so the first
        // and last cards can center when scrolled to an end — that would
        // pull the first card in from the edge, breaking the full-bleed
        // look and shifting the 24 px peek measurement.
        padEnds: false,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final onSave = onSaveTap;
          return Padding(
            padding: const EdgeInsets.only(right: _heroPeek),
            child: MediaCard(
              size: MediaCardSize.hero,
              title: item.title,
              posterUrl: item.posterUrl,
              onSaveTap: onSave == null ? null : () => onSave(item),
            ),
          );
        },
      ),
    );
  }
}
