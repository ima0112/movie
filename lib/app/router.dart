import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/domain/entities/discover_filter.dart';
import '../core/domain/entities/media_type.dart';
import '../core/domain/repositories/media_repository.dart';
import '../features/discover/presentation/screens/discover_screen.dart';
import '../features/explore/presentation/screens/explore_screen.dart';
import '../features/filtered_list/presentation/screens/filtered_list_screen.dart';
import '../features/movie_detail/presentation/screens/movie_detail_screen.dart';
import '../features/my_list/presentation/screens/my_list_screen.dart';
import '../features/my_tastes/presentation/screens/my_tastes_screen.dart';
import '../features/stats/presentation/screens/stats_screen.dart';
import '../features/you/presentation/screens/you_screen.dart';
import 'root_shell.dart';

/// Route paths, kept next to the routes that define them so features
/// don't hardcode a path's shape themselves — see `discover_hero.dart` /
/// `discover_section_carousel.dart` for the call sites.
class AppRoutes {
  const AppRoutes._();

  static String movieDetail(int id) => '/movie/$id';

  /// C4 (Stats), pushed from B5's "See stats" link
  /// (`you_screen.dart`'s `onSeeStats`).
  static const String stats = '/stats';

  /// C5 (My Tastes), pushed from B5's My Tastes card
  /// (`you_screen.dart`'s `MyTastesCard.onTap`).
  static const String myTastes = '/my-tastes';

  /// C1 (Filtered listing), not built yet — see `movie_detail_header.dart`
  /// / `movie_detail_title_block.dart`'s genre taps. Left as its own
  /// placeholder route deliberately: migrating D1/D2's genre taps onto
  /// [filteredList] below is out of scope for the branch that added that
  /// route — a separate, later change.
  static String genreListing(String genreId, MediaType type) =>
      '/genre/$genreId?type=${type.name}';

  /// C1 (Filtered listing) proper — reached from B1's "See all"
  /// (`discover_section_carousel.dart`), a B2 genre tile, or H8's "See N
  /// results" (all three go through here, carrying a [FilteredListArgs]
  /// via `extra` since a [DiscoverFilter] doesn't have — and isn't meant
  /// to have, see its own doc comment — a lossless URL-string encoding).
  static const String filteredList = '/list';

  /// E1 (Choose type), not built yet — see `match_hub_sheet.dart`'s own
  /// "Surprise me" card. Left as its own placeholder route deliberately,
  /// the same "destination not built yet" shape [genreListing] already
  /// uses: building E1 itself is out of scope for the branch that only
  /// needs to prove B3's card actually navigates somewhere.
  static const String surprise = '/surprise';
}

/// [FilteredListRouteArgs.title] is C1's own top-bar title (e.g. "In
/// theaters", a genre's name, or "Results" for H8's "See N results").
///
/// [FilteredListRouteArgs.collectionSection] is set only for a B1 "See
/// all" tap: `docs/SCREENS.md` C1's own "Source" line ("'See all'
/// collections use their own endpoint until a filter is touched") —
/// see `FilteredListCubit`'s own doc comment on the field it feeds.
/// `null` for every other origin (a genre tile, H8), which already
/// arrive with a real [DiscoverFilter].
class FilteredListRouteArgs {
  const FilteredListRouteArgs({
    required this.filter,
    required this.title,
    this.collectionSection,
  });

  final DiscoverFilter filter;
  final String title;
  final CarouselSection? collectionSection;
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
              builder: (context, state) => const ExploreScreen(),
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
      path: AppRoutes.stats,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const StatsScreen(),
    ),
    GoRoute(
      path: AppRoutes.myTastes,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const MyTastesScreen(),
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
    GoRoute(
      path: AppRoutes.filteredList,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final args = state.extra! as FilteredListRouteArgs;
        return FilteredListScreen(
          filter: args.filter,
          title: args.title,
          collectionSection: args.collectionSection,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.surprise,
      parentNavigatorKey: _rootNavigatorKey,
      // TODO: → E1 (Choose type) once it's built — this placeholder only
      // proves the Match hub's "Surprise me" card actually navigates.
      builder: (context, state) => const _SurprisePlaceholderScreen(),
    ),
  ],
);

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

/// Stand-in for E1 (Choose type) — same reasoning as
/// [_GenreListingPlaceholderScreen]: a real pushed screen, own back
/// button, just no real destination behind it yet.
class _SurprisePlaceholderScreen extends StatelessWidget {
  const _SurprisePlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: const Center(child: Text('Surprise me')),
    );
  }
}
