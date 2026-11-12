import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../app/environments.dart';
import '../../domain/entities/discover_filter.dart';
import '../../domain/entities/discover_page.dart';
import '../../domain/entities/media_detail.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/entities/media_key.dart';
import '../../domain/entities/media_type.dart';
import '../../domain/entities/result.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/entities/streaming_service.dart';
import '../../domain/entities/trailer_item.dart';
import '../../domain/entities/video.dart';
import '../../domain/entities/season_summary.dart';
import '../../domain/repositories/media_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/services/daily_picker.dart';
import '../../network/dio_failure_mapper.dart';
import '../tmdb/dtos/tmdb_movie_list_item_dto.dart';
import '../tmdb/dtos/tmdb_paged_response_dto.dart';
import '../tmdb/dtos/tmdb_tv_list_item_dto.dart';
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
        CarouselSection.comingSoon => await _comingSoon(),
        CarouselSection.finishedShows => await _finishedShows(),
        CarouselSection.trending => await _trending(type),
        CarouselSection.topRated => await _topRated(type),
        // No TMDB endpoint hydrates this one — it's whatever's in
        // UserLibraryRepository's own watch-later set, which needs
        // per-id `/movie/{id}`/`/tv/{id}` calls this datasource doesn't
        // have yet. TODO: inject UserLibraryRepository and hydrate its
        // watch-later keys here instead of returning empty.
        CarouselSection.watchLater => const <MediaItem>[],
      };
      // Finished shows is an all-time ranking whose top never moves: show a
      // day-stable shuffle of the page instead, so Home isn't identical daily.
      final shown = section == CarouselSection.finishedShows
          ? DailyPicker(
              DateTime.now(),
            ).shuffled(items, salt: 'home-${section.name}')
          : items;
      return Success(shown.take(10).toList());
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

  /// Movies and shows releasing from tomorrow up to 90 days ahead, most
  /// popular first — the same window as B2's "Coming soon".
  /// Movies and shows releasing from tomorrow up to 90 days ahead — the same
  /// window as B2's "Coming soon".
  DiscoverFilter _comingSoonFilter() {
    final today = DateTime.now();
    return DiscoverFilter(
      releasedFrom: today.add(const Duration(days: 1)),
      releasedTo: today.add(const Duration(days: 90)),
      minVoteCount: 0,
    );
  }

  Future<List<MediaItem>> _comingSoon() async {
    final filter = _comingSoonFilter();
    final page = await _discoverPage(filter, 1);
    return page.items.take(10).toList();
  }

  static const DiscoverFilter _finishedShowsFilter = DiscoverFilter(
    type: MediaType.tvShow,
    tvStatus: DiscoverTvStatus.ended,
    sortBy: DiscoverSortBy.rating,
    minVoteCount: 500,
  );

  Future<List<MediaItem>> _finishedShows() async =>
      (await _discoverPage(_finishedShowsFilter, 1)).items;

  /// How many candidates `latestTrailers` probes per wanted title: some have
  /// no YouTube video.
  static const int _trailerCandidateFactor = 2;

  @override
  Future<Result<List<TrailerItem>>> latestTrailers({int limit = 8}) async {
    try {
      final sources = await Future.wait([
        _datasource.movieNowPlaying(),
        _datasource.movieUpcoming(),
      ]);
      final candidates = _interleaved(
        sources.map(
          (page) => page.results.map(
            (dto) => mediaItemFromMovieDto(dto, imagesConfig: _imagesConfig),
          ),
        ),
        limit: limit * _trailerCandidateFactor,
      );
      final language = _settingsRepository.current.languageCode;
      final found = await Future.wait(
        candidates.map((item) async {
          try {
            final videos = await _datasource.movieVideos(item.id);
            final video = Video.pickTrailer(
              videos.map(
                (v) => Video(
                  key: v.key,
                  site: v.site,
                  type: v.type,
                  name: v.name,
                  official: v.official,
                  iso6391: v.iso6391,
                ),
              ),
              language: language,
            );
            return video == null ? null : TrailerItem(item: item, video: video);
          } on DioException {
            return null; // one title failing shouldn't sink the row
          }
        }),
      );
      return Success(found.nonNulls.take(limit).toList());
    } on DioException catch (e) {
      return mapDioExceptionToFailure(e);
    }
  }

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
  Future<Result<MediaDetail>> detail(MediaKey key, {String? regionCode}) async {
    final region = regionCode ?? _region;
    try {
      final MediaDetail detail = switch (key.type) {
        MediaType.movie => mediaDetailFromMovieDto(
          await _datasource.movieDetail(key.tmdbId),
          imagesConfig: _imagesConfig,
          region: region,
        ),
        MediaType.tvShow => mediaDetailFromTvDto(
          await _datasource.tvDetail(key.tmdbId),
          imagesConfig: _imagesConfig,
          region: region,
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
  Future<Result<List<SearchResult>>> searchMulti(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const Success([]);

    try {
      final results = await _datasource.searchMulti(trimmed);
      final items = results
          .map(
            (json) => searchResultFromJson(json, imagesConfig: _imagesConfig),
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
    final result = await discoverPage(filter);
    return switch (result) {
      Success(:final value) => Success(value.items),
      Failure(:final reason) => Failure(reason),
    };
  }

  @override
  Future<Result<DiscoverPage>> discoverPage(
    DiscoverFilter filter, {
    int page = 1,
  }) async {
    try {
      return Success(await _discoverPage(filter, page));
    } on DioException catch (e) {
      return mapDioExceptionToFailure(e);
    }
  }

  Future<DiscoverPage> _discoverPage(DiscoverFilter filter, int page) async {
    switch (filter.type) {
      case MediaType.movie:
        return _moviesPage((p) => _discoverMovies(filter, p), page);
      case MediaType.tvShow:
        return _tvPage((p) => _discoverTv(filter, p), page);
      case null:
        // C1: "All = both interleaved" — the same page of each type, woven
        // together. A type that has run out of pages contributes nothing.
        final parts = await Future.wait([
          _moviesPageOrEnd((p) => _discoverMovies(filter, p), page),
          _tvPageOrEnd((p) => _discoverTv(filter, p), page),
        ]);
        return _mergedPage(parts, page);
    }
  }

  Future<TmdbPagedResponseDto<TmdbMovieListItemDto>> _discoverMovies(
    DiscoverFilter filter,
    int page,
  ) => _datasource.discoverMovie({
    ...discoverQueryParams(filter, type: MediaType.movie, watchRegion: _region),
    'page': page,
  });

  Future<TmdbPagedResponseDto<TmdbTvListItemDto>> _discoverTv(
    DiscoverFilter filter,
    int page,
  ) => _datasource.discoverTv({
    ...discoverQueryParams(
      filter,
      type: MediaType.tvShow,
      watchRegion: _region,
    ),
    'page': page,
  });

  Future<DiscoverPage> _moviesPage(
    Future<TmdbPagedResponseDto<TmdbMovieListItemDto>> Function(int page) fetch,
    int page,
  ) async {
    final dto = await fetch(page);
    return DiscoverPage(
      items: [
        for (final d in dto.results)
          mediaItemFromMovieDto(d, imagesConfig: _imagesConfig),
      ],
      page: dto.page,
      totalPages: dto.totalPages,
      totalResults: dto.totalResults,
    );
  }

  Future<DiscoverPage> _tvPage(
    Future<TmdbPagedResponseDto<TmdbTvListItemDto>> Function(int page) fetch,
    int page,
  ) async {
    final dto = await fetch(page);
    return DiscoverPage(
      items: [
        for (final d in dto.results)
          mediaItemFromTvDto(d, imagesConfig: _imagesConfig),
      ],
      page: dto.page,
      totalPages: dto.totalPages,
      totalResults: dto.totalResults,
    );
  }

  /// A page past a type's last one makes TMDB answer 400; in a merged "All"
  /// list that just means that type has ended.
  Future<DiscoverPage> _moviesPageOrEnd(
    Future<TmdbPagedResponseDto<TmdbMovieListItemDto>> Function(int page) fetch,
    int page,
  ) => _orEnd(() => _moviesPage(fetch, page), page);

  Future<DiscoverPage> _tvPageOrEnd(
    Future<TmdbPagedResponseDto<TmdbTvListItemDto>> Function(int page) fetch,
    int page,
  ) => _orEnd(() => _tvPage(fetch, page), page);

  Future<DiscoverPage> _orEnd(
    Future<DiscoverPage> Function() fetch,
    int page,
  ) async {
    try {
      return await fetch();
    } on DioException catch (e) {
      if (page > 1 && e.response?.statusCode == 400) {
        return DiscoverPage(
          items: const [],
          page: page,
          totalPages: page - 1,
          totalResults: 0,
        );
      }
      rethrow;
    }
  }

  DiscoverPage _mergedPage(List<DiscoverPage> parts, int page) {
    final items = _interleaved(
      parts.map((p) => p.items),
      limit: parts.fold<int>(0, (sum, p) => sum + p.items.length),
    );
    return DiscoverPage(
      items: items,
      page: page,
      totalPages: parts.map((p) => p.totalPages).reduce(math.max),
      totalResults: parts.fold<int>(0, (sum, p) => sum + p.totalResults),
    );
  }

  @override
  Future<Result<DiscoverPage>> carouselSectionPage(
    CarouselSection section, {
    MediaType? type,
    int page = 1,
  }) async {
    try {
      final result = switch (section) {
        CarouselSection.popularThisWeek => await _trendingAllPage(page),
        CarouselSection.inTheaters => await _moviesPage(
          (p) => _datasource.movieNowPlaying(page: p),
          page,
        ),
        CarouselSection.upcoming => await _moviesPage(
          (p) => _datasource.movieUpcoming(page: p),
          page,
        ),
        CarouselSection.airingNow => await _tvPage(
          (p) => _datasource.tvOnTheAir(page: p),
          page,
        ),
        CarouselSection.popular => await _tvPage(
          (p) => _datasource.tvPopular(page: p),
          page,
        ),
        CarouselSection.trending => switch (type) {
          MediaType.movie => await _moviesPage(
            (p) => _datasource.trendingMovieWeek(page: p),
            page,
          ),
          MediaType.tvShow => await _tvPage(
            (p) => _datasource.trendingTvWeek(page: p),
            page,
          ),
          null => DiscoverPage.empty,
        },
        CarouselSection.topRated => switch (type) {
          MediaType.movie => await _moviesPage(
            (p) => _datasource.movieTopRated(page: p),
            page,
          ),
          MediaType.tvShow => await _tvPage(
            (p) => _datasource.tvTopRated(page: p),
            page,
          ),
          null => DiscoverPage.empty,
        },
        CarouselSection.comingSoon => await _discoverPage(
          _comingSoonFilter(),
          page,
        ),
        CarouselSection.finishedShows => await _discoverPage(
          _finishedShowsFilter,
          page,
        ),
        CarouselSection.watchLater => DiscoverPage.empty,
      };
      return Success(result);
    } on DioException catch (e) {
      return mapDioExceptionToFailure(e);
    }
  }

  Future<DiscoverPage> _trendingAllPage(int page) async {
    final data = await _datasource.trendingAllWeekPage(page);
    return DiscoverPage(
      items: [
        for (final json in data.results)
          ?mediaItemFromTrendingJson(json, imagesConfig: _imagesConfig),
      ],
      page: page,
      totalPages: data.totalPages,
      totalResults: data.totalResults,
    );
  }

  /// How many services B2's pill row offers.
  static const int _maxStreamingServices = 15;

  @override
  Future<Result<List<StreamingService>>> streamingServices({
    MediaType? type,
  }) async {
    try {
      final types = switch (type) {
        MediaType.movie => ['movie'],
        MediaType.tvShow => ['tv'],
        null => ['movie', 'tv'],
      };
      final raw = <Map<String, dynamic>>[];
      for (final t in types) {
        raw.addAll(await _datasource.watchProviders(t, region: _region));
      }
      return Success(
        streamingServicesFromJson(
          raw,
          imagesConfig: _imagesConfig,
          limit: _maxStreamingServices,
        ),
      );
    } on DioException catch (e) {
      return mapDioExceptionToFailure(e);
    }
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
