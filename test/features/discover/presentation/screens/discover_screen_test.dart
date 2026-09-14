import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/di.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/features/discover/presentation/screens/discover_screen.dart';

void main() {
  setUpAll(configureDependencies);

  Future<void> pumpDiscoverScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: const DiscoverScreen()),
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

  testWidgets('switching segments loads that segment\'s data', (
    tester,
  ) async {
    await pumpDiscoverScreen(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Movies'));
    // The segmented control itself updates before the load resolves.
    await tester.pump();
    await tester.pumpAndSettle();

    // The section is below the fold (after the full-height hero) — the
    // ListView only builds what's currently visible, so scroll to it.
    await tester.scrollUntilVisible(
      find.text('In theaters'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('In theaters'), findsOneWidget);
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
    final unsavedCountBefore = find.byIcon(AppIcons.watchLater).evaluate().length;

    await tester.tap(find.byIcon(AppIcons.watchLater).first);
    await tester.pump();

    // Exactly the tapped one flips to filled/saved — the rest stay put.
    expect(find.byIcon(AppIcons.watchLaterFill), findsOneWidget);
    expect(
      find.byIcon(AppIcons.watchLater).evaluate().length,
      unsavedCountBefore - 1,
    );

    // Untouched content around it, e.g. the hero title, is unaffected.
    expect(find.text('Dune: Part Two'), findsOneWidget);
  });
}
