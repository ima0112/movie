import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/app.dart';
import 'package:movies/app/di.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/features/explore/presentation/widgets/explore_search_field.dart';
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
/// tab through [AppTabBar] specifically rather than a bare
/// `find.text('Explore')`, which would otherwise sometimes also match
/// Explore's own (still-mounted, per `IndexedStack`) title text.
Finder _exploreTab() =>
    find.descendant(of: find.byType(AppTabBar), matching: find.text('Explore'));

void main() {
  setUpAll(() {
    configureDependencies();
    // Same swap `router_test.dart` makes — the real DriftUserLibraryRepository
    // needs path_provider, unavailable in `flutter test`'s host environment.
    getIt.unregister<UserLibraryRepository>();
    getIt.registerLazySingleton<UserLibraryRepository>(
      InMemoryUserLibraryRepository.new,
    );
  });

  testWidgets(
    'typing in Explore debounces, then shows search results',
    (tester) async {
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
    },
  );

  testWidgets(
    'tapping a genre tile reaches C1 with that genre as an active chip; '
    'applying a filter from H8 adds another chip',
    (tester) async {
      await tester.pumpWidget(const PakoTvApp());
      await tester.pumpAndSettle();

      await tester.tap(_exploreTab());
      await tester.pumpAndSettle();

      // Horror matches exactly one sample movie (see
      // filtered_list_cubit_test.dart's own comment to the same effect) —
      // enough to land in C1's loaded, non-empty state. It's alphabetically
      // 10th in GenreCatalog.all, so it may start below the fold — scroll
      // it into view first (`recent_searches_chips.dart`'s "Recent" row,
      // possibly non-empty from an earlier test's search history, pushes
      // it down further still).
      await tester.ensureVisible(find.text('Horror'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Horror'));
      await tester.pumpAndSettle();

      // C1's app-bar title is the genre's own name (`ExploreCubit
      // .openListing`'s `title: genre.name`), and its chips row shows it
      // again as a removable chip — scoped finders below because of that
      // overlap, and because H8 (opened next) reuses `GenreMultiSelectChips`
      // to show the same genre already selected.
      final chipsRow = find.byType(FilteredListChipsRow);
      expect(
        find.descendant(of: chipsRow, matching: find.text('Horror')),
        findsOneWidget,
      );
      expect(find.text('1 results · Popularity'), findsOneWidget);

      // Open H8 and add "Comedy" as a second included genre — genres are
      // OR'd together (`DiscoverFilter.withGenres`'s own doc comment), so
      // this only ever *adds* results, unlike switching type to TV Shows
      // (which would zero out Horror's one movie-only match instead of
      // combining with it).
      await tester.tap(find.byIcon(AppIcons.filter));
      await tester.pumpAndSettle();
      final sheet = find.byType(ExploreFilterSheet);
      await tester.tap(
        find.descendant(of: sheet, matching: find.text('Comedy')),
      );
      await tester.pumpAndSettle();
      final applyButton = find.descendant(
        of: sheet,
        matching: find.textContaining('results'),
      );
      await tester.ensureVisible(applyButton);
      await tester.tap(applyButton);
      await tester.pumpAndSettle();

      // Both dimensions now show as removable chips on C1.
      expect(
        find.descendant(of: chipsRow, matching: find.text('Comedy')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: chipsRow, matching: find.text('Horror')),
        findsOneWidget,
      );
    },
  );
}
