import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/app.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/router.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/features/movie_detail/presentation/widgets/movie_detail_compact_bar.dart';

/// Manual-verification checklist from the task, made automatic and
/// repeatable via `WidgetTester` instead of a live simulator session —
/// this environment has no gesture-injection tool for the simulator, so
/// `tester.tap`/`tester.drag` plus `debugPrintRebuildDirtyWidgets` (as
/// suggested) is the rigorous equivalent.
void main() {
  setUpAll(() {
    configureDependencies();
    // The real DriftUserLibraryRepository needs a native sqlite file via
    // path_provider, which has no platform channel in `flutter test`'s
    // host environment — swap in the fast, in-memory test double instead
    // of exercising real (and here, unavailable) disk I/O.
    getIt.unregister<UserLibraryRepository>();
    getIt.registerLazySingleton<UserLibraryRepository>(
      InMemoryUserLibraryRepository.new,
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
    await tester.tap(find.text('Dune: Part Two'));
    await tester.pumpAndSettle();
  }

  testWidgets('the compact bar is hidden at rest and appears once the '
      'header has scrolled past the top', (tester) async {
    await openDuneDetail(tester);

    expect(find.byType(MovieDetailCompactBar), findsNothing);

    // The header is 55% of the screen — dragging further than that
    // scrolls the title well past the top.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -800));
    await tester.pumpAndSettle();

    expect(find.byType(MovieDetailCompactBar), findsOneWidget);
  });

  testWidgets(
    'tapping a genre pushes the C1 placeholder with the right genre/type',
    (tester) async {
      await openDuneDetail(tester);

      // Dune: Part Two's genres (FakeMediaRepository): Science Fiction,
      // Drama.
      await tester.tap(find.text('Science Fiction'));
      await tester.pumpAndSettle();

      expect(find.text('Genre: sci-fi (movie)'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping Favorite rebuilds only its own action button, not the rest '
    'of the screen (CLAUDE.md rule 9)',
    (tester) async {
      await openDuneDetail(tester);

      final captured = <String>[];
      final originalDebugPrint = debugPrint;
      debugPrintRebuildDirtyWidgets = true;
      debugPrint = (message, {wrapWidth}) {
        if (message != null) captured.add(message);
      };
      try {
        await tester.tap(find.text('Favorite'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
      } finally {
        debugPrintRebuildDirtyWidgets = false;
        debugPrint = originalDebugPrint;
      }

      bool rebuilt(String widgetName) =>
          captured.any((line) => line.contains(widgetName));

      // The tap only travels through MovieActionRow's own StreamBuilder —
      // its sibling sections, the header, and the screen's Scaffold never
      // get marked dirty by it.
      expect(rebuilt('MovieActionButton'), isTrue);
      expect(rebuilt('MovieDetailHeader'), isFalse);
      expect(rebuilt('WhereToWatchSection'), isFalse);
      expect(rebuilt('MovieSynopsisSection'), isFalse);
      expect(rebuilt('MovieCastRow'), isFalse);
      expect(rebuilt('MovieSimilarSection'), isFalse);
      expect(rebuilt('CustomScrollView'), isFalse);
    },
  );
}
