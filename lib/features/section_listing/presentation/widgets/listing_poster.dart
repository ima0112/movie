import 'package:flutter/material.dart';

import '../../../../core/domain/entities/media_item.dart';
import '../../../../shared/widgets/result_poster_tile.dart';
import '../../domain/listing_style.dart';

/// One title of the "See all" grid: the results tile ([ResultPosterTile]) —
/// poster, title and, under it, the release year (the full date for
/// [ListingStyle.dated], the upcoming sections). [ListingStyle.ranked] puts the
/// position over the poster instead of the rating.
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

  @override
  Widget build(BuildContext context) {
    return ResultPosterTile(
      item: item,
      onTap: onTap,
      showPlatform: showPlatform,
      rank: style == ListingStyle.ranked ? rank : null,
      fullDate: style == ListingStyle.dated,
    );
  }
}
