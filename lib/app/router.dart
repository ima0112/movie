import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/domain/entities/discover_filter.dart';
import '../core/domain/entities/media_key.dart';
import '../core/domain/entities/media_type.dart';
import '../core/domain/repositories/media_repository.dart';
import '../features/discover/presentation/screens/discover_screen.dart';
import '../features/explore/presentation/screens/explore_screen.dart';
import '../features/filtered_list/presentation/screens/filtered_list_screen.dart';
import '../features/movie_detail/presentation/screens/movie_detail_screen.dart';
import '../features/person_detail/presentation/screens/person_detail_screen.dart';
import '../features/tv_detail/presentation/screens/tv_detail_screen.dart';
import '../features/my_list/presentation/screens/my_list_screen.dart';
import '../features/my_tastes/presentation/screens/my_tastes_screen.dart';
import '../features/stats/presentation/screens/stats_screen.dart';
import '../features/suggestion/presentation/cubit/surprise_cubit.dart';
import '../features/suggestion/presentation/screens/choose_type_screen.dart';
import '../features/suggestion/presentation/screens/surprise_quiz_screen.dart';
import '../features/suggestion/presentation/screens/surprise_result_screen.dart';
import '../features/you/presentation/screens/you_screen.dart';
import 'root_shell.dart';

/// Route paths, kept next to the routes that define them so features
/// don't hardcode a path's shape themselves — see `discover_hero.dart` /
/// `discover_section_carousel.dart` for the call sites.
class AppRoutes {
  const AppRoutes._();

  static String movieDetail(int id) => '/movie/$id';

  static String tvDetail(int id) => '/tv/$id';

  static String personDetail(int id) => '/person/$id';

  /// C4 (Stats), pushed from B5's "See stats" link
  /// (`you_screen.dart`'s `onSeeStats`).
  static const String stats = '/stats';

  /// C5 (My Tastes), pushed from B5's My Tastes card
  /// (`you_screen.dart`'s `MyTastesCard.onTap`).
  static const String myTastes = '/my-tastes';

  /// C1 (Filtered listing) — reached from B1's "See all"
  /// (`discover_section_carousel.dart`), a B2 genre tile, D1/D2's own
  /// genre chips, or H8's "See N results" (all go through here,
  /// carrying a [FilteredListArgs] via `extra` since a [DiscoverFilter]
  /// doesn't have — and isn't meant to have, see its own doc comment —
  /// a lossless URL-string encoding).
  static const String filteredList = '/list';

  /// E1 (Choose type) — `match_hub_sheet.dart`'s own "Surprise me" card.
  static const String surprise = '/surprise';

  /// E2 (the shared quiz), reached only from [ChooseTypeScreen]'s own
  /// `BlocListener` once its `SurpriseCubit` emits `NeedsQuiz` — always
  /// carries that same `SurpriseCubit` instance via `extra` (see
  /// `ChooseTypeScreen`'s own doc comment for why a route-level hand-off
  /// is needed instead of a nested `BlocProvider`).
  static const String surpriseQuiz = '/surprise/quiz';

  /// E3 (Surprise me result) — reached from [ChooseTypeScreen] directly
  /// (an explicit profile/inferred list) or from [surpriseQuiz] once the
  /// quiz completes. Same `extra`-carried `SurpriseCubit` hand-off.
  static const String surpriseResult = '/surprise/result';
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

/// The one place any card/row navigates to D1/D2/D3 — no widget builds
/// `/movie/:id`, `/tv/:id`, or `/person/:id` by hand (CLAUDE.md rule 2's
/// "no widget or repository builds a TMDB URL by hand," applied here to
/// this app's own in-app routes instead).
extension MediaDetailNavigation on BuildContext {
  /// Movie or TV show, picked from [key]'s own [MediaKey.type] — the
  /// same `MediaKey` every repository call and `UserLibraryRepository`
  /// entry already uses, so a caller never has to re-derive which route
  /// shape a given id needs.
  Future<T?> pushMediaDetail<T>(MediaKey key) {
    final path = switch (key.type) {
      MediaType.movie => AppRoutes.movieDetail(key.tmdbId),
      MediaType.tvShow => AppRoutes.tvDetail(key.tmdbId),
    };
    return push<T>(path);
  }

  /// D3 (Person detail) — cast/crew rows and search results that are
  /// people push here.
  Future<T?> pushPersonDetail<T>(int personId) =>
      push<T>(AppRoutes.personDetail(personId));
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
      path: '/tv/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return TvDetailScreen(tvId: id);
      },
    ),
    GoRoute(
      path: '/person/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return PersonDetailScreen(personId: id);
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
      builder: (context, state) => const ChooseTypeScreen(),
    ),
    GoRoute(
      path: AppRoutes.surpriseQuiz,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final cubit = state.extra! as SurpriseCubit;
        return SurpriseQuizScreen(cubit: cubit);
      },
    ),
    GoRoute(
      path: AppRoutes.surpriseResult,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final cubit = state.extra! as SurpriseCubit;
        return SurpriseResultScreen(cubit: cubit);
      },
    ),
  ],
);
