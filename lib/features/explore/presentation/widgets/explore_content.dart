import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../app/router.dart';
import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/domain/entities/genre_catalog.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/failure_localization.dart';
import '../../../../l10n/genre_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/state_views.dart';
import '../cubit/explore_cubit.dart';
import '../cubit/explore_state.dart';
import 'explore_search_skeleton.dart';
import 'genre_tile_grid.dart';
import 'recent_searches_chips.dart';
import 'search_results_list.dart';

/// The one `BlocBuilder` on this screen scoped to "which of B2's three
/// states is current" (CLAUDE.md rule 9) — `ExploreHeader` above it is
/// untouched by this. Renders nothing for `ExploreListing`: that state is
/// a pure "push C1 now" signal `explore_screen.dart`'s own `BlocListener`
/// reacts to, not something this widget draws (see `ExploreState.dart`'s
/// own doc comment on it).
class ExploreContent extends StatelessWidget {
  const ExploreContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreCubit, ExploreState>(
      builder: (context, state) {
        return switch (state) {
          ExploreAtRest() => _AtRestContent(state: state),
          ExploreSearchLoading() => const ExploreSearchSkeleton(),
          ExploreSearchLoaded() when state.results.isEmpty => EmptyStateView(
            icon: AppIcons.search,
            title: context.l10n.exploreNoResults,
            body: context.l10n.exploreTryAnotherTitle,
          ),
          ExploreSearchLoaded() => SearchResultsList(
            results: state.results,
            segment: state.segment,
            onTap: (item) => context.pushMediaDetail(item.key),
          ),
          ExploreSearchError(:final reason) => ErrorStateView(
            title: context.l10n.commonCouldntLoad,
            body: reason.localizedMessage(context.l10n),
            onRetry: () =>
                context.read<ExploreCubit>().runRecentSearch(state.query),
          ),
          ExploreListing() => const SizedBox.shrink(),
        };
      },
    );
  }
}

class _AtRestContent extends StatelessWidget {
  const _AtRestContent({required this.state});

  final ExploreAtRest state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExploreCubit>();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        RecentSearchesChips(
          recentSearches: state.recentSearches,
          onTap: cubit.runRecentSearch,
          onLongPress: cubit.removeRecentSearch,
          onClearAll: cubit.clearRecentSearches,
        ),
        if (state.recentSearches.isNotEmpty)
          const SizedBox(height: AppSpacing.xl),
        Text(context.l10n.commonGenres, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.md),
        // GenreCatalog isn't segmented by media type yet (see its own doc
        // comment — the TMDB-id-per-type mapping that would make "genres
        // change with the segment" possible lives only in `data/tmdb/`),
        // so the same list shows under All/Movies/TV Shows for now.
        GenreTileGrid(
          genres: GenreCatalog.all,
          onTap: (genre) => cubit.openListing(
            filter: DiscoverFilter(
              type: state.segment.mediaType,
              withGenres: {genre},
            ),
            title: genre.localizedName(context.l10n),
          ),
        ),
      ],
    );
  }
}
