import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/di.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/taste_profile.dart';
import 'package:movies/core/domain/repositories/taste_profile_repository.dart';
import 'package:movies/core/theme/app_icons.dart';

import 'surprise_me_test_helpers.dart';

/// With tastes saved: E1 → a type → H11 → "Answer the quiz instead" → the quiz
/// → back: the cards answer again and H11 opens again.
/// (One scenario per file — see `surprise_me_test_helpers.dart`.)
void main() {
  setUpAll(configureSurpriseMeDependencies);

  testWidgets('back from the quiz reached through H11, a card works again', (
    tester,
  ) async {
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
    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.byIcon(AppIcons.back));
    await tester.pumpAndSettle();

    await tester.tap(find.text('A TV show'));
    await tester.pumpAndSettle();
    expect(find.text('Find something to watch'), findsOneWidget);
  });
}
