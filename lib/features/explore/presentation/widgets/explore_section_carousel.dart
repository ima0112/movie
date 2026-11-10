import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_segment.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/number_format_extension.dart';
import '../../../../shared/widgets/media_backdrop_carousel.dart';
import '../../../../shared/widgets/media_card.dart';
import '../../../../shared/widgets/media_carousel.dart';
import '../../../../shared/widgets/poster_badge.dart';
import '../../domain/explore_section.dart';

/// The carousel for one B2 section. They deliberately don't all look alike —
/// size and shape carry the section's weight, so the page has a rhythm
/// instead of six identical rows:
///
/// | Section | Treatment |
/// |---|---|
/// | Top today | large posters (150×225) with a big rank number |
/// | Popular | the standard poster (110×165), the plain baseline |
/// | Top rated | wide backdrop cards (the lead section) |
/// | New releases | medium posters (130×195) with a "NEW" badge |
/// | Coming soon | small posters (90×135) with the release date under each |
/// | Hidden gems | medium posters with an amber rating badge |
class ExploreSectionCarousel extends StatelessWidget {
  const ExploreSectionCarousel({
    super.key,
    required this.section,
    required this.items,
    required this.segment,
    required this.onItemTap,
  });

  final ExploreSection section;
  final List<MediaItem> items;
  final MediaSegment segment;
  final void Function(MediaItem item) onItemTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tvTag = segment == MediaSegment.all;
    return switch (section) {
      ExploreSection.topToday => MediaCarousel.standard(
        items: items,
        size: MediaCardSize.carouselLarge,
        ranked: true,
        showTypeTag: tvTag,
        onItemTap: onItemTap,
      ),
      ExploreSection.popular => MediaCarousel.standard(
        items: items,
        showTypeTag: tvTag,
        onItemTap: onItemTap,
      ),
      ExploreSection.topRated => MediaBackdropCarousel(
        items: items,
        onItemTap: onItemTap,
      ),
      ExploreSection.newReleases => MediaCarousel.standard(
        items: items,
        size: MediaCardSize.carouselMedium,
        showTypeTag: tvTag,
        overlayBuilder: (_) =>
            PosterBadge(label: l10n.exploreNewTag, amber: true),
        onItemTap: onItemTap,
      ),
      ExploreSection.comingSoon => MediaCarousel.standard(
        items: items,
        size: MediaCardSize.carouselSmall,
        showTypeTag: tvTag,
        captionBuilder: (item) {
          final date = item.releaseDate;
          return date == null
              ? null
              : DateFormat.MMMd(l10n.localeName).format(date);
        },
        onItemTap: onItemTap,
      ),
      ExploreSection.hiddenGems => MediaCarousel.standard(
        items: items,
        size: MediaCardSize.carouselMedium,
        showTypeTag: false,
        overlayBuilder: (item) =>
            PosterBadge.rating(label: item.voteAverage.localizedRating(l10n)),
        onItemTap: onItemTap,
      ),
    };
  }
}
