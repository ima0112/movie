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
import '../../../../shared/widgets/media_carousel.dart';
import '../cubit/discover_cubit.dart';
import 'discover_section_skeleton.dart';

/// One named carousel (see `docs/SCREENS.md` B1's per-segment section
/// lists). Carries its own `BlocSelector` on just
/// `DiscoverLoaded.carousels[section]` — the structure a future
/// per-section-loading `DiscoverCubit` needs: an unaffected section's
/// selected value stays equal across emissions, so only the section that
/// actually changed rebuilds (CLAUDE.md rule 9). Renders its own
/// [DiscoverSectionSkeleton] while that value is still `null` for this
/// segment.
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
    return BlocSelector<DiscoverCubit, DiscoverState, List<MediaItem>?>(
      selector: (state) {
        if (state is DiscoverLoaded && state.segment == segment) {
          return state.carousels[section];
        }
        return null;
      },
      builder: (context, items) {
        if (items != null && items.isEmpty) {
          return const SizedBox.shrink();
        }
        if (items == null) {
          return const AppSection(child: DiscoverSectionSkeleton());
        }
        final label = section.localizedLabel(context.l10n);
        return AppSection(
          title: label,
          actionLabel: context.l10n.discoverSeeAll,
          // C1: "'See all' from B1 (arrives with the collection's name and no
          // filters)" — `collectionSection` is what lets C1 fetch this exact
          // collection instead of a plain discover() call until a filter
          // gets touched (see `FilteredListCubit`'s own doc comment).
          onAction: () => context.push(
            AppRoutes.filteredList,
            extra: FilteredListRouteArgs(
              filter: DiscoverFilter(type: segment.mediaType),
              title: label,
              collectionSection: section,
            ),
          ),
          child: MediaCarousel.standard(
            items: items,
            // TV posters carry a "TV" pill only in the mixed "All" segment —
            // see docs/SCREENS.md B1.
            showTypeTag: segment == MediaSegment.all,
            // `pushMediaDetail` (→ `push`, not `go`): the detail screen's back
            // button should return to Discover with its scroll position
            // intact, not replace it in the stack.
            onItemTap: (item) => context.pushMediaDetail(item.key),
          ),
        );
      },
    );
  }
}
