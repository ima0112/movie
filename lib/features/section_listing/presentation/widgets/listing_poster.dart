import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/number_format_extension.dart';
import '../../../../shared/widgets/media_card.dart';
import '../../../../shared/widgets/poster_badge.dart';
import '../../../../shared/widgets/ranked_poster.dart';
import '../../domain/listing_style.dart';

/// One poster of the "See all" grid, dressed like the carousel it came from
/// ([style]): a rank, a rating badge, or the release date and year.
class ListingPoster extends StatelessWidget {
  const ListingPoster({
    super.key,
    required this.item,
    required this.style,
    required this.rank,
    required this.onTap,
  });

  final MediaItem item;
  final ListingStyle style;

  /// 1-based position, shown only for [ListingStyle.ranked]; `null` once the
  /// list is re-sorted (a rank only means something in the section's own
  /// order).
  final int? rank;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final card = MediaCard(
      size: MediaCardSize.grid,
      title: item.title,
      posterUrl: item.posterUrl,
      showTypeTag: item.type == MediaType.tvShow,
      onTap: onTap,
    );
    return switch (style) {
      ListingStyle.plain => card,
      ListingStyle.ranked => RankedPoster(rank: rank, child: card),
      ListingStyle.rating => Stack(
        children: [
          Positioned.fill(child: card),
          Positioned(
            left: AppSpacing.xs,
            top: AppSpacing.xs,
            child: IgnorePointer(
              child: PosterBadge.rating(
                label: item.voteAverage.localizedRating(l10n),
              ),
            ),
          ),
        ],
      ),
      ListingStyle.dated => Stack(
        children: [
          Positioned.fill(child: card),
          if (item.releaseDate case final date?)
            Positioned(
              left: AppSpacing.xs,
              bottom: AppSpacing.xs,
              child: IgnorePointer(
                child: PosterBadge(
                  label: DateFormat.yMMMd(l10n.localeName).format(date),
                ),
              ),
            ),
        ],
      ),
    };
  }
}
