import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_suggestion_card.dart';

import 'surprise_me_test_helpers.dart';

/// The deck's whole game: answer the quiz, double-tap the card on top, and the
/// closing screen shows it in Watch later. (One scenario per file — see
/// `surprise_me_test_helpers.dart`.)
void main() {
  setUpAll(configureSurpriseMeDependencies);

  testWidgets(
    'double-tapping the top card ends on "Your surprise of the day"',
    (tester) async {
      await pumpSurpriseMe(tester);
      await tester.tap(find.text('A movie'));
      await tester.pumpAndSettle();
      await completeQuiz(tester);
      expectOnSurpriseResultScreen();
      expect(find.text('YOUR SURPRISE OF THE DAY'), findsNothing);

      final card = find.byType(SurpriseSuggestionCard).last;
      await tester.tap(card);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(card);
      // (The sparkles twinkle forever: no pumpAndSettle on the closing screen.)
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('YOUR SURPRISE OF THE DAY'), findsOneWidget);
      expect(find.text('In Watch later'), findsOneWidget);
      expect(find.text('Ask for another 5'), findsNothing);
      expect(find.byType(Scaffold), findsOneWidget);
    },
  );
}
