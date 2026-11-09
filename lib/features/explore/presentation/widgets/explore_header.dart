import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/explore_filter_sheet.dart';
import '../../../../shared/widgets/media_segmented_control.dart';
import '../cubit/explore_cubit.dart';
import '../cubit/explore_state.dart';
import 'explore_search_field.dart';

/// B2's header (no title — the design opens on the search field): its two Bloc-subscribed controls —
/// the search field's live query and the segmented control's live
/// segment. Grouped in one file since each is only a handful of lines,
/// the same "not substantial enough on its own" call
/// `discover_range_filters.dart` already makes for its own three small
/// widgets; each still carries its own narrowly-scoped `BlocSelector`
/// (CLAUDE.md rule 9) rather than sharing one `BlocBuilder`.
class ExploreHeader extends StatelessWidget {
  const ExploreHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [const _ExploreSearchBar()],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const _ExploreSegmentedControl(),
      ],
    );
  }
}

class _ExploreSearchBar extends StatelessWidget {
  const _ExploreSearchBar();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ExploreCubit, ExploreState, String>(
      selector: (state) => state is ExploreSearching ? state.query : '',
      builder: (context, query) {
        return ExploreSearchField(
          query: query,
          onChanged: (value) =>
              context.read<ExploreCubit>().onQueryChanged(value),
          onClear: () => context.read<ExploreCubit>().clearQuery(),
          // B2 never lingers in a "back on B2 with a filter still on"
          // state today — applying one in H8 always fires straight into
          // `ExploreCubit.openListing`/C1, so there's nothing here yet
          // for this to reflect.
          hasActiveFilters: false,
          onFilterTap: () => _openFilterSheet(context),
        );
      },
    );
  }

  void _openFilterSheet(BuildContext context) {
    final cubit = context.read<ExploreCubit>();
    final segment = cubit.state.segment;
    final title = context.l10n.exploreDefaultResultsTitle;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ExploreFilterSheet(
        initialFilter: DiscoverFilter(type: segment.mediaType),
        mediaRepository: getIt<MediaRepository>(),
        onApply: (filter) => cubit.openListing(filter: filter, title: title),
      ),
    );
  }
}

class _ExploreSegmentedControl extends StatelessWidget {
  const _ExploreSegmentedControl();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ExploreCubit, ExploreState, MediaSegment>(
      selector: (state) => state.segment,
      builder: (context, segment) {
        return MediaSegmentedControl(
          style: MediaSegmentedStyle.pill,
          segment: segment,
          onSelected: (value) =>
              context.read<ExploreCubit>().selectSegment(value),
        );
      },
    );
  }
}
