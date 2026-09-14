import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/app.dart';
import 'package:movies/app/di.dart';

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
}
