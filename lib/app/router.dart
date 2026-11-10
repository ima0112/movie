import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/domain/entities/discover_filter.dart';
import '../core/domain/entities/media_detail.dart';
import '../core/domain/entities/media_key.dart';
import '../core/domain/entities/media_type.dart';
import '../core/domain/entities/person.dart';
import '../core/domain/entities/season_summary.dart';
import '../core/domain/repositories/media_repository.dart';
import '../core/domain/repositories/onboarding_repository.dart';
import '../features/discover/presentation/screens/discover_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import 'di.dart';
import '../features/explore/presentation/screens/explore_screen.dart';
import '../features/filtered_list/presentation/screens/filtered_list_screen.dart';
import '../features/section_listing/domain/listing_source.dart';
import '../features/section_listing/domain/listing_style.dart';
import '../features/section_listing/presentation/screens/section_listing_screen.dart';
import '../features/movie_detail/presentation/screens/movie_detail_screen.dart';
import '../features/person_detail/presentation/screens/person_detail_screen.dart';
import '../features/tv_detail/presentation/screens/tv_detail_screen.dart';
import '../features/my_list/presentation/screens/my_list_screen.dart';
import '../features/my_tastes/presentation/screens/my_tastes_screen.dart';
import '../features/settings/presentation/screens/attribution_screen.dart';
import '../features/person_detail/presentation/screens/person_filmography_screen.dart';
import '../shared/widgets/media_detail/full_cast_screen.dart';
import '../features/tv_detail/presentation/screens/season_screen.dart';
import '../features/tv_detail/presentation/screens/tv_seasons_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
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

  /// B2 (Explore), a root tab.
  static const String explore = '/explore';

  /// B2 with its search field focused and the keyboard up — B1's search bar is
  /// a shortcut to it. The `focus` value is a fresh token on every call: the
  /// Explore tab stays alive in the shell, so a repeated shortcut has to read
  /// as a *new* request (the field only reacts when the token changes).
  static String exploreSearch() =>
      '$explore?$exploreFocusParam=${DateTime.now().microsecondsSinceEpoch}';

  /// The query parameter [exploreSearch] sets.
  static const String exploreFocusParam = 'focus';

  /// A2 (Onboarding) — the app's own top-level `redirect` sends every
  /// route here until `OnboardingRepository.isCompleted()` is `true`,
  /// and sends this one route to [DiscoverScreen] once it is.
  static const String welcome = '/welcome';

  /// C4 (Stats), pushed from B5's "See stats" link
  /// (`you_screen.dart`'s `onSeeStats`).
  static const String stats = '/stats';

  /// C5 (My Tastes), pushed from B5's My Tastes card
  /// (`you_screen.dart`'s `MyTastesCard.onTap`).
  static const String myTastes = '/my-tastes';

  /// C6 (Settings), pushed from B5's gear icon
  /// (`you_screen.dart`'s `YouHeader.onOpenSettings`).
  static const String settings = '/settings';

  /// C7 (Attribution and credits), pushed from C6's About group.
  static const String attribution = '/attribution';

  /// D3b (Filmography), pushed from D3's "View full filmography" card —
  /// carries the loaded person via `extra` ([PersonFilmographyRouteArgs]).
  static const String personFilmography = '/person-filmography';

  /// D1b (Full cast & crew), pushed from D1/D2's Cast "See all" — carries
  /// the title and the loaded cast/crew via `extra` ([FullCastRouteArgs]).
  static const String fullCast = '/full-cast';

  /// D2b (Seasons), pushed from D2's Seasons card — carries the loaded show
  /// via `extra` ([TvSeasonsRouteArgs]).
  static const String tvSeasons = '/tv-seasons';

  /// D2c (Season), pushed from a season card on D2b — carries the show's id
  /// and name plus the season summary via `extra` ([SeasonRouteArgs]).
  static const String tvSeason = '/tv-season';

  /// C1 (Filtered listing) — reached from B1's "See all"
  /// (`discover_section_carousel.dart`), a B2 genre tile, D1/D2's own
  /// genre chips, or H8's "See N results" (all go through here,
  /// carrying a [FilteredListArgs] via `extra` since a [DiscoverFilter]
  /// doesn't have — and isn't meant to have, see its own doc comment —
  /// a lossless URL-string encoding).
  static const String filteredList = '/list';
  static const String sectionListing = '/section-listing';

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
/// What D3b needs: the person D3 already loaded, so the screen makes no
/// network call of its own.
class PersonFilmographyRouteArgs {
  const PersonFilmographyRouteArgs({required this.detail});

  final PersonDetail detail;
}

/// What D1b needs: the cast and crew D1/D2 already loaded, so the screen makes
/// no network call of its own.
class FullCastRouteArgs {
  const FullCastRouteArgs({
    required this.title,
    required this.cast,
    required this.crew,
  });

  final String title;
  final List<CastMember> cast;
  final List<CrewMember> crew;
}

