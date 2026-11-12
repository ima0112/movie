import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/domain/repositories/settings_repository.dart';
import '../../../../core/domain/entities/country.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/explore_filter_sheet.dart';
import '../../../../shared/widgets/media_segmented_control.dart';
import '../cubit/explore_cubit.dart';
import '../cubit/explore_state.dart';
import 'explore_search_field.dart';

/// B2's header (no title — the design opens on the search field): the search
/// bar and the segmented control, two public widgets because the recent
/// searches panel is anchored **between** them — it drops from under the
/// search bar and covers the segmented control while the field is focused —
/// so the screen needs to place them apart. Each carries its own
/// narrowly-scoped `BlocSelector` (CLAUDE.md rule 9), the live query for the
/// field and the live segment for the control.
class ExploreSearchBar extends StatelessWidget {
  const ExploreSearchBar({
    super.key,
    required this.searchFocus,
    this.focusToken,
  });

  /// The search field's focus, owned by the screen.
  final FocusNode searchFocus;

  /// A new value focuses the search field (see `ExploreScreen.focusToken`).
  final String? focusToken;

  @override
  Widget build(BuildContext context) {
    // Same page margin as Discover, the field across its full width.
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenMargin,
        AppSpacing.md,
        AppSpacing.screenMargin,
        AppSpacing.md,
      ),
      child: _ExploreSearchBar(focusNode: searchFocus, focusToken: focusToken),
    );
  }
}

class _ExploreSearchBar extends StatelessWidget {
  const _ExploreSearchBar({required this.focusNode, this.focusToken});

  final FocusNode focusNode;
  final String? focusToken;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ExploreCubit, ExploreState, String>(
      selector: (state) => state is ExploreSearching ? state.query : '',
      builder: (context, query) {
        return ExploreSearchField(
          focusNode: focusNode,
          focusToken: focusToken,
          query: query,
          onChanged: (value) =>
              context.read<ExploreCubit>().onQueryChanged(value),
          onClear: () => context.read<ExploreCubit>().clearQuery(),
          onFilterTap: () => _openFilterSheet(context),
        );
      },
    );
  }
}

/// The filter icon → H8, seeded with the current segment's kind; "See N
/// results" there opens the filtered listing (`ExploreCubit.openListing`).
void _openFilterSheet(BuildContext context) {
  final cubit = context.read<ExploreCubit>();
  final title = context.l10n.exploreDefaultResultsTitle;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => ExploreFilterSheet(
      initialFilter: DiscoverFilter(type: cubit.state.segment.mediaType),
      mediaRepository: getIt<MediaRepository>(),
      regionName: countryName(getIt<SettingsRepository>().current.regionCode),
      onApply: (filter) => cubit.openListing(filter: filter, title: title),
    ),
  );
}

/// All | Movies | TV Shows at rest, plus **People** while searching (people
/// are only found by name, so there is nothing to browse for them). Watches
/// only the segment and whether a search is on (CLAUDE.md rule 9).
class ExploreSegmentedControl extends StatelessWidget {
  const ExploreSegmentedControl({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ExploreCubit, ExploreState, (MediaSegment, bool)>(
      selector: (state) => (state.segment, state is ExploreSearching),
      builder: (context, selected) {
        final (segment, searching) = selected;
        return MediaSegmentedControl(
          segments: searching ? MediaSegment.explore : MediaSegment.media,
          segment: segment,
          onSelected: (value) =>
              context.read<ExploreCubit>().selectSegment(value),
        );
      },
    );
  }
}
