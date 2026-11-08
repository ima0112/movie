import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../app/environments.dart';
import '../../domain/entities/discover_filter.dart';
import '../../domain/entities/genre.dart';
import '../../domain/entities/media_detail.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/entities/media_key.dart';
import '../../domain/entities/media_type.dart';
import '../../domain/entities/result.dart';
import '../../domain/repositories/media_repository.dart';
import '../../network/dio_failure_mapper.dart';
import '../tmdb/tmdb_configuration_service.dart';
import '../tmdb/tmdb_detail_mappers.dart';
import '../tmdb/tmdb_image_urls.dart';
import '../tmdb/tmdb_mappers.dart';
import '../tmdb/tmdb_media_datasource.dart';

/// Discover's (B1) and D1/D2's real TMDB-backed [MediaRepository].
/// [searchMulti]/[discover] stay `UnimplementedError` (their own TODO)
/// until their own branches land; `getHeroItems`/`getCarouselSection`
/// only handle the sections Discover's own `DiscoverCubit.
/// sectionsBySegment` actually requests.
@real
@LazySingleton(as: MediaRepository)
class TmdbMediaRepository implements MediaRepository {
  TmdbMediaRepository(this._datasource, this._configService);

  final TmdbMediaDatasource _datasource;
  final TmdbConfigurationService _configService;

  /// Same hardcoded `'ES'` default as `LocaleInterceptor`'s own region
  /// query parameter — no real settings source exists yet (see that
  /// interceptor's own doc comment).
  static const _region = 'ES';

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
        .map((json) => mediaItemFromTrendingJson(json, imagesConfig: _imagesConfig))
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
        (page) => page.results
            .map((dto) => mediaItemFromMovieDto(dto, imagesConfig: _imagesConfig)),
      ),
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
        (page) => page.results
            .map((dto) => mediaItemFromTvDto(dto, imagesConfig: _imagesConfig)),
      ),
    );
  }

  List<MediaItem> _interleaved(Iterable<Iterable<MediaItem>> sources) {
    final seenIds = <int>{};
    final result = <MediaItem>[];
    final iterators = sources.map((s) => s.iterator).toList();
    var exhausted = false;
    while (!exhausted && result.length < 8) {
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
    Genre? genre,
  }) async {
    try {
      final items = switch (section) {
        CarouselSection.popularThisWeek => await _allSegmentHero(),
        CarouselSection.inTheaters => await _mapMovies(
          _datasource.movieNowPlaying,
        ),
        CarouselSection.upcoming => await _mapMovies(
          _datasource.movieUpcoming,
        ),
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
        CarouselSection.forYou => throw UnimplementedError(
          // TODO: needs TasteProfileRepository + `/discover` — not
          // requested by DiscoverCubit yet (see its own doc comment).
          'forYou needs a taste profile; not wired into Discover yet.',
        ),
        CarouselSection.becauseYouLike => throw UnimplementedError(
          // TODO: same as forYou, plus discover()'s own genre filter.
          'becauseYouLike needs a taste profile; not wired into Discover yet.',
        ),
      };
      return Success(items.take(10).toList());
    } on DioException catch (e) {
      return mapDioExceptionToFailure(e);
    }
  }

  Future<List<MediaItem>> _trending(MediaType? type) => switch (type) {
    MediaType.movie => _mapMovies(_datasource.trendingMovieWeek),
    MediaType.tvShow => _mapTv(_datasource.trendingTvWeek),
    null => throw UnimplementedError(
      'trending has no "All" segment equivalent in DiscoverCubit today.',
    ),
  };

  Future<List<MediaItem>> _topRated(MediaType? type) => switch (type) {
    MediaType.movie => _mapMovies(_datasource.movieTopRated),
    MediaType.tvShow => _mapTv(_datasource.tvTopRated),
    null => throw UnimplementedError(
      'topRated has no "All" segment equivalent in DiscoverCubit today.',
    ),
  };

  Future<List<MediaItem>> _mapMovies(
    Future<dynamic> Function() fetch,
  ) async {
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
  Future<Result<List<MediaItem>>> searchMulti(String query) {
    // TODO(tmdb-search): /search/multi — a later branch's job.
    throw UnimplementedError('searchMulti() is not implemented yet.');
  }

  @override
  Future<Result<List<MediaItem>>> discover(DiscoverFilter filter) {
    // TODO(tmdb-discover-filter): /discover/{movie|tv} — a later
    // branch's job.
    throw UnimplementedError('discover() is not implemented yet.');
  }
}
