import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../features/match_hub/presentation/widgets/match_hub_sheet.dart';
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

  /// How far above the bar the fade starts.
  static const double _fadeReach = 72;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The bar floats over the content (glass blur), not beside it.
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // Behind the bar: the page fades into the background as it passes
          // under the glass pill, instead of showing through hard-edged.
          const Positioned(
            left: 0,
            right: 0,
            top: -_fadeReach,
            bottom: 0,
            child: IgnorePointer(child: _BarFade()),
          ),
          AppTabBar(
            activeTab: AppTab.values[navigationShell.currentIndex],
            onTabSelected: (tab) =>
                navigationShell.goBranch(AppTab.values.indexOf(tab)),
          ),
          MatchFab(onTap: () => _openMatchHub(context)),
        ],
      ),
    );
  }

  void _openMatchHub(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const MatchHubSheet(),
    );
  }
}

/// Transparent at the top to the page color at the bottom, on an eased
/// curve: it darkens slowly at first and most of the way down, so content
/// disappears gradually behind the glass pill rather than at one line.
class _BarFade extends StatelessWidget {
  const _BarFade();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.3, 0.55, 0.8, 1],
          colors: [
            AppColors.surface.withValues(alpha: 0),
            AppColors.surface.withValues(alpha: 0.35),
            AppColors.surface.withValues(alpha: 0.7),
            AppColors.surface.withValues(alpha: 0.94),
            AppColors.surface,
          ],
        ),
      ),
    );
  }
}
