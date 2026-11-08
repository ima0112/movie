import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/onboarding/presentation/widgets/genre_step.dart';

/// CLAUDE.md rule 14's own checklist, enforced for this step: "Step X
/// of 3"/"Skip" under the notch, the pill button above the home
/// indicator, no RenderFlex overflow — with or without a keyboard
/// (this step has no text field, but the same MediaQuery the task asks
/// for is simulated regardless, for parity with name_step_test.dart).
Widget _wrap(Widget child) {
  return MaterialApp(
    home: MediaQuery(
      data: const MediaQueryData(
        size: Size(390, 844),
        padding: EdgeInsets.only(top: 47, bottom: 34),
        viewInsets: EdgeInsets.only(bottom: 300),
      ),
      child: child,
    ),
  );
}

void main() {
  testWidgets(
    'GenreStep (step 2) survives a notch + home indicator + open '
    'keyboard with no RenderFlex overflow, and the header/button are '
    'both on screen',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          GenreStep(
            stepLabel: 'Step 2 of 3',
            headline: 'What genres do you like?',
            selected: const {},
            onToggle: (_) {},
            onSkip: () {},
            nextLabel: 'Next',
            onNext: () {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Step 2 of 3'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    },
  );

  testWidgets(
    'GenreStep (step 3) survives the same constraints with disabled '
    'genres rendered',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          GenreStep(
            stepLabel: 'Step 3 of 3',
            headline: 'And which ones never?',
            highlightWord: 'never',
            selected: const {},
            onToggle: (_) {},
            onSkip: () {},
            nextLabel: 'Done',
            onNext: () {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Step 3 of 3'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    },
  );
}
