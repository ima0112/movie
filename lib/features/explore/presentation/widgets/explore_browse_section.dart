import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/lazy_load.dart';
import '../../../discover/presentation/widgets/discover_content_error.dart';
import '../../../discover/presentation/widgets/discover_section_skeleton.dart';
import '../../domain/explore_section.dart';
import '../cubit/explore_browse_cubit.dart';
import '../cubit/explore_browse_state.dart';
import '../../../section_listing/domain/listing_source.dart';
import '../../../section_listing/domain/listing_style.dart';
import 'explore_section_carousel.dart';

/// The localized heading of a B2 body section.
String exploreSectionTitle(ExploreSection section, AppLocalizations l10n) =>
    switch (section) {
      ExploreSection.topToday => l10n.exploreSectionTopToday,
      ExploreSection.popular => l10n.exploreSectionPopular,
      ExploreSection.topRated => l10n.exploreSectionTopRated,
      ExploreSection.newReleases => l10n.exploreSectionNewReleases,
      ExploreSection.comingSoon => l10n.exploreSectionComingSoon,
      ExploreSection.hiddenGems => l10n.exploreSectionHiddenGems,
    };

/// One of B2's body sections: its own heading with "See all" (→ C1 with the
/// very filter that produced the carousel), its own kind of carousel (see
/// `ExploreSectionCarousel`), a skeleton while loading, or a retry row on
/// error. A section that loads empty draws nothing.
///
/// **Loads on demand** (CLAUDE.md rule 17): wrapped in `LazyLoad`, it asks the
/// cubit for its data only when it nears the viewport — and again when the
/// filters change (`revision`) while it is near. Watches only its own slot of
/// the state (CLAUDE.md rule 9).
class ExploreBrowseSection extends StatelessWidget {
  const ExploreBrowseSection({super.key, required this.section});

  final ExploreSection section;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      ExploreBrowseCubit,
      ExploreBrowseState,
      (int, ExploreSectionState)
    >(
      selector: (state) => (state.revision, state.sectionState(section)),
      builder: (context, selected) {
        final (revision, state) = selected;
        final l10n = context.l10n;
        final title = exploreSectionTitle(section, l10n);
        return LazyLoad(
          loadKey: revision,
          onNear: () =>
              context.read<ExploreBrowseCubit>().requestSection(section),
          child: switch (state) {
            ExploreSectionLoading() => const AppSection(
              child: DiscoverSectionSkeleton(),
            ),
            ExploreSectionError() => AppSection(
              title: title,
              child: DiscoverContentError(
                onRetry: () =>
                    context.read<ExploreBrowseCubit>().retrySection(section),
              ),
            ),
            ExploreSectionLoaded(:final items) when items.isEmpty =>
              const SizedBox.shrink(),
            ExploreSectionLoaded(:final items) => AppSection(
              title: title,
              subtitle: section == ExploreSection.topRated
                  ? l10n.exploreSectionTopRatedSubtitle
                  : null,
              actionLabel: l10n.discoverSeeAll,
              onAction: () => _seeAll(context, title),
              child: ExploreSectionCarousel(
                section: section,
                items: items,
                segment: context.read<ExploreBrowseCubit>().state.segment,
                onItemTap: (MediaItem item) =>
                    context.pushMediaDetail(item.key),
              ),
            ),
          },
        );
      },
    );
  }

  /// C1b with the same filter the section previewed, in the current segment.
  void _seeAll(BuildContext context, String title) {
    final browse = context.read<ExploreBrowseCubit>().state;
    final today = DateTime.now();
    context.push(
      AppRoutes.sectionListing,
      extra: SectionListingRouteArgs(
        title: title,
        source: FilterListing(
          exploreSectionFilter(
            section,
            today: today,
            type: browse.segment.mediaType,
            providerId: browse.service?.id,
            genre: browse.genre,
          ),
          today: today,
        ),
        style: _style,
        listingContext: ListingContext.explore(
          segment: browse.segment,
          genre: browse.genre,
          platform: browse.service,
        ),
      ),
    );
  }

  /// How the grid's posters are dressed — the same as the section's carousel.
  ListingStyle get _style => switch (section) {
    ExploreSection.topToday => ListingStyle.ranked,
    ExploreSection.topRated => ListingStyle.rating,
    ExploreSection.hiddenGems => ListingStyle.detailed,
    ExploreSection.newReleases ||
    ExploreSection.comingSoon => ListingStyle.dated,
    ExploreSection.popular => ListingStyle.plain,
  };
}
