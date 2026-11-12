import 'package:flutter/material.dart';

import '../../core/domain/entities/trailer_item.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n_extension.dart';
import 'media_backdrop_carousel.dart';

/// B1's "Latest trailers": the same wide cards as B2's "Top rated"
/// ([MediaBackdropCarousel]'s size), but each is a still of the film under a
/// centered play button — tapping calls [onTrailerTap] (the screen opens
/// YouTube; nothing plays in the app). The still is the film's backdrop, or
/// the video's own YouTube thumbnail when TMDB has no backdrop.
///
/// Pure presentation: everything comes in by parameter.
class TrailerCarousel extends StatelessWidget {
  const TrailerCarousel({super.key, required this.trailers, this.onTrailerTap});

  final List<TrailerItem> trailers;
  final void Function(TrailerItem trailer)? onTrailerTap;

  /// YouTube's own still for a video, used when the film has no backdrop.
  static String thumbnailUrl(String videoKey) =>
      'https://img.youtube.com/vi/$videoKey/hqdefault.jpg';

  static const double _peek = 36;
  static const double _playSize = 52;

  @override
  Widget build(BuildContext context) {
    final available =
        MediaQuery.sizeOf(context).width - AppSpacing.screenMargin * 2;
    final width = (available - _peek).clamp(
      0.0,
      MediaBackdropCarousel.cardWidth,
    );
    return SizedBox(
      height: MediaBackdropCarousel.cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: trailers.length,
        itemBuilder: (context, index) {
          final trailer = trailers[index];
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : AppSpacing.md),
            child: _TrailerCard(
              trailer: trailer,
              width: width,
              onTap: onTrailerTap == null ? null : () => onTrailerTap!(trailer),
            ),
          );
        },
      ),
    );
  }
}

class _TrailerCard extends StatelessWidget {
  const _TrailerCard({
    required this.trailer,
    required this.width,
    required this.onTap,
  });

  final TrailerItem trailer;
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final item = trailer.item;
    final image =
        item.backdropUrl ?? TrailerCarousel.thumbnailUrl(trailer.video.key);
    return Semantics(
      button: onTap != null,
      label: context.l10n.trailerPlayLabel(item.title),
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
                        AppColors.surface.withValues(alpha: 0.2),
                        AppColors.surface.withValues(alpha: 0.92),
                      ],
                    ),
                  ),
                ),
                const Center(child: _PlayButton()),
                Positioned(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: Text(
                    item.title,
                    style: AppTextStyles.h3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _PlayButton extends StatelessWidget {
  const _PlayButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: TrailerCarousel._playSize,
      height: TrailerCarousel._playSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.glass,
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: const Icon(AppIcons.play, color: AppColors.ink),
    );
  }
}
