import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_icons.dart';

import 'surprise_me_test_helpers.dart';

/// E1 → a type → the quiz → back: the two cards must answer again (picking a
/// type again reaches the quiz again, and picking the other one too).
/// (One scenario per file — see `surprise_me_test_helpers.dart`.)
void main() {
  setUpAll(configureSurpriseMeDependencies);

  testWidgets('after going back from the quiz, a card can be picked again', (
    tester,
  ) async {
    await pumpSurpriseMe(tester);

    await tester.tap(find.text('A movie'));
    await tester.pumpAndSettle();
    expect(find.text('Continue'), findsOneWidget); // the quiz

    await tester.tap(find.byIcon(AppIcons.back));
    await tester.pumpAndSettle();
    expect(find.text('What are you in the mood for today?'), findsOneWidget);

    await tester.tap(find.text('A movie'));
    await tester.pumpAndSettle();
    expect(find.text('Continue'), findsOneWidget, reason: 'movie, again');

    await tester.tap(find.byIcon(AppIcons.back));
    await tester.pumpAndSettle();

    await tester.tap(find.text('A TV show'));
    await tester.pumpAndSettle();
    expect(find.text('Continue'), findsOneWidget, reason: 'TV show');
  });
}
