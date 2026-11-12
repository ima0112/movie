import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/app.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/app/router.dart';
import 'package:movies/core/data/local/in_memory_onboarding_repository.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/repositories/onboarding_repository.dart';
import 'package:movies/core/domain/repositories/taste_profile_repository.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/features/discover/presentation/widgets/discover_search_field.dart';
import 'package:movies/features/explore/presentation/widgets/explore_pill.dart';
import 'package:movies/features/explore/presentation/widgets/explore_search_field.dart';
import 'package:movies/features/person_detail/presentation/screens/person_detail_screen.dart';
import 'package:movies/core/domain/entities/media_segment.dart';
import 'package:movies/shared/widgets/app_segmented_control.dart';
import 'package:movies/features/filtered_list/presentation/widgets/filtered_list_chips_row.dart';
import 'package:movies/shared/widgets/app_tab_bar.dart';
import 'package:movies/shared/widgets/explore_filter_sheet.dart';

/// End-to-end coverage for the flows this branch's own task asked to be
/// manually verified: typing in Explore's search field with its 400 ms
/// debounce, tapping a genre tile into C1, and applying a filter from H8
/// while C1 is open — all through the real `PakoTvApp`/router/DI, the
/// same style `router_test.dart` already uses for Discover's own flows.
///
/// `appRouter` is a module-level singleton (see `app/router.dart`), so
/// its current location carries over between separate `pumpWidget` calls
/// in this same test file — a later test can start already on whichever
/// tab an earlier one left active. Every test below finds the Explore
/// tab through [AppTabBar] specifically (the tabs are icon-only, so by
/// their semantics label) rather than a bare `find.text('Explore')`,
/// which would match Explore's own (still-mounted, per `IndexedStack`)
/// title text.
Finder _exploreTab() => find.descendant(
  of: find.byType(AppTabBar),
  matching: find.bySemanticsLabel('Explore'),
);

