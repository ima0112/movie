import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/domain/entities/media_type.dart';
import '../features/discover/presentation/screens/discover_screen.dart';
import '../features/movie_detail/presentation/screens/movie_detail_screen.dart';
import '../features/my_list/presentation/screens/my_list_screen.dart';
import '../features/you/presentation/screens/you_screen.dart';
import 'root_shell.dart';

/// Route paths, kept next to the routes that define them so features
/// don't hardcode a path's shape themselves — see `discover_hero.dart` /
/// `discover_section_carousel.dart` for the call sites.
class AppRoutes {
  const AppRoutes._();

  static String movieDetail(int id) => '/movie/$id';

  /// C1 (Filtered listing), not built yet — see `movie_detail_header.dart`
  /// / `movie_detail_title_block.dart`'s genre taps.
  static String genreListing(String genreId, MediaType type) =>
      '/genre/$genreId?type=${type.name}';
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
            GoRoute(
              path: '/',
              builder: (context, state) => const DiscoverScreen(),
            ),
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
              builder: (context, state) => const MyListScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/you',
              builder: (context, state) => const YouScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/movie/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return MovieDetailScreen(movieId: id);
      },
    ),
    GoRoute(
      path: '/genre/:genreId',
      parentNavigatorKey: _rootNavigatorKey,
      // TODO: → C1 (Filtered listing) once it's built — this placeholder
      // only proves navigation + the genre/type round-trip from D1's
      // tappable genres (`movie_detail_title_block.dart`).
      builder: (context, state) {
        final genreId = state.pathParameters['genreId']!;
        final type = state.uri.queryParameters['type'] ?? MediaType.movie.name;
        return _GenreListingPlaceholderScreen(genreId: genreId, type: type);
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

/// Stand-in for C1 (Filtered listing). A real pushed screen (like D1
/// itself), so it needs its own `Scaffold` + back button — see
/// `docs/SCREENS.md` ("every pushed screen has a back button... and
/// hides the bottom bar"): it's on the root navigator, outside
/// [RootShell] entirely.
class _GenreListingPlaceholderScreen extends StatelessWidget {
  const _GenreListingPlaceholderScreen({
    required this.genreId,
    required this.type,
  });

  final String genreId;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: Center(child: Text('Genre: $genreId ($type)')),
    );
  }
}
