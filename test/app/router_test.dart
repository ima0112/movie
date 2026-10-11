import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/app.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/core/data/local/in_memory_onboarding_repository.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/repositories/onboarding_repository.dart';
import 'package:movies/core/domain/repositories/taste_profile_repository.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/shared/widgets/media_card.dart';

void main() {
  setUpAll(() {
    configureDependencies(fake.name);
    // The real DriftUserLibraryRepository/DriftTasteProfileRepository
    // need a native sqlite file via path_provider, which has no
    // platform channel in `flutter test`'s host environment — swap in
    // the fast, in-memory test doubles instead of exercising real (and
    // here, unavailable) disk I/O. Navigating into a movie detail
    // screen (below) resolves UserLibraryRepository via MovieActionRow;
    // Discover's own RecommendationsCubit resolves both on every load.
    getIt.unregister<UserLibraryRepository>();
    getIt.registerLazySingleton<UserLibraryRepository>(
      InMemoryUserLibraryRepository.new,
    );
    getIt.unregister<TasteProfileRepository>();
    getIt.registerLazySingleton<TasteProfileRepository>(
      InMemoryTasteProfileRepository.new,
    );
    // Same swap for OnboardingRepository — these tests exercise
    // Discover/tabs/detail navigation, not the onboarding gate itself
    // (see onboarding_redirect_test.dart for that), so `isCompleted:
    // true` (the default) keeps them landing where they already did.
    getIt.unregister<OnboardingRepository>();
    getIt.registerLazySingleton<OnboardingRepository>(
      InMemoryOnboardingRepository.new,
    );
  });

  testWidgets('the four tabs navigate, and switching back to Discover '
      'keeps its already-loaded state instead of reloading from scratch', (
    tester,
  ) async {
    await tester.pumpWidget(const PakoTvApp());
    await tester.pumpAndSettle();

    // Discover (/) loaded.
    expect(find.text('Dune: Part Two'), findsOneWidget);

    // Explore (/explore).
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    expect(find.text('Explore'), findsWidgets);
    expect(find.text('Dune: Part Two'), findsNothing);

    // My List (/my-list) — placeholder.
    await tester.tap(find.text('My List'));
    await tester.pumpAndSettle();
    expect(find.text('My List'), findsWidgets);

    // You (/you) — placeholder.
    await tester.tap(find.text('You'));
    await tester.pumpAndSettle();
    expect(find.text('You'), findsWidgets);

    // Back to Discover: StatefulShellRoute.indexedStack keeps each
    // branch's Navigator (and DiscoverCubit's already-loaded state) alive
    // underneath — a single `pump()` (no time for a fresh 400ms fake-repo
    // load) should already show the previously-loaded hero, not a
    // skeleton.
    await tester.tap(find.text('Discover'));
    await tester.pump();
    expect(find.text('Dune: Part Two'), findsOneWidget);
  });

  testWidgets('tapping the hero card pushes /movie/:id with the right id; '
      'back returns to Discover', (tester) async {
    await tester.pumpWidget(const PakoTvApp());
    await tester.pumpAndSettle();

    // FakeMediaRepository's "Dune: Part Two" has id 1, with full D1
    // sample data — a real trailer proves the right movie loaded.
    await tester.tap(find.text('Dune: Part Two'));
    await tester.pumpAndSettle();
    expect(find.text('Trailer'), findsOneWidget);
    expect(find.byIcon(AppIcons.back), findsOneWidget);
    // The pushed detail hides the tab bar — a pushed screen per
    // docs/SCREENS.md ("every pushed screen... hides the bottom bar").
    expect(find.text('Discover'), findsNothing);

    await tester.tap(find.byIcon(AppIcons.back));
    await tester.pumpAndSettle();
    expect(find.text('Dune: Part Two'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);
  });

  testWidgets(
    'tapping a section-carousel card pushes the detail too; back returns '
    "to Discover with its scroll position intact (push, not go)",
    (tester) async {
      await tester.pumpWidget(const PakoTvApp());
      await tester.pumpAndSettle();

      final scrollable = find.byType(Scrollable).first;
      await tester.drag(scrollable, const Offset(0, -700));
      await tester.pumpAndSettle();
      final scrollOffsetBefore = tester
          .state<ScrollableState>(scrollable)
          .position
          .pixels;

      // A carousel card has no title text of its own (docs/SCREENS.md B1:
      // "no title or year underneath"), so find it structurally instead.
      // Whatever it is (a movie with full sample data, one with the
      // generic fallback, or — D2 not being implemented yet — a TV show
      // that ends in an error state) always renders exactly one way back.
      final carouselCard = find.byWidgetPredicate(
        (widget) =>
            widget is MediaCard && widget.size == MediaCardSize.carousel,
      );
      expect(carouselCard, findsWidgets);
      await tester.tap(carouselCard.first);
      await tester.pumpAndSettle();
      expect(find.byIcon(AppIcons.back), findsOneWidget);

      await tester.tap(find.byIcon(AppIcons.back));
      await tester.pumpAndSettle();

      final scrollOffsetAfter = tester
          .state<ScrollableState>(scrollable)
          .position
          .pixels;
      expect(scrollOffsetAfter, scrollOffsetBefore);
    },
  );
}
