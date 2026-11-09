import 'package:flutter/widgets.dart';

import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/library_tab_localization.dart';
import '../../../../shared/widgets/state_views.dart';

/// B4's empty state: no entries at all for a tab (`docs/SCREENS.md` B4:
/// "empty with sleeping Pako..., per-tab headline..., a line mentioning
/// what does exist in other tabs, 'Explore' CTA").
///
/// [otherTabsNote] is the "line mentioning what does exist in other
/// tabs" — its exact wording isn't given verbatim in SCREENS.md (unlike
/// the per-tab headlines below), and depends on live counts for every
/// tab, which this widget doesn't have; the screen that already
/// subscribes to all three tabs' counts (see `MyListSegmentedTabs`)
/// composes it.
class MyListEmptyState extends StatelessWidget {
  const MyListEmptyState({
    super.key,
    required this.tab,
    required this.otherTabsNote,
    this.onExploreTap,
  });

  final LibraryTab tab;
  final String otherTabsNote;
  final VoidCallback? onExploreTap;

  @override
  Widget build(BuildContext context) {
    return EmptyStateView(
      icon: switch (tab) {
        LibraryTab.favorites => AppIcons.favorite,
        LibraryTab.watchLater => AppIcons.watchLater,
        LibraryTab.watched => AppIcons.watched,
      },
      title: tab.localizedEmptyHeadline(context.l10n),
      body: otherTabsNote,
      ctaLabel: context.l10n.navTabExplore,
      onCtaTap: onExploreTap,
    );
  }
}

/// B4's filtered-empty state: entries exist for the tab, but the active
/// H9 filter hides all of them (`docs/SCREENS.md` B4: "If a filter is
/// what's emptying the list: 'No TV shows here' + 'See all'").
///
/// [title] is caller-supplied (e.g. "No TV shows here") since the exact
/// wording depends on which filter dimension is currently active —
/// SCREENS.md gives one example, not a template for every combination.
class MyListFilteredEmptyState extends StatelessWidget {
  const MyListFilteredEmptyState({
    super.key,
    required this.title,
    this.onSeeAllTap,
  });

  final String title;
  final VoidCallback? onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    return EmptyStateView(
      icon: AppIcons.filter,
      title: title,
      body: context.l10n.filteredListEmptyBody,
      ctaLabel: context.l10n.discoverSeeAll,
      onCtaTap: onSeeAllTap,
    );
  }
}
