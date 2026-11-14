import 'package:flutter/material.dart';

import '../../core/domain/entities/media_item.dart';
import '../../core/domain/entities/media_type.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/full_date_format.dart';
import '../../l10n/l10n_extension.dart';
import '../../l10n/number_format_extension.dart';
import 'listing_platform_logo.dart';
import 'media_card.dart';
import 'poster_badge.dart';
import 'ranked_poster.dart';

/// One title of a list of results: the 2:3 poster with its rating badge
/// (bottom-left) and a "TV" tag when it is a show (top-left), and its title
/// under it on one line, then its release year — or, with [fullDate], the whole
/// release date (upcoming titles). With a [rank] its outlined number takes the
/// rating's place. Sized by [ResultsGrid.delegate] with
/// `captionExtent: ResultsGrid.captionExtent(context)`.
///
/// Pure presentation — everything comes in by parameter.
class ResultPosterTile extends StatelessWidget {
  const ResultPosterTile({
    super.key,
    required this.item,
    required this.onTap,
    this.showPlatform = false,
    this.rank,
    this.fullDate = false,
  });

  final MediaItem item;
  final VoidCallback onTap;

  /// The platform the title streams on, as a small logo in the poster's
  /// top-right corner ([ListingPlatformLogo]) — for a list not narrowed to a
  /// platform. Needs a `ListingProvidersCubit` above it.
  final bool showPlatform;

  /// 1-based position: shown over the poster's foot instead of the rating.
  final int? rank;

  /// The subtitle is the full release date (`12 Jan, 2026`), not just the year.
  final bool fullDate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            MediaCard(
              size: MediaCardSize.grid,
              title: item.title,
              posterUrl: item.posterUrl,
              showTypeTag: item.type == MediaType.tvShow,
              onTap: onTap,
            ),
            if (showPlatform)
              Positioned.fill(
                child: IgnorePointer(
                  child: ListingPlatformLogo(titleKey: item.key),
                ),
              ),
            // Unrated titles (no votes yet) have no badge, not a "0.0".
            if (rank case final rank?)
              Positioned.fill(child: RankOverlay(rank: rank, compact: true))
            else if (item.voteAverage > 0)
              Positioned(
                left: AppSpacing.xs,
                bottom: AppSpacing.xs,
                child: IgnorePointer(
                  child: PosterBadge.rating(
                    label: item.voteAverage.localizedRating(l10n),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          item.title,
          style: AppTextStyles.bodySm,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // The release year, when TMDB has a date (not yet released titles
        // may not).
        if (item.releaseDate case final date?)
          Text(
            fullDate ? l10n.fullDate(date) : '${date.year}',
            style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
            maxLines: 1,
          ),
      ],
    );
  }
}
