import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../app/router.dart';
import '../../../../l10n/failure_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/state_views.dart';
import '../cubit/explore_cubit.dart';
import '../cubit/explore_state.dart';
import 'explore_browse_body.dart';
import 'explore_search_skeleton.dart';
import 'search_results_list.dart';

/// The one `BlocBuilder` on this screen scoped to "which of B2's three
/// states is current" (CLAUDE.md rule 9) — `ExploreHeader` above it is
/// untouched by this. Renders nothing for `ExploreListing`: that state is
/// a pure "push C1 now" signal `explore_screen.dart`'s own `BlocListener`
/// reacts to, not something this widget draws (see `ExploreState.dart`'s
/// own doc comment on it).
class ExploreContent extends StatelessWidget {
  const ExploreContent({super.key, required this.searchFocus});

  /// The search field's focus (the at-rest body shows recents while focused).
  final FocusNode searchFocus;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreCubit, ExploreState>(
      builder: (context, state) {
        return switch (state) {
          ExploreAtRest() => ExploreBrowseBody(
            state: state,
            searchFocus: searchFocus,
          ),
          ExploreSearchLoading() => const ExploreSearchSkeleton(),
          ExploreSearchLoaded() when state.results.isEmpty => EmptyStateView(
            icon: AppIcons.search,
            title: context.l10n.exploreNoResults,
            body: context.l10n.exploreTryAnotherTitle,
          ),
          ExploreSearchLoaded() => SearchResultsList(
            results: state.results,
            segment: state.segment,
            onMediaTap: (item) => context.pushMediaDetail(item.key),
            onPersonTap: (person) => context.pushPersonDetail(person.id),
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
