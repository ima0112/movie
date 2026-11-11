import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/app.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/app/router.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/shared/widgets/media_detail/full_cast_screen.dart';
import 'package:movies/core/data/local/in_memory_onboarding_repository.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/repositories/onboarding_repository.dart';
import 'package:movies/core/domain/repositories/taste_profile_repository.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/core/theme/app_spacing.dart';
import 'package:movies/shared/widgets/app_buttons.dart';
import 'package:movies/shared/widgets/scrim_back_button.dart';
import 'package:movies/shared/widgets/media_detail/media_cast_row.dart';
import 'package:movies/shared/widgets/media_detail/media_detail_action_row.dart';
import 'package:movies/shared/widgets/media_detail/media_detail_compact_bar.dart';
import 'package:movies/shared/widgets/media_detail/media_similar_section.dart';
import 'package:movies/shared/widgets/media_detail/media_synopsis_section.dart';
import 'package:movies/shared/widgets/media_detail/where_to_watch_section.dart';

/// Manual-verification checklist from the task, made automatic and
/// repeatable via `WidgetTester` instead of a live simulator session —
/// this environment has no gesture-injection tool for the simulator, so
/// `tester.tap`/`tester.drag` plus `debugPrintRebuildDirtyWidgets` (as
/// suggested) is the rigorous equivalent.
void main() {
  setUpAll(() {
    configureDependencies(fake.name);
    // The real DriftUserLibraryRepository/DriftTasteProfileRepository
    // need a native sqlite file via path_provider, which has no
    // platform channel in `flutter test`'s host environment — swap in
    // the fast, in-memory test doubles instead of exercising real (and
    // here, unavailable) disk I/O. Back on Discover (pushed from here,
    // popped back to), RecommendationsCubit resolves both.
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

  /// FakeMediaRepository's "Dune: Part Two" (id 1) has full D1 sample
  /// data — cast, crew, a trailer, similar, watch providers, and genres.
  Future<void> openDuneDetail(WidgetTester tester) async {
    // `appRouter` is a module-level singleton shared by every test in
    // this file — reset it *before* the first pump, so this test never
    // even transiently mounts whatever screen a previous test left
    // pushed (which would start a doomed async `loadDetail` on a
    // `MovieDetailCubit` this reset is about to dispose).
    appRouter.go('/');
    await tester.pumpWidget(const PakoTvApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dune: Part Two').first);
    await tester.pumpAndSettle();
  }

  testWidgets('the compact bar is hidden at rest and appears once the '
      'header has scrolled past the top', (tester) async {
    await openDuneDetail(tester);

    expect(find.byType(MediaDetailCompactBar), findsNothing);

    // The header is 55% of the screen — dragging further than that
    // scrolls the title well past the top.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -800));
    await tester.pumpAndSettle();

    expect(find.byType(MediaDetailCompactBar), findsOneWidget);
    // The bar keeps the Share action (the header's circle has scrolled away).
    expect(
      find.descendant(
        of: find.byType(MediaDetailCompactBar),
        matching: find.byIcon(AppIcons.share),
      ),
      findsOneWidget,
    );

    // And it stays however far down the page goes.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -5000));
    await tester.pumpAndSettle();
    expect(find.byType(MediaDetailCompactBar), findsOneWidget);
  });

  testWidgets('shows the Duration and Classification stat cards and the '
      'SYNOPSIS caption, from the app\'s own strings', (tester) async {
    tester.view.physicalSize = const Size(390, 5000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await openDuneDetail(tester);

    expect(find.text('Duration'), findsOneWidget);
    expect(find.text('2 h 46 min'), findsOneWidget);
    expect(find.text('Classification'), findsOneWidget);
    expect(find.text('PG-13'), findsOneWidget);
    expect(find.text('SYNOPSIS'), findsOneWidget);
  });

  testWidgets('every section starts the same AppSpacing.sectionGap below the '
      'previous one', (tester) async {
    tester.view.physicalSize = const Size(390, 5000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await openDuneDetail(tester);

    double top(Finder f) => tester.getTopLeft(f).dy;
    double bottom(Finder f) => tester.getBottomLeft(f).dy;
    final sections = [
      find.byType(MediaSynopsisSection),
      find.byType(WhereToWatchSection),
      find.byType(MediaCastRow),
      find.byType(MediaSimilarSection),
    ];
    for (var i = 1; i < sections.length; i++) {
      // Each section widget wraps its own top padding, so the box starts at
      // the end of the previous one and its first content sits sectionGap in.
      expect(top(sections[i]), moreOrLessEquals(bottom(sections[i - 1])));
    }
    // The first content of each section (a Text/heading) is sectionGap below
    // the section's own top edge.
    expect(
      tester.getTopLeft(find.text('Where to watch')).dy - top(sections[1]),
      greaterThanOrEqualTo(AppSpacing.sectionGap),
    );
  });

  testWidgets('the full cast route opens a page (not a sheet) titled with the '
      'movie, and back returns to the detail', (tester) async {
    await openDuneDetail(tester);

    unawaited(
      appRouter.push(
        AppRoutes.fullCast,
        extra: const FullCastRouteArgs(
          title: 'Dune: Part Two',
          cast: [],
          crew: [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FullCastScreen), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);

    await tester.tap(find.byIcon(AppIcons.back));
    await tester.pumpAndSettle();
    expect(find.byType(FullCastScreen), findsNothing);
  });

  testWidgets('a movie with no trailer, no similar titles and no services has '
      'no primary button (it would lead nowhere)', (tester) async {
    // Movie 4 has no sample detail, so the fake gives it a bare one.
    appRouter.go('/');
    await tester.pumpWidget(const PakoTvApp());
    await tester.pumpAndSettle();
    unawaited(appRouter.push(AppRoutes.movieDetail(4)));
    await tester.pumpAndSettle();

    expect(find.byType(MediaDetailActionRow), findsOneWidget);
    expect(find.byType(PrimaryButton), findsNothing);
    expect(find.text('See similar'), findsNothing);
    expect(find.text('Watched'), findsOneWidget);
  });

  testWidgets('the back button stays pinned while the header scrolls away', (
    tester,
  ) async {
    await openDuneDetail(tester);
    Offset backPos() => tester.getTopLeft(
      find.descendant(
        of: find.byType(ScrimBackButton),
        matching: find.byType(Container),
      ),
    );
    final rest = backPos();

    // A partial scroll, header still half on screen, no compact bar yet.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -150));
    await tester.pumpAndSettle();
    expect(find.byType(MediaDetailCompactBar), findsNothing);
    expect(backPos(), rest);
  });

  testWidgets('sections run synopsis -> where to watch -> cast -> similar, '
      'and the crew\'s names are not listed', (tester) async {
    // Tall enough that every sliver is built at once, so their positions can
    // be compared.
    tester.view.physicalSize = const Size(390, 5000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await openDuneDetail(tester);

    double top(Finder f) => tester.getTopLeft(f).dy;
    final synopsis = top(find.byType(MediaSynopsisSection));
    final where = top(find.byType(WhereToWatchSection));
    final cast = top(find.byType(MediaCastRow));
    final similar = top(find.byType(MediaSimilarSection));

    expect(synopsis, lessThan(where));
    expect(where, lessThan(cast));
    expect(cast, lessThan(similar));
    expect(find.text('Similar movies'), findsOneWidget);
    // The director(s) are credited under the Cast heading, not as a long list.
    expect(find.textContaining('Directed by'), findsOneWidget);
    // FakeMediaRepository's crew (director, writer) is not printed.
    expect(find.textContaining('(Director)'), findsNothing);
    expect(find.textContaining('(Writer)'), findsNothing);
  });

  testWidgets('tapping a genre pushes the real C1 (filtered listing) for that '
      'genre and type', (tester) async {
    await openDuneDetail(tester);

    // Dune: Part Two's genres (FakeMediaRepository): Science Fiction,
    // Drama.
    await tester.tap(find.text('Science Fiction'));
    await tester.pumpAndSettle();

    // C1's own top bar title is the genre's name (same convention as
    // B2's genre tiles — see explore_content.dart). C1's grid cards
    // show no title text (filtered_list_grid.dart's own doc comment),
    // so this checks the count line instead: Dune: Part Two, Furiosa,
    // and Untitled Sci-Fi Project are FakeMediaRepository's only
    // three *movies* carrying Science Fiction.
    expect(find.text('Science Fiction'), findsWidgets);
    expect(find.text('3 results · Popularity'), findsOneWidget);
  });

  testWidgets(
    'tapping Favorite rebuilds only its own action button, not the rest '
    'of the screen (CLAUDE.md rule 9)',
    (tester) async {
      await openDuneDetail(tester);
      // The taller header pushes the action row below the fold of the test
      // view: scroll it into reach first (outside the capture).
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -260));
      await tester.pumpAndSettle();

      final captured = <String>[];
      final originalDebugPrint = debugPrint;
      debugPrintRebuildDirtyWidgets = true;
      debugPrint = (message, {wrapWidth}) {
        if (message != null) captured.add(message);
      };
      try {
        await tester.tap(find.bySemanticsLabel('Favorite'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
      } finally {
        debugPrintRebuildDirtyWidgets = false;
        debugPrint = originalDebugPrint;
      }

      bool rebuilt(String widgetName) =>
          captured.any((line) => line.contains(widgetName));

      // The tap only travels through MediaDetailActionRow's own
      // StreamBuilder — its sibling sections, the header, and the
      // screen's Scaffold never get marked dirty by it.
      expect(rebuilt('MediaActionButton'), isTrue);
      expect(rebuilt('MediaDetailHeader'), isFalse);
      expect(rebuilt('WhereToWatchSection'), isFalse);
      expect(rebuilt('MediaSynopsisSection'), isFalse);
      expect(rebuilt('MediaCastRow'), isFalse);
      expect(rebuilt('MediaSimilarSection'), isFalse);
      expect(rebuilt('CustomScrollView'), isFalse);
    },
  );
}
