import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/di.dart';
import 'package:movies/core/domain/repositories/local_flags_repository.dart';

import 'surprise_me_test_helpers.dart';

/// The first time the deck opens, the 3-step tour shows over it; "Skip" ends it
/// and counts as seen. (One scenario per file — see
/// `surprise_me_test_helpers.dart`.)
void main() {
  setUpAll(() => configureSurpriseMeDependencies(tourSeen: false));

  testWidgets('the tour shows once; skipping it counts as seen', (
    tester,
  ) async {
    await pumpSurpriseMe(tester);
    await tester.tap(find.text('A movie'));
    await tester.pumpAndSettle();
    await completeQuiz(tester, settle: false);
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Swipe to pass a card'), findsOneWidget);
    expect(
      await getIt<LocalFlagsRepository>().isSet(LocalFlag.surpriseTourSeen),
      isFalse,
    );

    await tester.tap(find.text('Skip'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Swipe to pass a card'), findsNothing);
    expect(
      await getIt<LocalFlagsRepository>().isSet(LocalFlag.surpriseTourSeen),
      isTrue,
    );
    expect(find.text('Ask for another 5'), findsOneWidget);
  });
}
