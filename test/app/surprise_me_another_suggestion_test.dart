import 'package:flutter_test/flutter_test.dart';

import 'surprise_me_test_helpers.dart';

/// See `surprise_me_test_helpers.dart`'s own doc comment for why this
/// scenario — and each of its 3 siblings — gets its own file.
void main() {
  setUpAll(configureSurpriseMeDependencies);

  testWidgets('"Ask for another 5" searches again and comes back to a deck', (
    tester,
  ) async {
    await pumpSurpriseMe(tester);
    await tester.tap(find.text('A movie'));
    await tester.pumpAndSettle();
    await completeQuiz(tester);
    expectOnSurpriseResultScreen();

    await tester.tap(find.text('Ask for another 5'));
    await settleSearch(tester);

    expectOnSurpriseResultScreen();
  });
}
