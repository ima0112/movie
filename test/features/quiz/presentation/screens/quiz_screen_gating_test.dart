import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/theme/app_icons.dart';
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
  testWidgets('every step is optional; the vibes take at most three; going '
      'back clears the step you leave', (tester) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();
    const step0 = 'Where should it come from?';
    const step1 = 'What are you NOT in the mood for today?';
    const step2 = 'Which vibes are you in the mood for today?';
    expect(find.text(step0), findsOneWidget);

    // Continue is on from the start, on every step.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text(step1), findsOneWidget);
    await tester.tap(find.text('Continue')); // no genre skipped
    await tester.pumpAndSettle();
    expect(find.text(step2), findsOneWidget);

    // Pick four vibes: only three count.
    final chips = find.byType(AppChip);
    for (var i = 0; i < 4; i++) {
      await tester.tap(chips.at(i));
      await tester.pump();
    }
    List<AppChip> filled() => tester
        .widgetList<AppChip>(find.byType(AppChip))
        .where((c) => c.state == ChipState.solid)
        .toList();
    expect(filled(), hasLength(3));

    // Back to the genres and forward again: the vibes were cleared.
    await tester.tap(find.byIcon(AppIcons.back));
    await tester.pumpAndSettle();
    expect(find.text(step1), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text(step2), findsOneWidget);
    expect(filled(), isEmpty);
  });
}
