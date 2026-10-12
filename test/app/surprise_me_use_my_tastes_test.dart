import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/di.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/taste_profile.dart';
import 'package:movies/core/domain/repositories/taste_profile_repository.dart';

import 'surprise_me_test_helpers.dart';

/// See `surprise_me_test_helpers.dart`'s own doc comment for why this
/// scenario — and each of its 3 siblings — gets its own file.
///
/// This is the exact path both of this session's real crashes came
/// from: `getIt<MatchEngine>()`'s own real construction ("GetIt:
/// Object/factory with type Random is not registered") and H11's
/// `showModalBottomSheet` ("Could not find the correct
/// Provider&lt;SurpriseCubit&gt;").
void main() {
  setUpAll(configureSurpriseMeDependencies);

  testWidgets(
    'a usable taste profile: picking a type opens H11, and "Use my '
    'tastes" reaches a real result',
    (tester) async {
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

      expect(find.text('Find something to watch'), findsOneWidget);
      expect(find.text('Use my tastes'), findsOneWidget);

      await tester.tap(find.text('Use my tastes'));
      await settleSearch(tester);

      expectOnSurpriseResultScreen();
      expect(find.text('Based on your tastes'), findsOneWidget);
    },
  );
}
