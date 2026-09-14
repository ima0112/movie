import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/discover/presentation/screens/discover_screen.dart';
import 'root_shell.dart';

/// Route paths, kept next to the routes that define them so features
/// don't hardcode a path's shape themselves — see `discover_hero.dart` /
/// `discover_section_carousel.dart` for the call sites.
class AppRoutes {
  const AppRoutes._();

  static String movieDetail(int id) => '/movie/$id';
}

/// The app's single `GoRouter`. Source of truth: `docs/STRUCTURE.md`
/// ("Navigation | go_router").
///
/// The four roots (Discover, Explore, My List, You) are one
/// `StatefulShellRoute.indexedStack` branch each, so switching tabs never
/// rebuilds a tab from scratch — every branch keeps its own `Navigator`
/// (and whatever scroll position/state it holds) alive in an
/// `IndexedStack` underneath [RootShell].
///
/// `/movie/:id` is a *sibling* of the shell route, pushed onto the root
/// navigator via [_rootNavigatorKey] rather than a branch's own — that's
/// what makes it cover the whole screen and hide the tab bar, per
/// `docs/SCREENS.md` ("Every pushed screen... hides the bottom bar").
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return RootShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/', builder: (context, state) => const DiscoverScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/explore',
              // TODO: → B2 (Explore) once it's built.
              builder: (context, state) =>
                  const _RootPlaceholder(title: 'Explore'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/my-list',
              // TODO: → B4 (My List) once it's built.
              builder: (context, state) =>
                  const _RootPlaceholder(title: 'My List'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/you',
              // TODO: → B5 (You) once it's built.
              builder: (context, state) => const _RootPlaceholder(title: 'You'),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/movie/:id',
      parentNavigatorKey: _rootNavigatorKey,
      // TODO: → D1 (Movie detail) once it's built — this placeholder only
      // proves navigation + the id round-trip.
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return _MoviePlaceholderScreen(id: id);
      },
    ),
  ],
);

/// Stand-in for a root tab that isn't built yet. Rendered inside
/// [RootShell]'s own `Scaffold`, so it's just content — no `Scaffold` of
/// its own.
class _RootPlaceholder extends StatelessWidget {
  const _RootPlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title));
  }
}

/// Stand-in for D1 (Movie detail). A real pushed screen (unlike the root
/// placeholders above), so it needs its own `Scaffold` + back button —
/// this is what `docs/SCREENS.md` means by "every pushed screen has a
/// back button... and hides the bottom bar": it's on the root navigator,
/// outside `RootShell` entirely.
class _MoviePlaceholderScreen extends StatelessWidget {
  const _MoviePlaceholderScreen({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: Center(child: Text('Movie $id')),
    );
  }
}
