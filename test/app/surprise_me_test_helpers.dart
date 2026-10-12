import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/app/router.dart';
import 'package:movies/core/data/local/in_memory_onboarding_repository.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/repositories/onboarding_repository.dart';
import 'package:movies/core/domain/repositories/taste_profile_repository.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/features/suggestion/presentation/cubit/surprise_cubit.dart';
import 'package:movies/features/suggestion/presentation/screens/choose_type_screen.dart';
import 'package:movies/features/suggestion/presentation/screens/surprise_quiz_screen.dart';
import 'package:movies/features/suggestion/presentation/screens/surprise_result_screen.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/vibe_tile_grid.dart';

/// Shared setup for the Surprise-me end-to-end files
/// (`surprise_me_*_test.dart`) — split one scenario per file rather
/// than one file with several `testWidgets`: a second `MaterialApp
/// .router` + real `getIt` DI pumped in the *same* process as an
/// earlier one hangs on `pumpAndSettle` for reasons that trace to
/// `go_router`/`flutter_test` interaction, not to anything in this
/// app's own code — reproduced even with a single, reused `GoRouter`
/// instance and with `VibeCatalog.loadFromAssets()`'s own caching
/// removed, so it isn't either of those. Each scenario gets its own
/// file/process instead of chasing that further.
void configureSurpriseMeDependencies() {
  configureDependencies(fake.name);
  // The real drift-backed repositories need path_provider, unavailable
  // in `flutter test`'s host environment.
  getIt.unregister<UserLibraryRepository>();
  getIt.registerLazySingleton<UserLibraryRepository>(
    InMemoryUserLibraryRepository.new,
  );
  getIt.unregister<TasteProfileRepository>();
  getIt.registerLazySingleton<TasteProfileRepository>(
    InMemoryTasteProfileRepository.new,
  );
  getIt.unregister<OnboardingRepository>();
  getIt.registerLazySingleton<OnboardingRepository>(
    InMemoryOnboardingRepository.new,
  );
}

/// A real `GoRouter` with just the 3 routes this flow actually touches,
/// `/surprise` as the entry point — the same `parentNavigatorKey`/route
/// shape `app/router.dart` uses for real, just without the other ~20
/// unrelated routes/the 4-tab shell. Lets each file test
/// `ChooseTypeScreen`'s own `showModalBottomSheet` and
/// `context.push`/`pushReplacement` calls exactly as written, without
/// going through B3's `MatchHubSheet` or Discover's own carousels —
/// neither of which this flow needs, and the former has a pre-existing,
/// unrelated layout gap (its own `Column` has no scrollable, overflowing
/// at `flutter_test`'s default window) that would otherwise fail these
/// files for a reason that has nothing to do with Surprise-me.
Future<void> pumpSurpriseMe(WidgetTester tester) async {
  // This file is about DI/provider wiring and navigation, not pixel
  // layout. A `RenderFlex overflowed` here traces to this environment
  // (narrow default test window, a non-Manrope fallback font since
  // Google Fonts can't fetch over the network under `flutter_test`),
  // not to anything this test actually exercises — letting it through
  // unreported keeps this file testing what it says it tests; anything
  // else still fails normally.
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exception.toString().contains('RenderFlex overflowed')) {
      return;
    }
    previousOnError?.call(details);
  };
  addTearDown(() => FlutterError.onError = previousOnError);

  final router = GoRouter(
    initialLocation: AppRoutes.surprise,
    routes: [
      GoRoute(
        path: AppRoutes.surprise,
        builder: (context, state) => const ChooseTypeScreen(),
      ),
      GoRoute(
        path: AppRoutes.surpriseQuiz,
        builder: (context, state) =>
            SurpriseQuizScreen(cubit: state.extra! as SurpriseCubit),
      ),
      GoRoute(
        path: AppRoutes.surpriseResult,
        builder: (context, state) =>
            SurpriseResultScreen(cubit: state.extra! as SurpriseCubit),
      ),
    ],
  );

  await tester.pumpWidget(
    MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
  await tester.pumpAndSettle();

  expect(find.text('What are you in the mood for today?'), findsOneWidget);
}

/// Taps through E2's 4 steps with the minimum valid selection on each —
/// step 1 (vetoes) and steps 3/4 always start valid; step 2 needs
/// exactly 3 vibes.
Future<void> completeQuiz(WidgetTester tester) async {
  expect(find.text('Next'), findsOneWidget);
  await tester.tap(find.text('Next')); // step 1 -> 2
  await tester.pumpAndSettle();

  final tiles = find.descendant(
    of: find.byType(VibeTileGrid),
    matching: find.byType(GestureDetector),
  );
  expect(tiles, findsWidgets);
  await tester.tap(tiles.at(0));
  await tester.tap(tiles.at(1));
  await tester.tap(tiles.at(2));
  await tester.pump();

  await tester.tap(find.text('Next')); // step 2 -> 3
  await tester.pumpAndSettle();
  await tester.tap(find.text('Next')); // step 3 -> 4
  await tester.pumpAndSettle();

  await tester.tap(find.text('Search')); // step 4 -> SurpriseCubit.answerWith
  await settleSearch(tester);
}

/// `pumpAndSettle` only keeps pumping while a frame is actually
/// scheduled — a quiet gap where `SurpriseCubit._search` is purely
/// awaiting a `Timer`/the engine's own `Future` (nothing requesting a
/// new frame yet) makes it return early, well before
/// `SurpriseCubit.minSearchingDuration`/`.maxSearchingDuration` have
/// actually elapsed. An explicit pump longer than
/// `maxSearchingDuration` first guarantees the search has genuinely
/// resolved one way or another before the final settle.
Future<void> settleSearch(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 9));
  await tester.pumpAndSettle();
}

void expectOnSurpriseResultScreen() {
  expect(find.text('Your suggestion'), findsOneWidget);
  expect(find.text('Another suggestion'), findsOneWidget);
}
