import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../app/router.dart';
import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/scroll_edge_fade.dart';
import '../../../../shared/widgets/state_views.dart';
import '../cubit/filtered_list_cubit.dart';
import '../cubit/filtered_list_state.dart';
import 'filtered_list_chips_row.dart';
import 'filtered_list_grid.dart';
import 'filtered_list_grid_skeleton.dart';

/// C1's body: the active-filter chips (always there while something is set,
/// also on the empty and error states, so a filter can be dropped right there)
/// and under them the state — `docs/SCREENS.md` C1: "grid skeleton, empty...,
/// error, offline." (Offline isn't modeled: no connectivity detection exists
/// anywhere in the app yet.)
///
/// The state switch only subscribes to *which* [FilteredListState] subtype is
/// current (CLAUDE.md rule 9) — `loadMore()` never changes that, so revealing
/// another page never rebuilds it; each child carries its own narrower
/// selector for the slice it needs.
class FilteredListContent extends StatelessWidget {
  const FilteredListContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _ChipsRow(),
        Expanded(child: _States()),
      ],
    );
  }
}

class _States extends StatelessWidget {
  const _States();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<FilteredListCubit, FilteredListState, Type>(
      selector: (state) => state.runtimeType,
      builder: (context, _) {
        final cubit = context.read<FilteredListCubit>();
        final state = cubit.state;
        return switch (state) {
          FilteredListInitial() ||
          FilteredListLoading() => const FilteredListGridSkeleton(),
          FilteredListError(:final reason) => FailureStateView(
            reason: reason,
            onRetry: cubit.retry,
          ),
          FilteredListLoaded() when state.allItems.isEmpty => EmptyStateView(
            icon: AppIcons.search,
            title: context.l10n.filteredListEmptyTitle,
            body: context.l10n.filteredListEmptyBody,
            ctaLabel: state.filter.activeFilterCount == 0
                ? null
                : context.l10n.filteredListClearFilters,
            // Back to every title of the segment, most popular first.
            onCtaTap: () =>
                cubit.updateFilter(DiscoverFilter(type: state.filter.type)),
          ),
          // Posters scrolling up under the header dissolve, as on Home.
          FilteredListLoaded() => const ScrollEdgeFade(
            top: AppSpacing.lg,
            child: _Grid(),
          ),
        };
      },
    );
  }
}

class _ChipsRow extends StatelessWidget {
  const _ChipsRow();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      FilteredListCubit,
      FilteredListState,
      (DiscoverFilter, Map<int, String>)
    >(
      selector: (state) => (state.filter, state.providerNames),
      builder: (context, data) => FilteredListChipsRow(
        filter: data.$1,
        providerNames: data.$2,
        onFilterChanged: context.read<FilteredListCubit>().updateFilter,
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      FilteredListCubit,
      FilteredListState,
      FilteredListLoaded?
    >(
      selector: (state) => state is FilteredListLoaded ? state : null,
      builder: (context, state) {
        if (state == null) return const SizedBox.shrink();
        return FilteredListGrid(
          items: state.visibleItems,
          hasMore: state.hasMore,
          // With a platform picked every title is on it: a logo says nothing.
          showPlatform: state.filter.withWatchProviders.isEmpty,
          onLoadMore: () => context.read<FilteredListCubit>().loadMore(),
          onTap: (item) => context.pushMediaDetail(item.key),
        );
      },
    );
  }
}
