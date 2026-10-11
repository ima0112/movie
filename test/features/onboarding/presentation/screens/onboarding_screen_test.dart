import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/app.dart';
import 'package:movies/app/cubits/taste_profile_cubit.dart';
import 'package:movies/app/cubits/user_profile_cubit.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/app/router.dart';
import 'package:movies/core/data/local/in_memory_onboarding_repository.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/data/local/in_memory_user_profile_repository.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/season_summary.dart';
import 'package:movies/core/domain/repositories/media_repository.dart';
import 'package:movies/core/domain/repositories/onboarding_repository.dart';
import 'package:movies/core/domain/repositories/taste_profile_repository.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/core/domain/repositories/user_profile_repository.dart';
import 'package:movies/features/onboarding/presentation/widgets/poster_wall.dart';

/// Only `getPosterWallItems` matters for these tests (the welcome
/// step's own poster fetch) — every other method is unreachable from
/// what's pumped here, so it's left unimplemented rather than faked out
/// in full, same as other narrow test doubles this app already has.
class _FailingMediaRepository implements MediaRepository {
  @override
  Future<Result<List<MediaItem>>> getPosterWallItems() async =>
      const Failure(FailureReason.network);

  @override
  Future<Result<List<MediaItem>>> getCarouselSection(
    CarouselSection section, {
    MediaType? type,
  }) => throw UnimplementedError();

  @override
  Future<Result<List<MediaItem>>> recommendationsFor(MediaKey seed) =>
      throw UnimplementedError();

  @override
  Future<Result<List<MediaItem>>> getHeroItems({MediaType? type}) =>
      throw UnimplementedError();

  @override
  Future<Result<MediaDetail>> detail(MediaKey key) =>
      throw UnimplementedError();

  @override
  Future<Result<SeasonDetail>> season(int tvId, int seasonNumber) =>
      throw UnimplementedError();

  @override
  Future<Result<List<MediaItem>>> searchMulti(String query) =>
      throw UnimplementedError();

  @override
  Future<Result<List<MediaItem>>> discover(DiscoverFilter filter) =>
      throw UnimplementedError();
}

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
  });

  setUp(() {
    getIt.unregister<OnboardingRepository>();
    getIt.registerLazySingleton<OnboardingRepository>(
      () => InMemoryOnboardingRepository(isCompleted: false),
    );
  });

  testWidgets('picking a genre then finishing shows the "Tastes saved" '
      'snackbar and actually persists a TasteProfile', (tester) async {
    appRouter.go('/');
    await tester.pumpWidget(const PakoTvApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Dani');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Step 2 of 3'), findsOneWidget);
    await tester.tap(find.text('Action').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Step 3 of 3'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pump();

    expect(find.text('Tastes saved · Edit in You'), findsOneWidget);

    final savedTastes = getIt<TasteProfileRepository>();
    final profile = await savedTastes.watch().first;
    expect(profile, isNotNull);
    expect(profile!.likedGenres.map((g) => g.id), contains('action'));

    // Drains the SnackBar's own pending auto-dismiss Timer, and now
    // also Discover's own RecommendationsCubit ("For you" picked up
    // the genre just saved above) — pumpAndSettle rather than one
    // fixed-size pump, since reaching the latter's Timer takes a few
    // more microtask turns than a single pump(duration) covers.
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });

  testWidgets('a failed poster fetch on welcome (offline) falls back to '
      'placeholder tiles instead of crashing', (tester) async {
    final previousMediaRepository = getIt<MediaRepository>();
    getIt.unregister<MediaRepository>();
    getIt.registerLazySingleton<MediaRepository>(_FailingMediaRepository.new);
    addTearDown(() {
      getIt.unregister<MediaRepository>();
      getIt.registerLazySingleton<MediaRepository>(
        () => previousMediaRepository,
      );
    });

    appRouter.go('/');
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => UserProfileCubit(getIt<UserProfileRepository>()),
          ),
          BlocProvider(
            create: (_) => TasteProfileCubit(getIt<TasteProfileRepository>()),
          ),
        ],
        child: const PakoTvApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // No exception surfaced (TestWidgetsFlutterBinding would have
    // failed the test on its own if one had), welcome's own copy is
    // still there, and the poster wall renders — every tile a
    // placeholder since the fetch failed.
    expect(find.text("Hi, I'm Pako"), findsOneWidget);
    expect(find.byType(PosterWall), findsOneWidget);
  });
}
