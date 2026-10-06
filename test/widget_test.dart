import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/app.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/core/data/local/in_memory_onboarding_repository.dart';
import 'package:movies/core/domain/repositories/onboarding_repository.dart';

void main() {
  setUpAll(() {
    configureDependencies(fake.name);
    // The real DriftOnboardingRepository needs a native sqlite file via
    // path_provider, which has no platform channel in `flutter test`'s
    // host environment — same swap as UserLibraryRepository elsewhere.
    // `isCompleted: true` (the default) since this test is about
    // Discover, not the onboarding gate itself — see
    // onboarding_redirect_test.dart for that.
    getIt.unregister<OnboardingRepository>();
    getIt.registerLazySingleton<OnboardingRepository>(
      InMemoryOnboardingRepository.new,
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
