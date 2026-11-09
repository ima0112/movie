import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../app/router.dart';
import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/failure_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/state_views.dart';
import '../cubit/filtered_list_cubit.dart';
import '../cubit/filtered_list_state.dart';
import 'filtered_list_chips_row.dart';
import 'filtered_list_count_line.dart';
import 'filtered_list_grid.dart';
import 'filtered_list_grid_skeleton.dart';

/// C1's states — `docs/SCREENS.md` C1: "grid skeleton, empty..., error,
/// offline." (Offline isn't modeled: no connectivity detection exists
/// anywhere in the app yet, not something specific to this screen.)
///
/// Only subscribes to *which* [FilteredListState] subtype is current
/// (CLAUDE.md rule 9) — `loadMore()` never changes that (it re-emits
/// another [FilteredListLoaded]), so revealing another page never
/// rebuilds this switch; [_LoadedContent]'s own children each carry
/// their own narrower selector for the slice they actually need.
class FilteredListContent extends StatelessWidget {
  const FilteredListContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<FilteredListCubit, FilteredListState, Type>(
      selector: (state) => state.runtimeType,
      builder: (context, _) {
        final state = context.read<FilteredListCubit>().state;
        return switch (state) {
          FilteredListInitial() ||
          FilteredListLoading() => const FilteredListGridSkeleton(),
          FilteredListError(:final reason) => ErrorStateView(
            title: context.l10n.commonCouldntLoad,
            body: reason.localizedMessage(context.l10n),
            onRetry: () => context.read<FilteredListCubit>().retry(),
          ),
          FilteredListLoaded() when state.allItems.isEmpty => EmptyStateView(
            icon: AppIcons.filter,
            title: context.l10n.filteredListEmptyTitle,
            body: context.l10n.filteredListEmptyBody,
            ctaLabel: state.filter.isDefault ? null : context.l10n.commonReset,
            onCtaTap: () => context.read<FilteredListCubit>().updateFilter(
              const DiscoverFilter(),
            ),
          ),
          FilteredListLoaded() => const _LoadedContent(),
        };
      },
    );
  }
}

/// Built once per Loading→Loaded transition — never subscribes to
/// [FilteredListCubit] itself, so it never rebuilds on its own; each
/// child below manages its own narrow subscription instead.
class _LoadedContent extends StatelessWidget {
  const _LoadedContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ChipsRow(),
              const SizedBox(height: AppSpacing.sm),
              const _CountLine(),
            ],
          ),
        ),
        const Expanded(child: _Grid()),
      ],
    );
  }
}

class _ChipsRow extends StatelessWidget {
  const _ChipsRow();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<FilteredListCubit, FilteredListState, DiscoverFilter>(
      selector: (state) => state.filter,
      builder: (context, filter) => FilteredListChipsRow(
        filter: filter,
        onFilterChanged: context.read<FilteredListCubit>().updateFilter,
      ),
    );
  }
}

class _CountLine extends StatelessWidget {
  const _CountLine();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      FilteredListCubit,
      FilteredListState,
      (int, DiscoverSortBy)
    >(
      selector: (state) => switch (state) {
        FilteredListLoaded(:final totalCount) => (
          totalCount,
          state.filter.sortBy,
        ),
        _ => (0, state.filter.sortBy),
      },
      builder: (context, data) =>
          FilteredListCountLine(count: data.$1, sortBy: data.$2),
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
          onLoadMore: () => context.read<FilteredListCubit>().loadMore(),
          onTap: (item) => context.pushMediaDetail(item.key),
        );
      },
    );
  }
}
