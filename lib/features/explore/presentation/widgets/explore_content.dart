import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../app/router.dart';
import '../../../../l10n/failure_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_tab_bar.dart';
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
  const ExploreContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreCubit, ExploreState>(
      builder: (context, state) {
        return switch (state) {
          ExploreAtRest() => const ExploreBrowseBody(),
          ExploreSearchLoading() => const ExploreSearchSkeleton(),
          ExploreSearchLoaded() when state.results.isEmpty => _ClearOfTabBar(
            child: EmptyStateView(
              icon: AppIcons.search,
              title: context.l10n.exploreNoResults,
              body: context.l10n.exploreNoResultsBody(state.query),
              ctaLabel: context.l10n.exploreClearSearch,
              onCtaTap: context.read<ExploreCubit>().clearQuery,
            ),
          ),
          ExploreSearchLoaded() => SearchResultsList(
            results: state.results,
            segment: state.segment,
            onMediaTap: (item) => context.pushMediaDetail(item.key),
            onPersonTap: (person) => context.pushPersonDetail(person.id),
          ),
          ExploreSearchError(:final reason) => _ClearOfTabBar(
            child: ErrorStateView(
              title: context.l10n.commonCouldntLoad,
              body: reason.localizedMessage(context.l10n),
              onRetry: () =>
                  context.read<ExploreCubit>().runRecentSearch(state.query),
            ),
          ),
          ExploreListing() => const SizedBox.shrink(),
        };
      },
    );
  }
}

/// Centers a state view in the room the floating tab bar leaves free, not in
/// the whole body (which runs under the bar).
class _ClearOfTabBar extends StatelessWidget {
  const _ClearOfTabBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTabBar.scrollInset(context)),
      child: child,
    );
  }
}
