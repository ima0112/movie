import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/theme/app_spacing.dart';
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
  const ExploreHeader({super.key, required this.searchFocus, this.focusToken});

  /// The search field's focus, owned by the screen.
  final FocusNode searchFocus;

  /// A new value focuses the search field (see `ExploreScreen.focusToken`).
  final String? focusToken;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Same page margin as Discover, the field across its full width.
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenMargin,
            AppSpacing.md,
            AppSpacing.screenMargin,
            AppSpacing.md,
          ),
          child: _ExploreSearchBar(
            focusNode: searchFocus,
            focusToken: focusToken,
          ),
        ),
        const _ExploreSegmentedControl(),
      ],
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
        );
      },
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
          segment: segment,
          onSelected: (value) =>
              context.read<ExploreCubit>().selectSegment(value),
        );
      },
    );
  }
}
