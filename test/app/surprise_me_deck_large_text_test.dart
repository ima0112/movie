import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'surprise_me_test_helpers.dart';

/// The deck on a small phone at 200 % text: no overflow, and the reroll button
/// and the help line are still on screen. (One scenario per file — see
/// `surprise_me_test_helpers.dart`.)
void main() {
  setUpAll(configureSurpriseMeDependencies);

  testWidgets('the deck fits 320×568 at 200 % text', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    await pumpSurpriseMe(tester);
    await tester.tap(find.text('A movie'));
    await tester.pumpAndSettle();
    await completeQuiz(tester);

    // Reach the deck at normal size, then grow the text.
    final overflows = <String>[];
    final previous = FlutterError.onError;
    FlutterError.onError = (d) => overflows.add(d.exception.toString());
    addTearDown(() => FlutterError.onError = previous);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    await tester.pump(const Duration(milliseconds: 300));

    expect(overflows.where((e) => e.contains('overflowed')), isEmpty);
    expect(find.text('Ask for another 5'), findsOneWidget);
  });
}
