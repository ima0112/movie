import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/di.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/domain/repositories/taste_profile_repository.dart';

import 'surprise_me_test_helpers.dart';

/// See `surprise_me_test_helpers.dart`'s own doc comment for why this
/// scenario — and each of its 3 siblings — gets its own file.
void main() {
  setUpAll(configureSurpriseMeDependencies);

  testWidgets('no taste profile and an empty library: picking a type goes '
      'straight to the quiz, which ends on a real result', (tester) async {
    expect(
      await (getIt<TasteProfileRepository>() as InMemoryTasteProfileRepository)
          .watch()
          .first,
      isNull,
    );

    await pumpSurpriseMe(tester);

    await tester.tap(find.text('A movie'));
    await tester.pumpAndSettle();

    // No usable signal at all -> NeedsQuiz directly, no H11.
    expect(find.text('Find something to watch'), findsNothing);
    await completeQuiz(tester);

    expectOnSurpriseResultScreen();
  });
}
