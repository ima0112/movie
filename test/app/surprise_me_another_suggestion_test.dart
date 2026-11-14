import 'package:flutter_test/flutter_test.dart';

import 'surprise_me_test_helpers.dart';

/// See `surprise_me_test_helpers.dart`'s own doc comment for why this
/// scenario — and each of its 3 siblings — gets its own file.
void main() {
  setUpAll(configureSurpriseMeDependencies);

  testWidgets('"Another suggestion" rotates without crashing', (tester) async {
    await pumpSurpriseMe(tester);
    await tester.tap(find.text('A movie'));
    await tester.pumpAndSettle();
    await completeQuiz(tester);
    expectOnSurpriseResultScreen();

    await tester.ensureVisible(find.text('Another suggestion'));
    await tester.tap(find.text('Another suggestion'));
    await tester.pumpAndSettle();

    expectOnSurpriseResultScreen();
  });
}
