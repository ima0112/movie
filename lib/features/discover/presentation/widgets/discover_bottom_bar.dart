import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_tab_bar.dart';
import '../../../../shared/widgets/match_fab.dart';

/// Tab bar + Match FAB. `const`, built once — the same static structure
/// on every one of the four root screens (`docs/SCREENS.md` section B);
/// it doesn't depend on Discover's load state at all (CLAUDE.md rule 9).
class DiscoverBottomBar extends StatelessWidget {
  const DiscoverBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        const AppTabBar(activeTab: AppTab.discover),
        MatchFab(
          // TODO: → B3 (Match hub modal) once it exists.
          onTap: () {},
        ),
      ],
    );
  }
}
