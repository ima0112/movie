import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/app_tab_bar.dart';
import '../../../../shared/widgets/scroll_edge_fade.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../domain/explore_section.dart';
import '../cubit/explore_browse_cubit.dart';
import '../cubit/explore_browse_state.dart';
import '../cubit/explore_cubit.dart';
import '../cubit/explore_state.dart';
import 'explore_browse_section.dart';
import 'explore_genre_pills.dart';
import 'explore_platform_pills.dart';
import 'recent_searches_chips.dart';

/// B2 at rest (`docs/SCREENS.md` B2): the Genre and Platform pills, then the
/// sections they filter. While the search field is focused and empty
/// *and* there is a history, the recent searches show instead — the pills
/// come back as soon as the field loses focus.
class ExploreBrowseBody extends StatelessWidget {
  const ExploreBrowseBody({
    super.key,
    required this.state,
    required this.searchFocus,
  });

  final ExploreAtRest state;
  final FocusNode searchFocus;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: searchFocus,
      builder: (context, _) {
        if (searchFocus.hasFocus && state.recentSearches.isNotEmpty) {
          return _Recents(state: state);
        }
        return const _Browse();
      },
    );
  }
}

class _Recents extends StatelessWidget {
  const _Recents({required this.state});

  final ExploreAtRest state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExploreCubit>();
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenMargin,
        AppSpacing.lg,
        AppSpacing.screenMargin,
        AppTabBar.scrollInset(context),
      ),
      children: [
        RecentSearchesChips(
          recentSearches: state.recentSearches,
          onTap: cubit.runRecentSearch,
          onLongPress: cubit.removeRecentSearch,
          onClearAll: cubit.clearRecentSearches,
        ),
      ],
    );
  }
}

class _Browse extends StatelessWidget {
  const _Browse();

  static const double _fade = AppSpacing.lg;

  @override
  Widget build(BuildContext context) {
    return ScrollEdgeFade(
      top: _fade,
      child: ListView(
        // As tall as the top fade, so nothing is faded at rest.
        padding: EdgeInsets.only(
          top: _fade,
          bottom: AppTabBar.scrollInset(context),
        ),
        children: [
          const ExploreGenrePills(),
          const ExplorePlatformPills(),
          for (final section in ExploreSection.values)
            ExploreBrowseSection(section: section),
          const _NothingForFilters(),
        ],
      ),
    );
  }
}

/// Shown only when every section has loaded and every one is empty (the genre
/// and platform together leave nothing).
class _NothingForFilters extends StatelessWidget {
  const _NothingForFilters();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ExploreBrowseCubit, ExploreBrowseState, bool>(
      selector: (state) => ExploreSection.values.every((section) {
        final s = state.sectionState(section);
        return s is ExploreSectionLoaded && s.items.isEmpty;
      }),
      builder: (context, allEmpty) {
        if (!allEmpty) return const SizedBox.shrink();
        final l10n = context.l10n;
        return AppSection(
          child: EmptyStateView(
            icon: AppIcons.search,
            title: l10n.exploreBrowseEmptyTitle,
            body: l10n.exploreBrowseEmptyBody,
          ),
        );
      },
    );
  }
}
