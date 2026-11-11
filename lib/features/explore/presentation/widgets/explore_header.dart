import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/theme/app_spacing.dart';
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
        );
      },
    );
  }
}

class ExploreSegmentedControl extends StatelessWidget {
  const ExploreSegmentedControl({super.key});

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
