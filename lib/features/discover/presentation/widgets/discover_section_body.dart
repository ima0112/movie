import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/router.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/number_format_extension.dart';
import '../../../../shared/widgets/media_backdrop_carousel.dart';
import '../../../../shared/widgets/media_card.dart';
import '../../../../shared/widgets/media_carousel.dart';
import '../../../../shared/widgets/poster_badge.dart';

/// The carousel of one B1 section. Like B2, sections deliberately don't all
/// look alike — size and shape carry a section's weight:
///
/// | Section | Treatment |
/// |---|---|
/// | Popular this week, Trending | large posters (150×225) |
/// | Top rated | wide backdrop cards with the rating |
/// | In theaters, Airing now | medium posters (130×195) |
/// | Finished shows | medium posters with an amber rating badge |
/// | Coming soon, Upcoming | small posters (90×135), release date under each |
/// | Watch later, Popular (TV) | the standard poster (110×165) |
class DiscoverSectionBody extends StatelessWidget {
  const DiscoverSectionBody({
    super.key,
    required this.section,
    required this.segment,
    required this.items,
  });

  final CarouselSection section;
  final MediaSegment segment;
  final List<MediaItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // TV posters carry a "TV" pill only in the mixed "All" segment.
    final tvTag = segment == MediaSegment.all;
    void open(MediaItem item) => context.pushMediaDetail(item.key);
    return switch (section) {
      CarouselSection.popularThisWeek ||
      CarouselSection.trending => MediaCarousel.standard(
        items: items,
        size: MediaCardSize.carouselLarge,
        showTypeTag: tvTag,
        onItemTap: open,
      ),
      CarouselSection.topRated => MediaBackdropCarousel(
        items: items,
        onItemTap: open,
      ),
      CarouselSection.inTheaters ||
      CarouselSection.airingNow => MediaCarousel.standard(
        items: items,
        size: MediaCardSize.carouselMedium,
        showTypeTag: tvTag,
        onItemTap: open,
      ),
      CarouselSection.finishedShows => MediaCarousel.standard(
        items: items,
        size: MediaCardSize.carouselMedium,
        overlayBuilder: (item) =>
            PosterBadge.rating(label: item.voteAverage.localizedRating(l10n)),
        onItemTap: open,
      ),
      CarouselSection.comingSoon ||
      CarouselSection.upcoming => MediaCarousel.standard(
        items: items,
        size: MediaCardSize.carouselSmall,
        showTypeTag: tvTag,
        captionBuilder: (item) {
          final date = item.releaseDate;
          return date == null
              ? null
              : DateFormat.MMMd(l10n.localeName).format(date);
        },
        onItemTap: open,
      ),
      CarouselSection.watchLater ||
      CarouselSection.popular => MediaCarousel.standard(
        items: items,
        showTypeTag: tvTag,
        onItemTap: open,
      ),
    };
  }
}
