import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_taste_profile_repository.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/entities/app_settings.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_segment.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/search_result.dart';
import 'package:movies/core/domain/entities/streaming_service.dart';
import 'package:movies/core/domain/entities/season_summary.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/core/domain/repositories/media_repository.dart';
import 'package:movies/core/domain/repositories/settings_repository.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';
import 'package:movies/features/recommendations/domain/recommendation_builder.dart';
import 'package:movies/features/recommendations/presentation/cubit/recommendations_cubit.dart';

const _dune = MediaKey(type: MediaType.movie, tmdbId: 1);
const _action = Genre(id: 'action');

Movie _movie(int id) => Movie(
  id: id,
  title: 'Movie $id',
  posterUrl: 'poster-$id',
  genres: const [_action],
  releaseDate: null,
  voteAverage: 7,
);

final _recommendationPool = List.generate(
  RecommendationBuilder.minRecommendationCount + 2,
  _movie,
);

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this._current);

  AppSettings _current;
  final controller = StreamController<AppSettings>.broadcast();

  @override
  AppSettings get current => _current;

  @override
  Future<void> load() async {}

  @override
  Stream<AppSettings> watch() async* {
    yield _current;
    yield* controller.stream;
  }

  @override
  Future<Result<void>> save(AppSettings settings) async {
    _current = settings;
    return const Success(null);
  }
}

/// Controllable, call-counting stand-in — only `discover`/
/// `recommendationsFor` matter for this Cubit.
class _FakeMediaRepository implements MediaRepository {
  int discoverCalls = 0;
  int recommendationsCalls = 0;
  Result<List<MediaItem>> discoverResult = Success(_recommendationPool);
  Result<List<MediaItem>> recommendationsResult = Success(_recommendationPool);

  @override
  Future<Result<List<MediaItem>>> discover(DiscoverFilter filter) async {
    discoverCalls++;
    return discoverResult;
  }

  @override
  Future<Result<List<MediaItem>>> recommendationsFor(MediaKey seed) async {
    recommendationsCalls++;
    return recommendationsResult;
  }

  @override
  Future<Result<List<MediaItem>>> getCarouselSection(
    CarouselSection section, {
    MediaType? type,
  }) => throw UnimplementedError();

  @override
  Future<Result<List<MediaItem>>> getHeroItems({MediaType? type}) =>
      throw UnimplementedError();

  @override
  Future<Result<List<MediaItem>>> getPosterWallItems() =>
      throw UnimplementedError();

  @override
  Future<Result<MediaDetail>> detail(MediaKey key, {String? regionCode}) =>
      throw UnimplementedError();

  @override
  Future<Result<SeasonDetail>> season(int tvId, int seasonNumber) =>
      throw UnimplementedError();

  @override
  Future<Result<List<SearchResult>>> searchMulti(String query) =>
      throw UnimplementedError();

  @override
  Future<Result<List<StreamingService>>> streamingServices({MediaType? type}) =>
      throw UnimplementedError();
}

/// Counts [refresh] calls as they happen — the settings subscription
/// calls it `unawaited`, so a test can't just count how many times
/// `await cubit.refresh()` resolved, same reasoning as
/// `discover_cubit_test.dart`'s own `_CountingDiscoverCubit`.
class _CountingRecommendationsCubit extends RecommendationsCubit {
  _CountingRecommendationsCubit(
    super.mediaRepository,
    super.userLibraryRepository,
    super.tasteProfileRepository,
    super.settingsRepository,
    super.vibeCatalog,
  );

  int refreshCount = 0;

  @override
  Future<void> refresh() {
    refreshCount++;
    return super.refresh();
  }
}

RecommendationsCubit _cubit({
  required _FakeMediaRepository mediaRepository,
  required InMemoryUserLibraryRepository userLibraryRepository,
  required InMemoryTasteProfileRepository tasteProfileRepository,
  required _FakeSettingsRepository settingsRepository,
}) {
  return RecommendationsCubit(
    mediaRepository,
    userLibraryRepository,
    tasteProfileRepository,
    settingsRepository,
    VibeCatalog(const []),
  );
}

