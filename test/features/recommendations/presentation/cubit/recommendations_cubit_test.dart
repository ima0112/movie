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
import 'package:movies/core/domain/entities/trailer_item.dart';
import 'package:movies/core/domain/entities/search_result.dart';
import 'package:movies/core/domain/entities/streaming_service.dart';
import 'package:movies/core/domain/entities/season_summary.dart';
import 'package:movies/core/domain/entities/taste_profile.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/core/domain/repositories/media_repository.dart';
import 'package:movies/core/domain/repositories/settings_repository.dart';
import 'package:movies/features/match_engine/domain/vibe.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';
import 'package:movies/features/recommendations/domain/recommendation_builder.dart';
import 'package:movies/features/recommendations/domain/recommendation_planner.dart';
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
  Future<Result<List<TrailerItem>>> latestTrailers({int limit = 8}) async =>
      const Success([]);

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

const _drama = Genre(id: 'drama');

TasteProfile _profile({
  Set<Genre> genres = const {},
  Set<String> vibes = const {},
}) => TasteProfile(
  likedGenres: genres,
  vetoedGenres: const {},
  likedVibes: vibes,
  yearFrom: 1990,
  updatedAt: DateTime(2026),
);

final _vibes = VibeCatalog([
  const Vibe(
    id: 'explosive',
    icon: 'vibeExplosive',
    movie: VibeRule(genreIds: ['action'], keywordIds: []),
    tv: VibeRule(genreIds: ['action'], keywordIds: []),
  ),
]);

const _settings = AppSettings(languageCode: 'en', regionCode: 'US');

RecommendationsCubit _make(
  _FakeMediaRepository media, {
  InMemoryUserLibraryRepository? library,
  InMemoryTasteProfileRepository? tastes,
  _FakeSettingsRepository? settings,
  DateTime? today,
}) => RecommendationsCubit(
  media,
  library ?? InMemoryUserLibraryRepository(),
  tastes ?? InMemoryTasteProfileRepository(),
  settings ?? _FakeSettingsRepository(_settings),
  _vibes,
  clock: () => today ?? DateTime(2026, 5, 4),
);

const _dune2 = UserMediaEntry(
  key: _dune,
  title: 'Dune',
  isFavorite: true,
  genres: [_action],
);

