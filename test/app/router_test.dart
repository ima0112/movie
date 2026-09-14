import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/app.dart';
import 'package:movies/app/di.dart';
import 'package:movies/shared/widgets/media_card.dart';

void main() {
  setUpAll(configureDependencies);

  testWidgets('the four tabs navigate, and switching back to Discover '
      'keeps its already-loaded state instead of reloading from scratch', (
    tester,
  ) async {
    await tester.pumpWidget(const PakoTvApp());
    await tester.pumpAndSettle();

    // Discover (/) loaded.
    expect(find.text('Dune: Part Two'), findsOneWidget);

    // Explore (/explore) — placeholder.
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

    // FakeMediaRepository's "Dune: Part Two" has id 1.
    await tester.tap(find.text('Dune: Part Two'));
    await tester.pumpAndSettle();
    expect(find.text('Movie 1'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
    // The pushed detail hides the tab bar — a pushed screen per
    // docs/SCREENS.md ("every pushed screen... hides the bottom bar").
    expect(find.text('Discover'), findsNothing);

    await tester.tap(find.byType(BackButton));
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
      final carouselCard = find.byWidgetPredicate(
        (widget) => widget is MediaCard && widget.size == MediaCardSize.carousel,
      );
      expect(carouselCard, findsWidgets);
      await tester.tap(carouselCard.first);
      await tester.pumpAndSettle();
      expect(find.textContaining('Movie '), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      final scrollOffsetAfter = tester
          .state<ScrollableState>(scrollable)
          .position
          .pixels;
      expect(scrollOffsetAfter, scrollOffsetBefore);
    },
  );
}
