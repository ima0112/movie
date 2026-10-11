import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/app.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/core/data/local/in_memory_onboarding_repository.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/repositories/onboarding_repository.dart';
import 'package:movies/core/domain/repositories/taste_profile_repository.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';

void main() {
  setUpAll(() {
    configureDependencies(fake.name);
    // The real DriftOnboardingRepository/DriftUserLibraryRepository/
    // DriftTasteProfileRepository need a native sqlite file via
    // path_provider, which has no platform channel in `flutter test`'s
    // host environment — swap in the fast, in-memory test doubles.
    // `isCompleted: true` (the default) since this test is about
    // Discover, not the onboarding gate itself — see
    // onboarding_redirect_test.dart for that. Discover's own
    // RecommendationsCubit is what now resolves the other two, on
    // every load.
    getIt.unregister<OnboardingRepository>();
    getIt.registerLazySingleton<OnboardingRepository>(
      InMemoryOnboardingRepository.new,
    );
    getIt.unregister<UserLibraryRepository>();
    getIt.registerLazySingleton<UserLibraryRepository>(
      InMemoryUserLibraryRepository.new,
    );
    getIt.unregister<TasteProfileRepository>();
    getIt.registerLazySingleton<TasteProfileRepository>(
      InMemoryTasteProfileRepository.new,
    );
  });

  testWidgets('App boots into Discover (/) via the router', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PakoTvApp());
    await tester.pumpAndSettle();

    expect(find.text('PakoTV'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
  });
}
