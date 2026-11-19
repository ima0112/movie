import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/app_chip.dart';

Widget _host() => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: QuizScreen(mediaType: MediaType.movie, onComplete: (_) {}),
);

/// E2's genre and vibe steps need at least one pick (and take at most three) before
/// "Continue" moves on.
void main() {
  // One scenario in one test: a second pumped QuizScreen in the same process
  // hangs `pumpAndSettle` (see `test/app/surprise_me_test_helpers.dart`).
  testWidgets(
    'the collections step is optional; the genre and vibe steps: Continue waits for a pick; the vibes take at '
    'most three',
    (tester) async {
      await tester.pumpWidget(_host());
      await tester.pumpAndSettle();
      const step0 = 'Where should it come from?';
      const step1 = 'What are you NOT in the mood for today?';
      const step2 = 'Which vibes are you in the mood for today?';
      // The collections step is optional: Continue is on right away.
      expect(find.text(step0), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text(step1), findsOneWidget);

      // Step 1: nothing picked, nothing happens.
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text(step1), findsOneWidget, reason: 'no genre picked yet');

      await tester.tap(find.byType(AppChip).first);
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text(step2), findsOneWidget);

      // Step 2: same rule.
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text(step2), findsOneWidget, reason: 'no vibe picked yet');

      // Pick four: only three count.
      final chips = find.byType(AppChip);
      for (var i = 0; i < 4; i++) {
        await tester.tap(chips.at(i));
        await tester.pump();
      }
      final filled = tester
          .widgetList<AppChip>(find.byType(AppChip))
          .where((c) => c.state == ChipState.solid);
      expect(filled, hasLength(3));
    },
  );
}
