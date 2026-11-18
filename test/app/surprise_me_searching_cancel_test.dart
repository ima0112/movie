import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/di.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/taste_profile.dart';
import 'package:movies/core/domain/repositories/taste_profile_repository.dart';

import 'surprise_me_test_helpers.dart';

/// E3a: "Use my tastes" shows the shuffling screen at once; its "×" cancels
/// the search and goes back one step, to E1, where picking a type works
/// again. (One scenario per file — see `surprise_me_test_helpers.dart`.)
void main() {
  setUpAll(configureSurpriseMeDependencies);

  testWidgets('the searching screen appears, "×" returns to E1 and a second '
      'pick still routes', (tester) async {
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
    await tester.tap(find.text('Use my tastes'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Shuffling your 5 surprises'), findsOneWidget);
    expect(find.text('SURPRISE ME'), findsOneWidget);
    expect(find.text('?'), findsNWidgets(5));

    await tester.tap(find.byIcon(AppIcons.close).first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('What are you in the mood for today?'), findsOneWidget);
    expect(find.text('Shuffling your 5 surprises'), findsNothing);

    // The cancelled search never lands on screen, even long after.
    await tester.pump(const Duration(seconds: 9));

    // Picking again opens H11 again.
    await tester.tap(find.text('A movie'));
    await tester.pumpAndSettle();
    expect(find.text('Find something to watch'), findsOneWidget);
  });
}
