import 'dart:async';

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
import 'package:movies/core/theme/app_spacing.dart';
import 'package:movies/features/tv_detail/presentation/screens/season_screen.dart';
import 'package:movies/features/tv_detail/presentation/screens/tv_seasons_screen.dart';
import 'package:movies/shared/widgets/app_chip.dart';
import 'package:movies/shared/widgets/media_detail/media_cast_circle.dart';
import 'package:movies/shared/widgets/media_detail/media_cast_row.dart';
import 'package:movies/shared/widgets/media_detail/media_stat_cards.dart';
import 'package:movies/shared/widgets/media_detail/media_detail_compact_bar.dart';
import 'package:movies/shared/widgets/media_detail/media_similar_section.dart';
import 'package:movies/shared/widgets/media_detail/media_synopsis_section.dart';
import 'package:movies/shared/widgets/media_detail/where_to_watch_section.dart';

/// D2 (TV detail) on the fake repository's The Boys (106). Manual-verification checklist from the task, made automatic and
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

  Future<void> openTheBoys(WidgetTester tester) async {
    appRouter.go('/');
    await tester.pumpWidget(const PakoTvApp());
    await tester.pumpAndSettle();
    unawaited(appRouter.push(AppRoutes.tvDetail(106)));
    await tester.pumpAndSettle();
  }

  testWidgets('sections run cards -> synopsis -> where to watch -> cast -> '
      'similar, and the crew names are not listed', (tester) async {
    tester.view.physicalSize = const Size(390, 5000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await openTheBoys(tester);

    double top(Finder f) => tester.getTopLeft(f).dy;
    final cards = top(find.byType(MediaStatCards));
    final synopsis = top(find.byType(MediaSynopsisSection));
    final where = top(find.byType(WhereToWatchSection));
    final cast = top(find.byType(MediaCastRow));
    final similar = top(find.byType(MediaSimilarSection));

    expect(cards, lessThan(synopsis));
    expect(synopsis, lessThan(where));
    expect(where, lessThan(cast));
    expect(cast, lessThan(similar));
    expect(find.text('Similar TV shows'), findsOneWidget);
    // "Created by" sits under the Cast heading, above the circles.
    final created = top(find.textContaining('Created by'));
    expect(created, greaterThan(top(find.text('Cast'))));
    expect(created, lessThan(top(find.byType(MediaCastCircle).first)));
    // FakeMediaRepository's crew (a writer) is not printed.
    expect(find.textContaining('(Writer)'), findsNothing);
  });

  testWidgets('the Status and Seasons cards; Seasons opens D2b', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await openTheBoys(tester);

    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Seasons'), findsOneWidget);
    // No status pill in the header any more.
    expect(find.byType(AppChip), findsNothing);

    await tester.tap(find.text('Seasons'));
    await tester.pumpAndSettle();
    expect(find.byType(TvSeasonsScreen), findsOneWidget);
  });

  testWidgets('every section starts the same sectionGap below the previous '
      'one', (tester) async {
    tester.view.physicalSize = const Size(390, 5000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await openTheBoys(tester);

    double top(Finder f) => tester.getTopLeft(f).dy;
    double bottom(Finder f) => tester.getBottomLeft(f).dy;
    final sections = [
      find.byType(MediaSynopsisSection),
      find.byType(WhereToWatchSection),
      find.byType(MediaCastRow),
      find.byType(MediaSimilarSection),
    ];
    for (var i = 1; i < sections.length; i++) {
      expect(top(sections[i]), moreOrLessEquals(bottom(sections[i - 1])));
    }
    expect(
      tester.getTopLeft(find.text('Where to watch')).dy - top(sections[1]),
      greaterThanOrEqualTo(AppSpacing.sectionGap),
    );
  });

  testWidgets('the compact bar appears once scrolled and stays, with Share', (
    tester,
  ) async {
    await openTheBoys(tester);
    expect(find.byType(MediaDetailCompactBar), findsNothing);

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(find.byType(MediaDetailCompactBar), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(MediaDetailCompactBar),
        matching: find.byIcon(AppIcons.share),
      ),
      findsOneWidget,
    );

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -5000));
    await tester.pumpAndSettle();
    expect(find.byType(MediaDetailCompactBar), findsOneWidget);
  });

  testWidgets('a season opens as a page (not a sheet), the episode over it as '
      'a sheet, and back returns to the seasons', (tester) async {
    tester.view.physicalSize = const Size(390, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await openTheBoys(tester);

    await tester.tap(find.text('Seasons'));
    await tester.pumpAndSettle();
    expect(find.byType(TvSeasonsScreen), findsOneWidget);

    await tester.tap(find.text('Season 1').first);
    await tester.pumpAndSettle();
    expect(find.byType(SeasonScreen), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    // The show's name is the title, the season the big header.
    expect(find.text('The Boys'), findsWidgets);

    await tester.tap(find.byIcon(AppIcons.back).first);
    await tester.pumpAndSettle();
    expect(find.byType(SeasonScreen), findsNothing);
    expect(find.byType(TvSeasonsScreen), findsOneWidget);
  });
}
