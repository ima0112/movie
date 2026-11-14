import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/core/data/local/in_memory_recently_viewed_repository.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/repositories/recently_viewed_repository.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/repositories/taste_profile_repository.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/features/discover/presentation/screens/discover_screen.dart';
import 'package:movies/l10n/app_localizations.dart';

final recent = InMemoryRecentlyViewedRepository();

void main() {
  setUpAll(() {
    configureDependencies(fake.name);
    // The real DriftUserLibraryRepository/DriftTasteProfileRepository
    // need a native sqlite file via path_provider, which has no
    // platform channel in `flutter test`'s host environment —
    // RecommendationsCubit resolves both on every load.
    getIt.unregister<UserLibraryRepository>();
    getIt.registerLazySingleton<UserLibraryRepository>(
      InMemoryUserLibraryRepository.new,
    );
    getIt.unregister<RecentlyViewedRepository>();
    getIt.registerLazySingleton<RecentlyViewedRepository>(() => recent);
    getIt.unregister<TasteProfileRepository>();
    getIt.registerLazySingleton<TasteProfileRepository>(
      InMemoryTasteProfileRepository.new,
    );
  });

  Future<void> pumpDiscoverScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const DiscoverScreen(),
      ),
    );
  }

  testWidgets('shows a skeleton while loading, then the hero once loaded', (
    tester,
  ) async {
    await pumpDiscoverScreen(tester);

    // Loading: no hero title yet (FakeMediaRepository has a 400ms delay).
    expect(find.text('Dune: Part Two'), findsNothing);

    await tester.pumpAndSettle();

    // Loaded: the fake repository's first "All" segment movie shows up
    // as the hero's title.
    expect(find.text('Dune: Part Two'), findsOneWidget);
    expect(find.text('PakoTV'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Movies'), findsOneWidget);
    expect(find.text('TV Shows'), findsOneWidget);
  });

  testWidgets('switching segments loads that segment\'s data', (tester) async {
    await pumpDiscoverScreen(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Movies'));
    // The segmented control itself updates before the load resolves.
    await tester.pump();
    await tester.pumpAndSettle();

    // The section is below the fold (after the full-height hero) — the
    // ListView only builds what's currently visible, so scroll to it.
    await tester.scrollUntilVisible(
      find.text('Trending'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Trending'), findsOneWidget);
    expect(find.text('Airing now'), findsNothing);
  });

  testWidgets('tapping a hero save button only toggles that icon', (
    tester,
  ) async {
    await pumpDiscoverScreen(tester);
    await tester.pumpAndSettle();

    // All hero save buttons start unsaved (outline icon); none filled yet.
    expect(find.byIcon(AppIcons.watchLater), findsWidgets);
    expect(find.byIcon(AppIcons.watchLaterFill), findsNothing);
    final unsavedCountBefore = find
        .byIcon(AppIcons.watchLater)
        .evaluate()
        .length;

    await tester.tap(find.byIcon(AppIcons.watchLater).first);
    // The write goes through the repository and comes back on its stream.
    await tester.pumpAndSettle();

    // Exactly the tapped one flips to filled/saved — the rest stay put.
    expect(find.byIcon(AppIcons.watchLaterFill), findsOneWidget);
    expect(
      find.byIcon(AppIcons.watchLater).evaluate().length,
      unsavedCountBefore - 1,
    );

    // Untouched content around it, e.g. the hero title, is unaffected.
    expect(find.text('Dune: Part Two'), findsOneWidget);

    // And it really is in Watch later (it used to be a session-only icon).
    final watchLater = await tester.runAsync(
      () => getIt<UserLibraryRepository>()
          .watch(tab: LibraryTab.watchLater)
          .first,
    );
    expect(watchLater!.map((e) => e.title), contains('Dune: Part Two'));

    // Tapping again takes it out.
    await tester.tap(find.byIcon(AppIcons.watchLaterFill));
    await tester.pumpAndSettle();
    expect(find.byIcon(AppIcons.watchLaterFill), findsNothing);
  });

  testWidgets('Recently viewed shows in the All tab only, once something has '
      'been viewed', (tester) async {
    await pumpDiscoverScreen(tester);
    await tester.pumpAndSettle();
    expect(find.text('Recently viewed'), findsNothing);

    await recent.record(
      Movie(
        id: 42,
        title: 'Seen Movie',
        posterUrl: null,
        genres: const [],
        releaseDate: null,
        voteAverage: 7,
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Recently viewed'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Recently viewed'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Movies'),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Movies'));
    await tester.pumpAndSettle();
    expect(find.text('Recently viewed'), findsNothing);
  });
}
