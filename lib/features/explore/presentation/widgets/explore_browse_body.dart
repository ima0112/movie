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
import 'explore_browse_section.dart';
import 'explore_genre_pills.dart';
import 'explore_platform_pills.dart';

/// B2 at rest (`docs/SCREENS.md` B2): the Genre and Platform pills, then the
/// sections they filter. (The recent searches are a panel over this, drawn by
/// the screen — see `ExploreRecentsPanel`.)
class ExploreBrowseBody extends StatelessWidget {
  const ExploreBrowseBody({super.key});

  @override
  Widget build(BuildContext context) => const _Browse();
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
