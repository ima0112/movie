import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/di.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/taste_profile.dart';
import 'package:movies/core/domain/repositories/taste_profile_repository.dart';

import 'surprise_me_test_helpers.dart';

/// See `surprise_me_test_helpers.dart`'s own doc comment for why this
/// scenario — and each of its 3 siblings — gets its own file.
void main() {
  setUpAll(configureSurpriseMeDependencies);

  testWidgets('a usable taste profile: "Answer the quiz instead" from H11 '
      'reaches the quiz, which still ends on a real result', (tester) async {
    await (getIt<TasteProfileRepository>() as InMemoryTasteProfileRepository)
        .save(
          TasteProfile(
            likedGenres: {const Genre(id: 'action')},
            vetoedGenres: const {},
            likedVibes: const {},
            yearFrom: 1990,
            updatedAt: DateTime(2024),
          ),
        );

    await pumpSurpriseMe(tester);

    await tester.tap(find.text('A movie'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Answer the quiz instead'));
    await tester.pumpAndSettle();

    await completeQuiz(tester);

    expectOnSurpriseResultScreen();
    expect(find.text('Based on your answers'), findsOneWidget);
  });
}
