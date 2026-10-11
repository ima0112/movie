import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../app/environments.dart';
import '../../domain/entities/discover_filter.dart';
import '../../domain/entities/media_detail.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/entities/media_key.dart';
import '../../domain/entities/media_type.dart';
import '../../domain/entities/result.dart';
import '../../domain/entities/season_summary.dart';
import '../../domain/repositories/media_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../network/dio_failure_mapper.dart';
import '../tmdb/tmdb_configuration_service.dart';
import '../tmdb/tmdb_detail_mappers.dart';
import '../tmdb/tmdb_discover_params.dart';
import '../tmdb/tmdb_image_urls.dart';
import '../tmdb/tmdb_mappers.dart';
import '../tmdb/tmdb_media_datasource.dart';

/// Discover's (B1), D1/D2's, B2's, and C1's real TMDB-backed
/// [MediaRepository]. `getHeroItems`/`getCarouselSection` only handle
/// the sections Discover's own `DiscoverCubit.sectionsBySegment`
/// actually requests.
@real
@LazySingleton(as: MediaRepository)
class TmdbMediaRepository implements MediaRepository {
  TmdbMediaRepository(
    this._datasource,
    this._configService,
    this._settingsRepository,
  );

  final TmdbMediaDatasource _datasource;
  final TmdbConfigurationService _configService;
  final SettingsRepository _settingsRepository;

  /// The user's own region (F11) — same source `ApiClient`'s
  /// `LocaleInterceptor` reads, so a detail call's watch
  /// providers/certification and a `/discover` call's own
  /// `certification_country` always agree with each other.
  String get _region => _settingsRepository.current.regionCode;

  /// Fire-and-forget, memoized — see `PosterImage`'s own identical use of
  /// `TmdbConfigurationService` for why this doesn't need an `await`.
  TmdbImagesConfig get _imagesConfig {
    _configService.load();
    return _configService.current;
  }

  @override
  Future<Result<List<MediaItem>>> getHeroItems({MediaType? type}) async {
    try {
      final items = switch (type) {
        null => await _allSegmentHero(),
        MediaType.movie => await _movieHero(),
        MediaType.tvShow => await _tvHero(),
      };
      return Success(items.take(8).toList());
    } on DioException catch (e) {
      return mapDioExceptionToFailure(e);
    }
  }

  Future<List<MediaItem>> _allSegmentHero() async {
    final trending = await _datasource.trendingAllWeek();
    return trending
        .map(
          (json) =>
              mediaItemFromTrendingJson(json, imagesConfig: _imagesConfig),
        )
        .nonNulls
        .toList();
  }

  /// `docs/DECISIONS.md` §2's "Movies home" row, interleaved rather than
  /// shown as one long now-playing list: 2 from each of its 4 sources,
  /// deduped by id (the same title often appears in more than one).
  Future<List<MediaItem>> _movieHero() async {
    final sources = await Future.wait([
      _datasource.movieNowPlaying(),
      _datasource.trendingMovieWeek(),
      _datasource.movieTopRated(),
      _datasource.movieUpcoming(),
    ]);
    return _interleaved(
      sources.map(
        (page) => page.results.map(
          (dto) => mediaItemFromMovieDto(dto, imagesConfig: _imagesConfig),
        ),
      ),
      limit: 8,
    );
  }

  /// `docs/DECISIONS.md` §2's "TV shows home" row — same interleaving as
  /// [_movieHero].
  Future<List<MediaItem>> _tvHero() async {
    final sources = await Future.wait([
      _datasource.tvOnTheAir(),
      _datasource.trendingTvWeek(),
      _datasource.tvTopRated(),
      _datasource.tvPopular(),
    ]);
    return _interleaved(
      sources.map(
        (page) => page.results.map(
          (dto) => mediaItemFromTvDto(dto, imagesConfig: _imagesConfig),
        ),
      ),
      limit: 8,
    );
  }

  List<MediaItem> _interleaved(
    Iterable<Iterable<MediaItem>> sources, {
    required int limit,
  }) {
    final seenIds = <int>{};
    final result = <MediaItem>[];
    final iterators = sources.map((s) => s.iterator).toList();
    var exhausted = false;
    while (!exhausted && result.length < limit) {
      exhausted = true;
      for (final it in iterators) {
        if (!it.moveNext()) continue;
        exhausted = false;
        if (seenIds.add(it.current.id)) result.add(it.current);
      }
    }
    return result;
  }

