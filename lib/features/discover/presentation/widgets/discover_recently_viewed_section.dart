import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/media_carousel.dart';
import '../cubit/recently_viewed_cubit.dart';

/// B1's "Recently viewed" (All tab only): the standard poster carousel of the
/// titles whose detail the user opened last (at most 10, newest first), each
/// with the "TV" tag when it's a show — movies and shows are mixed here. Tap →
/// that detail. Nothing at all until something has been viewed. Its own
/// `BlocBuilder` on just the list (CLAUDE.md rule 9); it needs no network, so
/// it isn't wrapped in `LazyLoad`.
class DiscoverRecentlyViewedSection extends StatelessWidget {
  const DiscoverRecentlyViewedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecentlyViewedCubit, List<MediaItem>>(
      builder: (context, items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return AppSection(
          title: context.l10n.carouselSectionRecentlyViewed,
          child: MediaCarousel.standard(
            items: items,
            showTypeTag: true,
            onItemTap: (item) => context.pushMediaDetail(item.key),
          ),
        );
      },
    );
  }
}
