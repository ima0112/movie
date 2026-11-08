import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/app.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/app/router.dart';
import 'package:movies/core/data/local/in_memory_onboarding_repository.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/data/local/in_memory_user_profile_repository.dart';
import 'package:movies/core/domain/repositories/onboarding_repository.dart';
import 'package:movies/core/domain/repositories/taste_profile_repository.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/core/domain/repositories/user_profile_repository.dart';

void main() {
  late InMemoryOnboardingRepository onboardingRepository;

  setUpAll(() {
    configureDependencies(fake.name);
    getIt.unregister<UserLibraryRepository>();
    getIt.registerLazySingleton<UserLibraryRepository>(
      InMemoryUserLibraryRepository.new,
    );
    // The last test below walks OnboardingCubit.finish(), which saves
    // through the real, global UserProfileCubit/TasteProfileCubit —
    // those two also need the same native-sqlite swap.
    getIt.unregister<UserProfileRepository>();
    getIt.registerLazySingleton<UserProfileRepository>(
      InMemoryUserProfileRepository.new,
    );
    getIt.unregister<TasteProfileRepository>();
    getIt.registerLazySingleton<TasteProfileRepository>(
      InMemoryTasteProfileRepository.new,
    );

    // One instance, mutated directly between tests below — simpler
    // than re-registering a fresh one each time, and
    // `registerLazySingleton` would just cache the first one anyway.
    onboardingRepository = InMemoryOnboardingRepository(isCompleted: false);
    getIt.unregister<OnboardingRepository>();
    getIt.registerLazySingleton<OnboardingRepository>(
      () => onboardingRepository,
    );
  });

  testWidgets('without the flag, any route redirects to /welcome', (
    tester,
  ) async {
    onboardingRepository.isCompleted = false;
    appRouter.go('/explore');
    await tester.pumpWidget(const PakoTvApp());
    // Not pumpAndSettle: the welcome step's poster wall drifts on an
    // endlessly repeating AnimationController by design, which never
    // settles.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text("Hi, I'm Pako"), findsOneWidget);
    expect(find.text('Explore'), findsNothing);
  });

  testWidgets(
    'with the flag, /welcome redirects to Discover instead of showing '
    'it again',
    (tester) async {
      onboardingRepository.isCompleted = true;
      appRouter.go('/welcome');
      await tester.pumpWidget(const PakoTvApp());
      await tester.pumpAndSettle();

      expect(find.text('Dune: Part Two'), findsOneWidget);
      expect(find.text("Hi, I'm Pako"), findsNothing);
    },
  );

  testWidgets('with the flag, a normal route is left alone', (tester) async {
    onboardingRepository.isCompleted = true;
    appRouter.go('/');
    await tester.pumpWidget(const PakoTvApp());
    await tester.pumpAndSettle();

    expect(find.text('Dune: Part Two'), findsOneWidget);
  });

  testWidgets('walking the real flow (name, skip both genre steps) marks '
      'onboarding completed and reaches Discover', (tester) async {
    onboardingRepository.isCompleted = false;
    appRouter.go('/');
    await tester.pumpWidget(const PakoTvApp());
    // Not pumpAndSettle here either — see the first test's own note.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text("Hi, I'm Pako"), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Dani');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Step 2 of 3'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Step 3 of 3'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Dune: Part Two'), findsOneWidget);
    expect(onboardingRepository.isCompleted, isTrue);
  });
}
