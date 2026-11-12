import 'package:flutter/material.dart';

import '../../core/domain/entities/media_item.dart';
import '../../core/domain/entities/media_type.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
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
  });

  final List<MediaItem> items;
  final bool showTypeTag;

  /// A big 1, 2, 3… over each poster's bottom-left corner (B2's "Top today").
  final bool ranked;

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
  final void Function(MediaItem item)? onItemTap;

  @override
  Widget build(BuildContext context) {
    return _buildStandard(context);
  }

  /// Room under a poster for [captionBuilder]'s one line of text.
  static const double _captionHeight = 28;

  Widget _buildStandard(BuildContext context) {
    final hasCaption = captionBuilder != null;
    return SizedBox(
      height: size.height + (hasCaption ? _captionHeight : 0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
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
                          top: AppSpacing.xs,
                          child: IgnorePointer(child: overlay),
                        ),
                    ],
                  ),
                  if (hasCaption)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        caption ?? '',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.inkMuted,
                        ),
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
