import 'package:flutter_test/flutter_test.dart';

import 'surprise_me_test_helpers.dart';

/// With a screen reader on, the deck shows Save / Choose this / Next as real
/// buttons (and no "double-tap" line); Choose this ends on the closing screen.
/// (One scenario per file — see `surprise_me_test_helpers.dart`.)
void main() {
  setUpAll(configureSurpriseMeDependencies);

  testWidgets('accessible navigation shows the visible controls', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(accessibleNavigation: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await pumpSurpriseMe(tester);
    await tester.tap(find.text('A movie'));
    await tester.pumpAndSettle();
    await completeQuiz(tester);

    expect(find.text('Choose this'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Double-tap to choose'), findsNothing);

    await tester.tap(find.text('Next'));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Choose this'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('YOUR SURPRISE OF THE DAY'), findsOneWidget);
  });
}
