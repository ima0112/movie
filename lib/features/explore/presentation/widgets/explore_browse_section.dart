import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_segment.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/media_carousel.dart';
import '../../../discover/presentation/widgets/discover_content_error.dart';
import '../../../discover/presentation/widgets/discover_section_skeleton.dart';
import '../../domain/explore_section.dart';
import '../cubit/explore_browse_cubit.dart';
import '../cubit/explore_browse_state.dart';
import '../cubit/explore_cubit.dart';

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
/// very filter that produced the carousel), a carousel — numbered for "Top
/// today" — a skeleton while loading, or a retry row on error. A section that
/// loads empty draws nothing. Watches only its own slot of the state
/// (CLAUDE.md rule 9).
class ExploreBrowseSection extends StatelessWidget {
  const ExploreBrowseSection({super.key, required this.section});

  final ExploreSection section;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      ExploreBrowseCubit,
      ExploreBrowseState,
      ExploreSectionState
    >(
      selector: (state) => state.sectionState(section),
      builder: (context, state) {
        final l10n = context.l10n;
        final title = exploreSectionTitle(section, l10n);
        return switch (state) {
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
            actionLabel: l10n.discoverSeeAll,
            onAction: () => _seeAll(context, title),
            child: MediaCarousel.standard(
              items: items,
              showTypeTag:
                  context.read<ExploreBrowseCubit>().state.segment ==
                  MediaSegment.all,
              ranked: section == ExploreSection.topToday,
              onItemTap: (MediaItem item) => context.pushMediaDetail(item.key),
            ),
          ),
        };
      },
    );
  }

  /// C1 with the same filter the section previewed, in the current segment.
  void _seeAll(BuildContext context, String title) {
    final browse = context.read<ExploreBrowseCubit>().state;
    context.read<ExploreCubit>().openListing(
      filter: exploreSectionFilter(
        section,
        today: DateTime.now(),
        type: browse.segment.mediaType,
        providerId: browse.service?.id,
      ),
      title: title,
    );
  }
}