void main() {
  group('All follows the taste profile', () {
    test('no profile -> all three sections Hidden, no network, even with a '
        'full My List', () async {
      final media = _FakeMediaRepository();
      final library = InMemoryUserLibraryRepository();
      await library.upsert(_dune2);
      final cubit = _make(media, library: library);
      addTearDown(cubit.close);

      await cubit.load(MediaSegment.all);

      expect(cubit.state.forYou, isA<RecommendationSectionHidden>());
      expect(cubit.state.becauseYouLike, isA<RecommendationSectionHidden>());
      expect(cubit.state.becauseYouWant, isA<RecommendationSectionHidden>());
      expect(media.discoverCalls + media.recommendationsCalls, 0);
    });

    test('a profile gives For you, Because you like {genre} and Because '
        'you want {vibe}', () async {
      final media = _FakeMediaRepository();
      final tastes = InMemoryTasteProfileRepository();
      await tastes.save(
        _profile(genres: {_action, _drama}, vibes: {'explosive'}),
      );
      final cubit = _make(media, tastes: tastes);
      addTearDown(cubit.close);

      await cubit.load(MediaSegment.all);

      expect(cubit.state.forYou, isA<RecommendationSectionLoaded>());
      final like = cubit.state.becauseYouLike as RecommendationSectionLoaded;
      expect(like.seed, isA<GenreSeed>());
      final want = cubit.state.becauseYouWant as RecommendationSectionLoaded;
      expect((want.seed! as VibeSeed).vibe.id, 'explosive');
      // Genre and vibe sections use /discover, never /recommendations.
      expect(media.recommendationsCalls, 0);
    });
  });

  group('Movies and TV Shows follow My List', () {
    test('a favorite gives For you and Because you like {title}; the '
        'taste profile is ignored', () async {
      final media = _FakeMediaRepository();
      final library = InMemoryUserLibraryRepository();
      await library.upsert(_dune2);
      final cubit = _make(media, library: library);
      addTearDown(cubit.close);

      await cubit.load(MediaSegment.movie);

      expect(cubit.state.forYou, isA<RecommendationSectionLoaded>());
      final like = cubit.state.becauseYouLike as RecommendationSectionLoaded;
      expect(like.seedTitle, 'Dune');
      expect(cubit.state.becauseYouWant, isA<RecommendationSectionHidden>());
      expect(media.recommendationsCalls, 1);
    });

    test('something watched and rated badly never seeds a section', () async {
      final media = _FakeMediaRepository();
      final library = InMemoryUserLibraryRepository();
      await library.upsert(
        UserMediaEntry(
          key: _dune,
          title: 'Dune',
          watchedAt: DateTime(2026),
          rating: 2,
          genres: const [_action],
        ),
      );
      final cubit = _make(media, library: library);
      addTearDown(cubit.close);

      await cubit.load(MediaSegment.movie);

      expect(cubit.state.becauseYouLike, isA<RecommendationSectionHidden>());
      expect(cubit.state.forYou, isA<RecommendationSectionHidden>());
      expect(media.discoverCalls + media.recommendationsCalls, 0);
    });
  });

  group('behaviour', () {
    Future<RecommendationsCubit> loadedMovieCubit(
      _FakeMediaRepository media,
      InMemoryUserLibraryRepository library, {
      DateTime? today,
      _FakeSettingsRepository? settings,
    }) async {
      final cubit = _make(
        media,
        library: library,
        settings: settings,
        today: today,
      );
      addTearDown(cubit.close);
      await cubit.load(MediaSegment.movie);
      return cubit;
    }

    test('one section failing never blocks or clears the other', () async {
      final media = _FakeMediaRepository()
        ..discoverResult = const Failure(FailureReason.network);
      final library = InMemoryUserLibraryRepository();
      await library.upsert(_dune2);
      final cubit = await loadedMovieCubit(media, library);

      expect(cubit.state.forYou, isA<RecommendationSectionError>());
      expect(cubit.state.becauseYouLike, isA<RecommendationSectionLoaded>());
    });

    test('retry(forYou) re-fetches only that section', () async {
      final media = _FakeMediaRepository()
        ..discoverResult = const Failure(FailureReason.network);
      final library = InMemoryUserLibraryRepository();
      await library.upsert(_dune2);
      final cubit = await loadedMovieCubit(media, library);
      final before = media.recommendationsCalls;

      media.discoverResult = Success(_recommendationPool);
      await cubit.retry(RecommendationSlot.forYou);

      expect(cubit.state.forYou, isA<RecommendationSectionLoaded>());
      expect(media.recommendationsCalls, before);
    });

    test('refresh() on the same day with nothing changed costs no '
        'network call', () async {
      final media = _FakeMediaRepository();
      final library = InMemoryUserLibraryRepository();
      await library.upsert(_dune2);
      final cubit = await loadedMovieCubit(media, library);
      final discover = media.discoverCalls;
      final recommendations = media.recommendationsCalls;

      await cubit.refresh();

      expect(media.discoverCalls, discover);
      expect(media.recommendationsCalls, recommendations);
    });

    test('refresh() picks up a new My List signal', () async {
      final media = _FakeMediaRepository();
      final library = InMemoryUserLibraryRepository();
      await library.upsert(_dune2);
      final cubit = await loadedMovieCubit(media, library);
      final discover = media.discoverCalls;

      await library.upsert(
        const UserMediaEntry(
          key: MediaKey(type: MediaType.movie, tmdbId: 2),
          title: 'Heat',
          isFavorite: true,
          genres: [_drama],
        ),
      );
      await cubit.refresh();

      expect(media.discoverCalls, greaterThan(discover));
    });

    test(
      'the title seed changes from day to day, never the day before',
      () async {
        final library = InMemoryUserLibraryRepository();
        for (var i = 1; i <= 5; i++) {
          await library.upsert(
            UserMediaEntry(
              key: MediaKey(type: MediaType.movie, tmdbId: i),
              title: 'Title $i',
              isFavorite: true,
              genres: const [_action],
            ),
          );
        }
        final titles = <String?>[];
        for (var d = 1; d <= 6; d++) {
          // Ids that don't collide with My List's (those are excluded).
          final pool = List.generate(8, (i) => _movie(100 + i));
          final media = _FakeMediaRepository()
            ..recommendationsResult = Success(pool)
            ..discoverResult = Success(pool);
          final cubit = await loadedMovieCubit(
            media,
            library,
            today: DateTime(2026, 5, d),
          );
          titles.add(
            (cubit.state.becauseYouLike as RecommendationSectionLoaded)
                .seedTitle,
          );
        }
        for (var i = 1; i < titles.length; i++) {
          expect(titles[i], isNot(titles[i - 1]));
        }
        expect(titles.toSet().length, greaterThan(2));
      },
    );

    test('a language/region change triggers refresh()', () async {
      final media = _FakeMediaRepository();
      final library = InMemoryUserLibraryRepository();
      await library.upsert(_dune2);
      final settings = _FakeSettingsRepository(_settings);
      final cubit = _CountingRecommendationsCubit(
        media,
        library,
        InMemoryTasteProfileRepository(),
        settings,
        _vibes,
      );
      addTearDown(cubit.close);
      await cubit.load(MediaSegment.movie);

      settings.controller.add(
        const AppSettings(languageCode: 'es', regionCode: 'ES'),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.refreshCount, 1);
    });
  });
}