void main() {
  group('RecommendationsCubit', () {
    test('no profile, no library signal -> both sections Hidden, no '
        'network call at all', () async {
      final mediaRepository = _FakeMediaRepository();
      final cubit = _cubit(
        mediaRepository: mediaRepository,
        userLibraryRepository: InMemoryUserLibraryRepository(),
        tasteProfileRepository: InMemoryTasteProfileRepository(),
        settingsRepository: _FakeSettingsRepository(
          const AppSettings(languageCode: 'en', regionCode: 'US'),
        ),
      );
      addTearDown(cubit.close);

      await cubit.load(MediaSegment.all);

      expect(cubit.state.forYou, isA<RecommendationSectionHidden>());
      expect(cubit.state.becauseYouLike, isA<RecommendationSectionHidden>());
      expect(mediaRepository.discoverCalls, 0);
      expect(mediaRepository.recommendationsCalls, 0);
    });

    test('a favorite entry gives both sections a real signal and loads '
        'independently', () async {
      final mediaRepository = _FakeMediaRepository();
      final userLibraryRepository = InMemoryUserLibraryRepository();
      await userLibraryRepository.upsert(
        const UserMediaEntry(
          key: _dune,
          title: 'Dune',
          isFavorite: true,
          genres: [_action],
        ),
      );
      final cubit = _cubit(
        mediaRepository: mediaRepository,
        userLibraryRepository: userLibraryRepository,
        tasteProfileRepository: InMemoryTasteProfileRepository(),
        settingsRepository: _FakeSettingsRepository(
          const AppSettings(languageCode: 'en', regionCode: 'US'),
        ),
      );
      addTearDown(cubit.close);

      await cubit.load(MediaSegment.all);

      expect(cubit.state.forYou, isA<RecommendationSectionLoaded>());
      final becauseYouLike =
          cubit.state.becauseYouLike as RecommendationSectionLoaded;
      expect(becauseYouLike.seedTitle, 'Dune');
      expect(mediaRepository.recommendationsCalls, 1);
    });

    test('one section failing never blocks or clears the other', () async {
      final mediaRepository = _FakeMediaRepository()
        ..discoverResult = const Failure(FailureReason.network);
      final userLibraryRepository = InMemoryUserLibraryRepository();
      await userLibraryRepository.upsert(
        const UserMediaEntry(
          key: _dune,
          title: 'Dune',
          isFavorite: true,
          genres: [_action],
        ),
      );
      final cubit = _cubit(
        mediaRepository: mediaRepository,
        userLibraryRepository: userLibraryRepository,
        tasteProfileRepository: InMemoryTasteProfileRepository(),
        settingsRepository: _FakeSettingsRepository(
          const AppSettings(languageCode: 'en', regionCode: 'US'),
        ),
      );
      addTearDown(cubit.close);

      await cubit.load(MediaSegment.all);

      expect(cubit.state.forYou, isA<RecommendationSectionError>());
      expect(cubit.state.becauseYouLike, isA<RecommendationSectionLoaded>());
    });

    test('retry(forYou) re-fetches only that section', () async {
      final mediaRepository = _FakeMediaRepository()
        ..discoverResult = const Failure(FailureReason.network);
      final userLibraryRepository = InMemoryUserLibraryRepository();
      await userLibraryRepository.upsert(
        const UserMediaEntry(
          key: _dune,
          title: 'Dune',
          isFavorite: true,
          genres: [_action],
        ),
      );
      final cubit = _cubit(
        mediaRepository: mediaRepository,
        userLibraryRepository: userLibraryRepository,
        tasteProfileRepository: InMemoryTasteProfileRepository(),
        settingsRepository: _FakeSettingsRepository(
          const AppSettings(languageCode: 'en', regionCode: 'US'),
        ),
      );
      addTearDown(cubit.close);
      await cubit.load(MediaSegment.all);
      expect(cubit.state.forYou, isA<RecommendationSectionError>());
      final recommendationsCallsBefore = mediaRepository.recommendationsCalls;

      mediaRepository.discoverResult = Success(_recommendationPool);
      await cubit.retry(RecommendationSlot.forYou);

      expect(cubit.state.forYou, isA<RecommendationSectionLoaded>());
      // becauseYouLike was never touched by this retry.
      expect(mediaRepository.recommendationsCalls, recommendationsCallsBefore);
    });

    test('refresh() skips the network call when the derived request '
        "hasn't actually changed", () async {
      final mediaRepository = _FakeMediaRepository();
      final userLibraryRepository = InMemoryUserLibraryRepository();
      await userLibraryRepository.upsert(
        const UserMediaEntry(
          key: _dune,
          title: 'Dune',
          isFavorite: true,
          genres: [_action],
        ),
      );
      final cubit = _cubit(
        mediaRepository: mediaRepository,
        userLibraryRepository: userLibraryRepository,
        tasteProfileRepository: InMemoryTasteProfileRepository(),
        settingsRepository: _FakeSettingsRepository(
          const AppSettings(languageCode: 'en', regionCode: 'US'),
        ),
      );
      addTearDown(cubit.close);
      await cubit.load(MediaSegment.all);
      final discoverCallsAfterLoad = mediaRepository.discoverCalls;
      final recommendationsCallsAfterLoad =
          mediaRepository.recommendationsCalls;

      await cubit.refresh();

      expect(mediaRepository.discoverCalls, discoverCallsAfterLoad);
      expect(
        mediaRepository.recommendationsCalls,
        recommendationsCallsAfterLoad,
      );
    });

    test('refresh() does re-fetch once the signal actually changes', () async {
      final mediaRepository = _FakeMediaRepository();
      final userLibraryRepository = InMemoryUserLibraryRepository();
      await userLibraryRepository.upsert(
        const UserMediaEntry(
          key: _dune,
          title: 'Dune',
          isFavorite: true,
          genres: [_action],
        ),
      );
      final cubit = _cubit(
        mediaRepository: mediaRepository,
        userLibraryRepository: userLibraryRepository,
        tasteProfileRepository: InMemoryTasteProfileRepository(),
        settingsRepository: _FakeSettingsRepository(
          const AppSettings(languageCode: 'en', regionCode: 'US'),
        ),
      );
      addTearDown(cubit.close);
      await cubit.load(MediaSegment.all);
      final discoverCallsAfterLoad = mediaRepository.discoverCalls;

      // A new favorite changes the "For you" filter's own withGenres.
      await userLibraryRepository.upsert(
        const UserMediaEntry(
          key: MediaKey(type: MediaType.tvShow, tmdbId: 101),
          title: 'The Bear',
          isFavorite: true,
          genres: [Genre(id: 'comedy')],
        ),
      );
      await cubit.refresh();

      expect(
        mediaRepository.discoverCalls,
        greaterThan(discoverCallsAfterLoad),
      );
    });

    test('a language/region change triggers refresh()', () async {
      final mediaRepository = _FakeMediaRepository();
      final userLibraryRepository = InMemoryUserLibraryRepository();
      await userLibraryRepository.upsert(
        const UserMediaEntry(
          key: _dune,
          title: 'Dune',
          isFavorite: true,
          genres: [_action],
        ),
      );
      final settingsRepository = _FakeSettingsRepository(
        const AppSettings(languageCode: 'en', regionCode: 'US'),
      );
      final cubit = _CountingRecommendationsCubit(
        mediaRepository,
        userLibraryRepository,
        InMemoryTasteProfileRepository(),
        settingsRepository,
        VibeCatalog(const []),
      );
      addTearDown(cubit.close);
      await cubit.load(MediaSegment.all);

      settingsRepository.controller.add(
        const AppSettings(languageCode: 'es', regionCode: 'ES'),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.refreshCount, 1);
    });
  });
}
