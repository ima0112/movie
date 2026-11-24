
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/app.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/app/router.dart';
import 'package:movies/core/data/local/in_memory_onboarding_repository.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/data/local/in_memory_user_profile_repository.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/repositories/onboarding_repository.dart';
import 'package:movies/core/domain/repositories/taste_profile_repository.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/core/domain/repositories/user_profile_repository.dart';
import 'package:movies/core/launch/app_link.dart';
import 'package:movies/features/movie_detail/presentation/screens/movie_detail_screen.dart';
import 'package:movies/features/tv_detail/presentation/screens/tv_detail_screen.dart';
import 'package:movies/shared/widgets/media_detail/media_detail_compact_bar.dart';

/// A link into the app (`pakotv://app/movie/1`), as the system delivers it:
/// opens the title over Home; before the onboarding is done it waits for it;
/// a garbled one lands on Home.
void main() {
  late InMemoryOnboardingRepository onboarding;

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
    onboarding = InMemoryOnboardingRepository(isCompleted: true);
    getIt.unregister<OnboardingRepository>();
    getIt.registerLazySingleton<OnboardingRepository>(() => onboarding);
  });

  /// What the platform does when a link arrives while the app is open.
  Future<void> receive(WidgetTester tester, String link) async {
    final message = const JSONMethodCodec().encodeMethodCall(
      MethodCall('pushRouteInformation', {'location': link}),
    );
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/navigation',
      message,
      (_) {},
    );
  }

  Future<void> startOnHome(WidgetTester tester) async {
    onboarding.isCompleted = true;
    appRouter.go('/');
    await tester.pumpWidget(const PakoTvApp());
    await tester.pumpAndSettle();
    expect(find.text('Dune: Part Two'), findsOneWidget);
  }

  testWidgets('a movie link opens its detail over Home: back lands on Home', (
    tester,
  ) async {
    await startOnHome(tester);

    await receive(
      tester,
      appLinkFor(const MediaKey(type: MediaType.movie, tmdbId: 1)).toString(),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MovieDetailScreen), findsOneWidget);

    appRouter.pop();
    await tester.pumpAndSettle();
    expect(find.byType(MovieDetailScreen), findsNothing);
    expect(find.text('Dune: Part Two'), findsOneWidget); // Home underneath
  });

  testWidgets('a TV link opens a show\'s detail', (tester) async {
    await startOnHome(tester);

    await receive(tester, 'pakotv://app/tv/101');
    await tester.pumpAndSettle();

    expect(find.byType(TvDetailScreen), findsOneWidget);
  });

  testWidgets('a garbled link lands on Home and throws nothing', (
    tester,
  ) async {
    for (final link in [
      'pakotv://app/foo',
      'pakotv://app/movie/abc',
      'pakotv://app/movie',
      'pakotv://movie/603',
      'pakotv://app/',
    ]) {
      await startOnHome(tester);
      await receive(tester, link);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: link);
      expect(find.byType(MovieDetailScreen), findsNothing, reason: link);
      expect(find.text('Dune: Part Two'), findsOneWidget, reason: link);
    }
  });

  testWidgets('an in-app route with a bad id goes Home too', (tester) async {
    await startOnHome(tester);

    appRouter.go('/movie/abc');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(MovieDetailScreen), findsNothing);
    expect(find.text('Dune: Part Two'), findsOneWidget);
  });

  testWidgets('before the onboarding is done the link waits, and opens the '
      'title when it ends', (tester) async {
    onboarding.isCompleted = false;
    appRouter.go('/');
    await tester.pumpWidget(const PakoTvApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Get started'), findsOneWidget);

    await receive(tester, 'pakotv://app/movie/1');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    // Still the onboarding, the link kept on the welcome route.
    expect(find.text('Get started'), findsOneWidget);
    expect(find.byType(MovieDetailScreen), findsNothing);
    expect(
      appRouter.state.uri.queryParameters[AppRoutes.welcomeNextParam],
      '/detail/movie/1',
    );

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Dani');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(onboarding.isCompleted, isTrue);
    expect(find.byType(MovieDetailScreen), findsOneWidget);
    expect(find.byType(MediaDetailCompactBar), findsNothing);

    appRouter.pop();
    await tester.pumpAndSettle();
    expect(find.text('Dune: Part Two'), findsOneWidget); // Home underneath
  });

  test('the welcome route takes only a title\'s detail over Home as '
      '"next"', () {
    expect(
      AppRoutes.mediaKeyOfHomeDetail('/detail/movie/603'),
      const MediaKey(type: MediaType.movie, tmdbId: 603),
    );
    expect(
      AppRoutes.mediaKeyOfHomeDetail('/detail/tv/1396'),
      const MediaKey(type: MediaType.tvShow, tmdbId: 1396),
    );
    for (final bad in [
      '/settings',
      'https://evil.example/detail/movie/1',
      '/detail/movie/abc',
      '/detail/person/1',
      '/detail/movie/1/extra',
      '/detail/movie/-1',
      '',
    ]) {
      expect(AppRoutes.mediaKeyOfHomeDetail(bad), isNull, reason: bad);
    }
    expect(
      AppRoutes.welcomeThen('/detail/movie/603'),
      '/welcome?next=%2Fdetail%2Fmovie%2F603',
    );
  });
}
