import 'package:flutter/material.dart';

import '../../core/domain/entities/media_item.dart';
import '../../core/domain/entities/media_type.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'focus_zoom_list.dart';
import 'media_card.dart';
import 'ranked_poster.dart';

/// A horizontal row of poster cards — the section carousels (the Discover
/// hero is `MediaHeroCarousel`).
///
/// Source of truth: `docs/SCREENS.md` B1 (Discover) and
/// `docs/DECISIONS.md` section 9 ("110×165 posters with 12 px gaps, 3.2
/// visible... up to 8 cards, 330×380... with snap and a 24 px peek of the
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
  /// the corner; movies don't"). [onItemTap] is called with the tapped
  /// item — see `docs/SCREENS.md` B1 ("Tap → detail with Hero
  /// transition").
  const MediaCarousel.standard({
    super.key,
    required this.items,
    this.showTypeTag = false,
    this.onItemTap,
    this.ranked = false,
    this.size = MediaCardSize.carousel,
    this.overlayBuilder,
    this.captionBuilder,
    this.captionStyle,
    this.overlayAtBottom = false,
    this.focusZoom = false,
  });

  final List<MediaItem> items;
  final bool showTypeTag;

  /// A big 1, 2, 3… over each poster's bottom-left corner (B2's "Top today").
  final bool ranked;

  /// The poster at the leading edge is full size and the others shrink a
  /// little with distance as it scrolls ([FocusZoomList]).
  final bool focusZoom;

  /// The poster size: [MediaCardSize.carousel] (default), or the larger and
  /// smaller `carousel*` variants B2 uses to give its sections different
  /// weight.
  final MediaCardSize size;

  /// A widget laid over each poster's top-left corner (a "NEW" or rating
  /// badge); `null` result = none for that item.
  final Widget? Function(MediaItem item)? overlayBuilder;

  /// A line of text under each poster (Coming soon's release date); `null`
  /// result = none for that item.
  final String? Function(MediaItem item)? captionBuilder;

  /// The caption's style: the small muted line by default; a title under a
  /// poster (Hidden gems) uses the body style.
  final TextStyle? captionStyle;

  /// Put [overlayBuilder]'s widget in the poster's bottom-left corner instead
  /// of the top-left one — which is then free for the "TV" tag.
  final bool overlayAtBottom;
  final void Function(MediaItem item)? onItemTap;

  @override
  Widget build(BuildContext context) {
    return _buildStandard(context);
  }

  static final TextStyle _defaultCaption = AppTextStyles.caption.copyWith(
    color: AppColors.inkMuted,
  );

  /// Room under a poster for [captionBuilder]'s one line of text at the
  /// current text scale.
  double _captionHeight(BuildContext context) {
    final style = captionStyle ?? _defaultCaption;
    final line = MediaQuery.textScalerOf(
      context,
    ).scale(style.fontSize! * style.height!);
    return AppSpacing.xs + line.ceilToDouble() + 1;
  }

  Widget _list({required IndexedWidgetBuilder itemBuilder}) {
    if (focusZoom) {
      return FocusZoomList(
        itemCount: items.length,
        itemExtent: size.width + AppSpacing.md,
        itemBuilder: itemBuilder,
      );
    }
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      itemBuilder: itemBuilder,
    );
  }

  Widget _buildStandard(BuildContext context) {
    final hasCaption = captionBuilder != null;
    return SizedBox(
      height: size.height + (hasCaption ? _captionHeight(context) : 0),
      child: _list(
        itemBuilder: (context, index) {
          final item = items[index];
          final onTap = onItemTap;
          final overlay = overlayBuilder?.call(item);
          final caption = captionBuilder?.call(item);
          final card = RankedPoster(
            rank: ranked ? index + 1 : null,
            child: MediaCard(
              size: size,
              title: item.title,
              posterUrl: item.posterUrl,
              showTypeTag: showTypeTag && item.type == MediaType.tvShow,
              onTap: onTap == null ? null : () => onTap(item),
            ),
          );
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : AppSpacing.md),
            child: SizedBox(
              width: size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      card,
                      if (overlay != null)
                        Positioned(
                          left: AppSpacing.xs,
                          top: overlayAtBottom ? null : AppSpacing.xs,
                          bottom: overlayAtBottom ? AppSpacing.xs : null,
                          child: IgnorePointer(child: overlay),
                        ),
                    ],
                  ),
                  if (hasCaption)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        caption ?? '',
                        style: captionStyle ?? _defaultCaption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