void main() {
  setUpAll(() {
    configureDependencies(fake.name);
    // Same swap `router_test.dart` makes — the real
    // DriftUserLibraryRepository/DriftTasteProfileRepository need
    // path_provider, unavailable in `flutter test`'s host environment.
    getIt.unregister<UserLibraryRepository>();
    getIt.registerLazySingleton<UserLibraryRepository>(
      InMemoryUserLibraryRepository.new,
    );
    getIt.unregister<TasteProfileRepository>();
    getIt.registerLazySingleton<TasteProfileRepository>(
      InMemoryTasteProfileRepository.new,
    );
    // Same swap for OnboardingRepository — `isCompleted: true`
    // (the default) since this test isn't about the onboarding
    // gate itself (see onboarding_redirect_test.dart for that).
    getIt.unregister<OnboardingRepository>();
    getIt.registerLazySingleton<OnboardingRepository>(
      InMemoryOnboardingRepository.new,
    );
  });

  /// The text field that is the primary focus right now, if any.
  bool searchFieldHasFocus(WidgetTester tester) {
    final field = tester.widget<TextField>(find.byType(TextField));
    return field.focusNode?.hasFocus ?? false;
  }

  testWidgets('B1\'s search bar opens Explore with the search field focused '
      '(keyboard up), every time', (tester) async {
    appRouter.go('/');
    addTearDown(() => appRouter.go('/'));
    await tester.pumpWidget(const PakoTvApp());
    await tester.pumpAndSettle();

    // Discover: the look-alike field.
    // The taller hero can push the bar below the fold of the test screen.
    await tester.ensureVisible(find.byType(DiscoverSearchField));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DiscoverSearchField));
    await tester.pumpAndSettle();
    expect(find.byType(ExploreSearchField), findsOneWidget);
    expect(searchFieldHasFocus(tester), isTrue);

    // Leave the field and the tab, come back through the shortcut again.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    appRouter.go('/');
    await tester.pumpAndSettle();
    // The taller hero can push the bar below the fold of the test screen.
    await tester.ensureVisible(find.byType(DiscoverSearchField));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DiscoverSearchField));
    await tester.pumpAndSettle();
    expect(searchFieldHasFocus(tester), isTrue);
  });

  testWidgets('opening Explore from its own tab does not grab the '
      'keyboard', (tester) async {
    appRouter.go('/');
    addTearDown(() => appRouter.go('/'));
    await tester.pumpWidget(const PakoTvApp());
    await tester.pumpAndSettle();

    await tester.tap(_exploreTab());
    await tester.pumpAndSettle();
    expect(searchFieldHasFocus(tester), isFalse);
  });

  testWidgets('searching finds people too: a circular row with "Department · '
      'Person" that opens D3; the Movies segment hides them', (tester) async {
    appRouter.go('/');
    addTearDown(() => appRouter.go('/'));
    await tester.pumpWidget(const PakoTvApp());
    await tester.pumpAndSettle();

    await tester.tap(_exploreTab());
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'zendaya');
    await tester.pumpAndSettle();

    expect(find.text('Zendaya'), findsOneWidget);
    expect(find.text('Acting · Person'), findsOneWidget);

    // Movies / TV Shows hide people.
    await tester.tap(
      find.descendant(
        of: find.byType(AppSegmentedControl<MediaSegment>),
        matching: find.text('Movies'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Zendaya'), findsNothing);

    await tester.tap(
      find.descendant(
        of: find.byType(AppSegmentedControl<MediaSegment>),
        matching: find.text('All'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zendaya'));
    await tester.pumpAndSettle();
    expect(find.byType(PersonDetailScreen), findsOneWidget);
  });

  Future<void> openExplore(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    appRouter.go('/');
    addTearDown(() => appRouter.go('/'));
    await tester.pumpWidget(const PakoTvApp());
    await tester.pumpAndSettle();
    await tester.tap(_exploreTab());
    await tester.pumpAndSettle();
  }

  testWidgets('B2 at rest: a full-width search bar on the page margin, no '
      'filter icon, the Platform pills and the six sections', (tester) async {
    await openExplore(tester);

    // Search field: 20 px margins both sides = the content's full width.
    final field = tester.getRect(find.byType(TextField));
    expect(field.left, 20);
    expect(field.right, 390 - 20);
    expect(find.byIcon(AppIcons.filter), findsNothing);

    // The segmented control keeps its All | Movies | TV Shows.
    expect(find.text('All'), findsWidgets);
    expect(find.text('Movies'), findsWidgets);

    // Pills.
    expect(find.text('PLATFORM'), findsOneWidget);
    expect(find.text('GENRE'), findsNothing);
    expect(find.text('Netflix'), findsOneWidget);

    // The four sections, Top today numbered.
    for (final title in [
      'Top today',
      'Popular',
      'Top rated',
      'New releases',
      'Coming soon',
      'Hidden gems',
    ]) {
      await tester.ensureVisible(find.text(title));
      expect(find.text(title), findsOneWidget, reason: title);
    }
    await tester.ensureVisible(find.text('Top today'));
    expect(find.text('1'), findsWidgets);
  });

  testWidgets('typing puts an × inside the field (no Cancel); it clears', (
    tester,
  ) async {
    await openExplore(tester);

    await tester.enterText(find.byType(TextField), 'dune');
    await tester.pump();
    expect(find.byIcon(AppIcons.close), findsOneWidget);
    expect(find.text('Cancel'), findsNothing);

    await tester.tap(find.byIcon(AppIcons.close));
    await tester.pumpAndSettle();
    expect(find.byIcon(AppIcons.close), findsNothing);
    expect(find.text('Top today'), findsOneWidget);
  });

  testWidgets('a platform pill becomes the selected one', (tester) async {
    await openExplore(tester);

    await tester.tap(find.text('Netflix'));
    await tester.pumpAndSettle();

    final pill = tester.widget<ExplorePill>(
      find.ancestor(
        of: find.text('Netflix'),
        matching: find.byType(ExplorePill),
      ),
    );
    expect(pill.selected, isTrue);
    final all = tester
        .widgetList<ExplorePill>(find.byType(ExplorePill))
        .where((p) => p.label == 'All' && p.selected);
    expect(all, isEmpty); // "All" is no longer the selected one
  });

  testWidgets('typing in Explore debounces, then shows search results', (
    tester,
  ) async {
    await tester.pumpWidget(const PakoTvApp());
    await tester.pumpAndSettle();

    await tester.tap(_exploreTab());
    await tester.pumpAndSettle();
    expect(find.byType(ExploreSearchField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'dune');
    // Right after typing, still within the 400 ms debounce window —
    // FakeMediaRepository.searchMulti hasn't even been called yet.
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Dune: Part Two'), findsNothing);

    // Past the debounce, then past FakeMediaRepository's own 400 ms
    // artificial delay.
    await tester.pumpAndSettle();
    expect(find.text('Dune: Part Two'), findsOneWidget);
  });

  testWidgets(
    'a section\'s "See all" reaches C1 with that section\'s filter; applying '
    'a filter from H8 adds a chip',
    (tester) async {
      appRouter.go('/');
      addTearDown(() => appRouter.go('/'));
      await tester.pumpWidget(const PakoTvApp());
      await tester.pumpAndSettle();

      await tester.tap(_exploreTab());
      await tester.pumpAndSettle();

      await tester.tap(find.text('See all').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AppIcons.filter));
      await tester.pumpAndSettle();
      final sheet = find.byType(ExploreFilterSheet);
      await tester.tap(
        find.descendant(of: sheet, matching: find.text('Horror')),
      );
      await tester.pumpAndSettle();
      final applyButton = find.descendant(
        of: sheet,
        matching: find.textContaining('results'),
      );
      await tester.ensureVisible(applyButton);
      await tester.tap(applyButton);
      await tester.pumpAndSettle();

      final chipsRow = find.byType(FilteredListChipsRow);
      expect(
        find.descendant(of: chipsRow, matching: find.text('Horror')),
        findsOneWidget,
      );
    },
  );
}
