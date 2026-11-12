import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../l10n/carousel_section_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/lazy_load.dart';
import '../../../../shared/widgets/media_carousel.dart';
import 'discover_content_error.dart';
import '../cubit/discover_cubit.dart';
import 'discover_section_skeleton.dart';

/// One named carousel (see `docs/SCREENS.md` B1's per-segment section
/// lists). **Loads on demand** (CLAUDE.md rule 17): wrapped in `LazyLoad`, it
/// asks the cubit for its data only when it nears the viewport. Carries its
/// own `BlocSelector` on just its slot of `DiscoverLoaded.carousels`, so an
/// unaffected section stays untouched when another one changes (rule 9);
/// shows a skeleton while loading and a retry row on error.
class DiscoverSectionCarousel extends StatelessWidget {
  const DiscoverSectionCarousel({
    super.key,
    required this.segment,
    required this.section,
  });

  final MediaSegment segment;
  final CarouselSection section;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      DiscoverCubit,
      DiscoverState,
      DiscoverSlot<List<MediaItem>>?
    >(
      selector: (state) {
        if (state is DiscoverLoaded && state.segment == segment) {
          return state.carousels[section];
        }
        return null;
      },
      builder: (context, slot) {
        final label = section.localizedLabel(context.l10n);
        return LazyLoad(
          onNear: () => context.read<DiscoverCubit>().requestSection(section),
          child: switch (slot) {
            null || DiscoverSlotLoading() => const AppSection(
              child: DiscoverSectionSkeleton(),
            ),
            DiscoverSlotError() => AppSection(
              title: label,
              child: DiscoverContentError(
                onRetry: () =>
                    context.read<DiscoverCubit>().retrySection(section),
              ),
            ),
            DiscoverSlotLoaded(:final value) when value.isEmpty =>
              const SizedBox.shrink(),
            DiscoverSlotLoaded(:final value) => AppSection(
              title: label,
              actionLabel: context.l10n.discoverSeeAll,
              // C1: "'See all' from B1 (arrives with the collection's name and
              // no filters)" — `collectionSection` lets C1 fetch this exact
              // collection until a filter gets touched.
              onAction: () => context.push(
                AppRoutes.filteredList,
                extra: FilteredListRouteArgs(
                  filter: DiscoverFilter(type: segment.mediaType),
                  title: label,
                  collectionSection: section,
                ),
              ),
              child: MediaCarousel.standard(
                items: value,
                // TV posters carry a "TV" pill only in the mixed "All"
                // segment — see docs/SCREENS.md B1.
                showTypeTag: segment == MediaSegment.all,
                // `push`, not `go`: back returns to Discover with its scroll
                // position intact.
                onItemTap: (item) => context.pushMediaDetail(item.key),
              ),
            ),
          },
        );
      },
    );
  }
}
