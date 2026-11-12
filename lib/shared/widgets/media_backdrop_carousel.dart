import 'package:flutter/material.dart';

import '../../core/domain/entities/media_item.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n_extension.dart';
import '../../l10n/number_format_extension.dart';
import 'poster_badge.dart';

/// The big wide cards of B2's "Top rated" — the section that gets the most
/// weight: each is a 16:9 backdrop (the poster when TMDB has none) under a
/// fade to the page color, with the title, the year and a rating badge on it.
/// A horizontally scrolling row; cards are ~300 px wide and narrower on a
/// small phone so the next one still peeks in.
///
/// Pure presentation: everything comes in by parameter.
class MediaBackdropCarousel extends StatelessWidget {
  const MediaBackdropCarousel({super.key, required this.items, this.onItemTap});

  final List<MediaItem> items;
  final void Function(MediaItem item)? onItemTap;

  static const double cardWidth = 300;
  static const double cardHeight = 170;

  /// How much of the next card shows at the right edge of the screen.
  static const double _peek = 36;

  @override
  Widget build(BuildContext context) {
    final available =
        MediaQuery.sizeOf(context).width - AppSpacing.screenMargin * 2;
    // Narrower on a small phone so the peek survives.
    final width = (available - _peek).clamp(0.0, cardWidth);
    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : AppSpacing.md),
            child: _BackdropCard(
              item: item,
              width: width,
              onTap: onItemTap == null ? null : () => onItemTap!(item),
            ),
          );
        },
      ),
    );
  }
}

class _BackdropCard extends StatelessWidget {
  const _BackdropCard({
    required this.item,
    required this.width,
    required this.onTap,
  });

  final MediaItem item;
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final image = item.backdropUrl ?? item.posterUrl;
    final year = item.releaseDate?.year;
    return Semantics(
      button: onTap != null,
      label: item.title,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: SizedBox(
            width: width,
            height: MediaBackdropCarousel.cardHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (image == null)
                  const ColoredBox(color: AppColors.surfaceRaised2)
                else
                  Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const ColoredBox(color: AppColors.surfaceRaised2),
                  ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.35, 1],
                      colors: [
                        AppColors.surface.withValues(alpha: 0),
                        AppColors.surface.withValues(alpha: 0.92),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: AppSpacing.md,
                  top: AppSpacing.md,
                  child: PosterBadge.rating(
                    label: item.voteAverage.localizedRating(l10n),
                  ),
                ),
                Positioned(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        style: AppTextStyles.h3,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (year != null)
                        Text(
                          '$year',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.inkMuted,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
