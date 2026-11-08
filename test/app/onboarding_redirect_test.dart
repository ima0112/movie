import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/app.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/app/router.dart';
import 'package:movies/core/data/local/in_memory_onboarding_repository.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/repositories/onboarding_repository.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';

void main() {
  late InMemoryOnboardingRepository onboardingRepository;

  setUpAll(() {
    configureDependencies(fake.name);
    getIt.unregister<UserLibraryRepository>();
    getIt.registerLazySingleton<UserLibraryRepository>(
      InMemoryUserLibraryRepository.new,
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
    await tester.pumpAndSettle();

    expect(find.text('Skip for now (placeholder)'), findsOneWidget);
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
      expect(find.text('Skip for now (placeholder)'), findsNothing);
    },
  );

  testWidgets('with the flag, a normal route is left alone', (tester) async {
    onboardingRepository.isCompleted = true;
    appRouter.go('/');
    await tester.pumpWidget(const PakoTvApp());
    await tester.pumpAndSettle();

    expect(find.text('Dune: Part Two'), findsOneWidget);
  });

  testWidgets("the placeholder's own skip action marks onboarding complete and "
      'reaches Discover', (tester) async {
    onboardingRepository.isCompleted = false;
    appRouter.go('/');
    await tester.pumpWidget(const PakoTvApp());
    await tester.pumpAndSettle();
    expect(find.text('Skip for now (placeholder)'), findsOneWidget);

    await tester.tap(find.text('Skip for now (placeholder)'));
    await tester.pumpAndSettle();

    expect(find.text('Dune: Part Two'), findsOneWidget);
    expect(onboardingRepository.isCompleted, isTrue);
  });
}