  @override
  Future<Result<List<MediaItem>>> getCarouselSection(
    CarouselSection section, {
    MediaType? type,
  }) async {
    try {
      final items = switch (section) {
        CarouselSection.popularThisWeek => await _allSegmentHero(),
        CarouselSection.inTheaters => await _mapMovies(
          _datasource.movieNowPlaying,
        ),
        CarouselSection.upcoming => await _mapMovies(_datasource.movieUpcoming),
        CarouselSection.airingNow => await _mapTv(_datasource.tvOnTheAir),
        CarouselSection.popular => await _mapTv(_datasource.tvPopular),
        CarouselSection.trending => await _trending(type),
        CarouselSection.topRated => await _topRated(type),
        // No TMDB endpoint hydrates this one — it's whatever's in
        // UserLibraryRepository's own watch-later set, which needs
        // per-id `/movie/{id}`/`/tv/{id}` calls this datasource doesn't
        // have yet. TODO: inject UserLibraryRepository and hydrate its
        // watch-later keys here instead of returning empty.
        CarouselSection.watchLater => const <MediaItem>[],
      };
      return Success(items.take(10).toList());
    } on DioException catch (e) {
      return mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<Result<List<MediaItem>>> recommendationsFor(MediaKey seed) async {
    try {
      final items = switch (seed.type) {
        MediaType.movie => await _mapMovies(
          () => _datasource.movieRecommendations(seed.tmdbId),
        ),
        MediaType.tvShow => await _mapTv(
          () => _datasource.tvRecommendations(seed.tmdbId),
        ),
      };
      return Success(items);
    } on DioException catch (e) {
      return mapDioExceptionToFailure(e);
    }
  }

  // `type: null` never actually reaches either of these —
  // `CarouselSection.trending`/`.topRated` only appear in
  // `DiscoverCubit.sectionsBySegment`'s Movies/TV Shows lists, always
  // with a concrete type — but an empty list (not a throw) is the safe
  // default if that ever changes, same reasoning as `watchLater` above.
  Future<List<MediaItem>> _trending(MediaType? type) => switch (type) {
    MediaType.movie => _mapMovies(_datasource.trendingMovieWeek),
    MediaType.tvShow => _mapTv(_datasource.trendingTvWeek),
    null => Future.value(const <MediaItem>[]),
  };

  Future<List<MediaItem>> _topRated(MediaType? type) => switch (type) {
    MediaType.movie => _mapMovies(_datasource.movieTopRated),
    MediaType.tvShow => _mapTv(_datasource.tvTopRated),
    null => Future.value(const <MediaItem>[]),
  };

  Future<List<MediaItem>> _mapMovies(Future<dynamic> Function() fetch) async {
    final page = await fetch();
    return page.results
        .map<MediaItem>(
          (dto) => mediaItemFromMovieDto(dto, imagesConfig: _imagesConfig),
        )
        .toList();
  }

  Future<List<MediaItem>> _mapTv(Future<dynamic> Function() fetch) async {
    final page = await fetch();
    return page.results
        .map<MediaItem>(
          (dto) => mediaItemFromTvDto(dto, imagesConfig: _imagesConfig),
        )
        .toList();
  }

  @override
  Future<Result<MediaDetail>> detail(MediaKey key) async {
    try {
      final MediaDetail detail = switch (key.type) {
        MediaType.movie => mediaDetailFromMovieDto(
          await _datasource.movieDetail(key.tmdbId),
          imagesConfig: _imagesConfig,
          region: _region,
        ),
        MediaType.tvShow => mediaDetailFromTvDto(
          await _datasource.tvDetail(key.tmdbId),
          imagesConfig: _imagesConfig,
          region: _region,
        ),
      };
      return Success(detail);
    } on DioException catch (e) {
      return mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<Result<SeasonDetail>> season(int tvId, int seasonNumber) async {
    try {
      final dto = await _datasource.seasonDetail(tvId, seasonNumber);
      return Success(seasonDetailFromDto(dto));
    } on DioException catch (e) {
      return mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<Result<List<MediaItem>>> searchMulti(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const Success([]);

    try {
      final results = await _datasource.searchMulti(trimmed);
      final items = results
          .map(
            (json) =>
                mediaItemFromTrendingJson(json, imagesConfig: _imagesConfig),
          )
          .nonNulls
          .toList();
      return Success(items);
    } on DioException catch (e) {
      return mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<Result<List<MediaItem>>> discover(DiscoverFilter filter) async {
    try {
      final items = switch (filter.type) {
        MediaType.movie => await _discoverMovies(filter),
        MediaType.tvShow => await _discoverTv(filter),
        // C1: "All = both interleaved" — only the first page of each
        // (no pagination concept on this interface today; see
        // tmdb_discover_params.dart's own doc comment).
        null => _interleaved([
          (await _discoverMovies(filter)),
          (await _discoverTv(filter)),
        ], limit: 40),
      };
      return Success(items);
    } on DioException catch (e) {
      return mapDioExceptionToFailure(e);
    }
  }

  Future<List<MediaItem>> _discoverMovies(DiscoverFilter filter) async {
    final page = await _datasource.discoverMovie(
      discoverQueryParams(filter, type: MediaType.movie),
    );
    return page.results
        .map((dto) => mediaItemFromMovieDto(dto, imagesConfig: _imagesConfig))
        .toList();
  }

  Future<List<MediaItem>> _discoverTv(DiscoverFilter filter) async {
    final page = await _datasource.discoverTv(
      discoverQueryParams(filter, type: MediaType.tvShow),
    );
    return page.results
        .map((dto) => mediaItemFromTvDto(dto, imagesConfig: _imagesConfig))
        .toList();
  }

  @override
  Future<Result<List<MediaItem>>> getPosterWallItems() async {
    try {
      final moviesFuture = _mapMovies(_datasource.trendingMovieWeek);
      final tvFuture = _mapTv(_datasource.trendingTvWeek);
      final seenIds = <int>{};
      final items = <MediaItem>[];
      for (final item in [...await moviesFuture, ...await tvFuture]) {
        if (seenIds.add(item.id)) items.add(item);
      }
      return Success(items);
    } on DioException catch (e) {
      return mapDioExceptionToFailure(e);
    }
  }
}
