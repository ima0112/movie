import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/app.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/app/router.dart';
import 'package:movies/core/config/feature_flags.dart';
import 'package:movies/core/data/local/in_memory_onboarding_repository.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/data/local/in_memory_user_profile_repository.dart';
import 'package:movies/core/domain/repositories/onboarding_repository.dart';
import 'package:movies/core/domain/repositories/taste_profile_repository.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/core/domain/repositories/user_profile_repository.dart';
import 'package:movies/features/match_hub/presentation/widgets/match_hub_sheet.dart';
import 'package:movies/features/suggestion/presentation/screens/choose_type_screen.dart';
import 'package:movies/shared/widgets/match_fab.dart';

/// While the Match hub is off (`matchHubEnabled`), the bottom bar's Match button
/// goes straight to Surprise me's first screen (E1) — no sheet in between.
void main() {
  setUpAll(() {
    configureDependencies(fake.name);
    getIt.unregister<UserLibraryRepository>();
    getIt.registerLazySingleton<UserLibraryRepository>(
      InMemoryUserLibraryRepository.new,
    );
    getIt.unregister<UserProfileRepository>();
    getIt.registerLazySingleton<UserProfileRepository>(
      InMemoryUserProfileRepository.new,
    );
    getIt.unregister<TasteProfileRepository>();
    getIt.registerLazySingleton<TasteProfileRepository>(
      InMemoryTasteProfileRepository.new,
    );
    getIt.unregister<OnboardingRepository>();
    getIt.registerLazySingleton<OnboardingRepository>(
      () => InMemoryOnboardingRepository(isCompleted: true),
    );
  });

  test('the hub is off in this version', () {
    expect(matchHubEnabled, isFalse);
  });

  testWidgets('the Match button opens E1 directly, with no sheet', (
    tester,
  ) async {
    appRouter.go('/');
    await tester.pumpWidget(const PickMeApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(MatchFab));
    await tester.pumpAndSettle();

    expect(find.byType(ChooseTypeScreen), findsOneWidget);
    expect(find.byType(MatchHubSheet), findsNothing);
    expect(find.text('What are you in the mood for today?'), findsOneWidget);
  });

  testWidgets('the button reads as "Surprise me" to a screen reader while '
      'the hub is off', (tester) async {
    appRouter.go('/');
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(const PickMeApp());
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Surprise me'), findsWidgets);
    expect(find.bySemanticsLabel('Surprise me and match'), findsNothing);
    handle.dispose();
  });

  testWidgets('going back from E1 returns to where the user was', (
    tester,
  ) async {
    appRouter.go('/');
    await tester.pumpWidget(const PickMeApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(MatchFab));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(ChooseTypeScreen), findsOneWidget);
    appRouter.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(ChooseTypeScreen), findsNothing);
    expect(find.byType(MatchFab), findsOneWidget);
  });
}
