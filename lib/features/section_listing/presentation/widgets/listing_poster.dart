import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/number_format_extension.dart';
import '../../../../shared/widgets/media_card.dart';
import '../../../../shared/widgets/poster_badge.dart';
import '../../../../shared/widgets/ranked_poster.dart';
import '../../domain/listing_style.dart';
import 'listing_platform_logo.dart';

/// One poster of the "See all" grid, dressed by [style] (see
/// `listingStyleFor`): a rank, a rating badge, the date or year, or the title.
/// The dressing cross-fades when the style changes (a re-sort), unless the
/// system asks for reduced motion.
class ListingPoster extends StatelessWidget {
  const ListingPoster({
    super.key,
    required this.item,
    required this.style,
    required this.rank,
    required this.onTap,
    this.showPlatform = false,
  });

  final MediaItem item;
  final ListingStyle style;

  /// 1-based position, used by [ListingStyle.ranked].
  final int rank;
  final VoidCallback onTap;

  /// Show the platform the title streams on, top-right.
  final bool showPlatform;

  static const Duration _fade = Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return Stack(
      children: [
        Positioned.fill(
          child: MediaCard(
            size: MediaCardSize.grid,
            title: item.title,
            posterUrl: item.posterUrl,
            // The rating badge takes the corner the "TV" tag would sit in.
            showTypeTag:
                item.type == MediaType.tvShow && style != ListingStyle.rating,
            onTap: onTap,
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedSwitcher(
              duration: still ? Duration.zero : _fade,
              child: KeyedSubtree(
                key: ValueKey(style),
                child: _Dressing(item: item, style: style, rank: rank),
              ),
            ),
          ),
        ),
        if (showPlatform)
          Positioned.fill(
            child: IgnorePointer(
              child: ListingPlatformLogo(titleKey: item.key),
            ),
          ),
      ],
    );
  }
}

class _Dressing extends StatelessWidget {
  const _Dressing({
    required this.item,
    required this.style,
    required this.rank,
  });

  final MediaItem item;
  final ListingStyle style;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final date = item.releaseDate;
    return switch (style) {
      ListingStyle.plain => const SizedBox.shrink(),
      ListingStyle.ranked => RankOverlay(rank: rank, compact: true),
      ListingStyle.rating => _Corner(
        alignment: Alignment.topLeft,
        child: PosterBadge.rating(
          label: item.voteAverage.localizedRating(l10n),
        ),
      ),
      ListingStyle.dated =>
        date == null
            ? const SizedBox.shrink()
            : _Corner(
                alignment: Alignment.bottomLeft,
                child: PosterBadge(
                  label: DateFormat.yMMMd(l10n.localeName).format(date),
                ),
              ),
      ListingStyle.year =>
        date == null
            ? const SizedBox.shrink()
            : _Corner(
                alignment: Alignment.bottomLeft,
                child: PosterBadge(label: '${date.year}'),
              ),
      ListingStyle.titled => _TitleOverlay(title: item.title),
    };
  }
}

class _Corner extends StatelessWidget {
  const _Corner({required this.alignment, required this.child});

  final Alignment alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: child,
      ),
    );
  }
}

/// The title on a fade at the poster's foot.
class _TitleOverlay extends StatelessWidget {
  const _TitleOverlay({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.surface.withValues(alpha: 0),
                AppColors.surface.withValues(alpha: 0.9),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                title,
                style: AppTextStyles.captionStrong,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
