import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../shared/widgets/app_tab_bar.dart';
import '../shared/widgets/match_fab.dart';

/// Wraps the four root tabs (in `AppTab.values` order — see `router.dart`'s
/// branches) with the tab bar + Match FAB, per `docs/SCREENS.md` section B.
///
/// Lives at the app level, not inside any one feature's screen: it's
/// chrome shared by all four roots, built once by
/// `StatefulShellRoute.indexedStack` — switching tabs never rebuilds this,
/// and each branch keeps its own `Navigator` (and whatever state/scroll
/// position it holds) alive underneath it (CLAUDE.md rule 9).
class RootShell extends StatelessWidget {
  const RootShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          AppTabBar(
            activeTab: AppTab.values[navigationShell.currentIndex],
            onTabSelected: (tab) =>
                navigationShell.goBranch(AppTab.values.indexOf(tab)),
          ),
          MatchFab(
            // TODO: → B3 (Match hub modal) once it exists.
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