/// What D2b needs: the show D2 already loaded, so the screen makes no
/// network call of its own.
/// What D2c needs: the show's id (to fetch the season) and what D2b already
/// knows about the season, so the header shows at once.
class SeasonRouteArgs {
  const SeasonRouteArgs({
    required this.tvId,
    required this.seasonSummary,
    this.showTitle,
  });

  final int tvId;
  final SeasonSummary seasonSummary;
  final String? showTitle;
}

class TvSeasonsRouteArgs {
  const TvSeasonsRouteArgs({required this.detail});

  final TvShowDetail detail;
}

/// What C1b ("See all" of a section) needs: its title, where its titles come
/// from, how its posters are dressed, and what the previous screen had set.
class SectionListingRouteArgs {
  const SectionListingRouteArgs({
    required this.title,
    required this.source,
    required this.style,
    required this.listingContext,
  });

  final String title;
  final ListingSource source;
  final ListingStyle style;
  final ListingContext listingContext;
}

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

/// Lets `DiscoverScreen` know when it's been returned to from a pushed
/// detail screen (`RouteAware.didPopNext`) — `RecommendationsCubit`'s
/// own "refresh on returning to Discover" trigger
/// (`docs/SCREENS.md` B1). Switching *bottom tabs* away and back
/// doesn't fire this (`StatefulShellRoute.indexedStack` never pushes/
/// pops for that); only a real `Navigator.push`/`pop` within Discover's
/// own branch does, which is exactly what tapping a recommended title
/// then pressing back is.
final RouteObserver<PageRoute<void>> discoverRouteObserver =
    RouteObserver<PageRoute<void>>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  redirect: _onboardingRedirect,
  observers: [discoverRouteObserver],
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
              path: AppRoutes.explore,
              builder: (context, state) => ExploreScreen(
                focusToken:
                    state.uri.queryParameters[AppRoutes.exploreFocusParam],
              ),
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
      path: AppRoutes.settings,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.attribution,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AttributionScreen(),
    ),
    GoRoute(
      path: AppRoutes.personFilmography,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final args = state.extra! as PersonFilmographyRouteArgs;
        return PersonFilmographyScreen(detail: args.detail);
      },
    ),
    GoRoute(
      path: AppRoutes.fullCast,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final args = state.extra! as FullCastRouteArgs;
        return FullCastScreen(
          title: args.title,
          cast: args.cast,
          crew: args.crew,
          onPersonTap: (person) => context.pushPersonDetail(person.id),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.tvSeason,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final args = state.extra! as SeasonRouteArgs;
        return SeasonScreen(
          tvId: args.tvId,
          seasonSummary: args.seasonSummary,
          showTitle: args.showTitle,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.tvSeasons,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final args = state.extra! as TvSeasonsRouteArgs;
        return TvSeasonsScreen(detail: args.detail);
      },
    ),
    GoRoute(
      path: AppRoutes.sectionListing,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final args = state.extra! as SectionListingRouteArgs;
        return SectionListingScreen(
          title: args.title,
          source: args.source,
          style: args.style,
          listingContext: args.listingContext,
        );
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
    GoRoute(
      path: AppRoutes.welcome,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const OnboardingScreen(),
    ),
  ],
);

/// This app's own "where should the user be" gate (`docs/SCREENS.md`
/// A2's own access rule: "first launch only"). Evaluated by `GoRouter`
/// on every navigation attempt, including the very first one:
/// - Not completed, and not already headed to [AppRoutes.welcome]:
///   redirect there, regardless of what was actually requested.
/// - Completed, and headed to [AppRoutes.welcome] (e.g. a stale deep
///   link, or just landing there again after finishing it): redirect
///   to Discover instead of showing it a second time.
/// - Otherwise: no redirect.
///
/// Reads [OnboardingRepository] through `getIt` rather than taking it
/// as a parameter — `appRouter` is a plain top-level `GoRouter`, not a
/// widget, so there's no constructor to thread it through; every other
/// cross-cutting read in this file (`MediaDetailNavigation`'s own
/// extension methods) does the same.
///
/// Deliberately synchronous — [OnboardingRepository.isCompleted] is a
/// plain, always-available value (see its own doc comment for why),
/// not awaited here. `redirect` runs on every navigation, including
/// pops; an `async` version of this function added a real timing gap
/// to each one, which surfaced as cross-test `Cubit`-used-after-close
/// flakiness in this app's own widget tests (a previous version of
/// this function awaited `isCompleted()`, before the interface was
/// changed to be synchronous specifically to fix this).
String? _onboardingRedirect(BuildContext context, GoRouterState state) {
  final isCompleted = getIt<OnboardingRepository>().isCompleted;
  final isWelcome = state.matchedLocation == AppRoutes.welcome;

  if (!isCompleted && !isWelcome) return AppRoutes.welcome;
  if (isCompleted && isWelcome) return '/';
  return null;
}
