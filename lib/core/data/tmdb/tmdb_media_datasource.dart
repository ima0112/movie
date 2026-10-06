import 'package:injectable/injectable.dart';

import '../../../app/environments.dart';
import '../../network/api_client.dart';
import 'dtos/tmdb_movie_detail_dto.dart';
import 'dtos/tmdb_movie_list_item_dto.dart';
import 'dtos/tmdb_paged_response_dto.dart';
import 'dtos/tmdb_person_detail_dto.dart';
import 'dtos/tmdb_season_detail_dto.dart';
import 'dtos/tmdb_tv_detail_dto.dart';
import 'dtos/tmdb_tv_list_item_dto.dart';

/// Raw TMDB responses only — DTOs in, DTOs (or, for the one mixed-type
/// endpoint, raw JSON maps) out. Never a [MediaItem]; mapping is
/// `tmdb_mappers.dart`'s job, not this datasource's (`docs/STRUCTURE.md`).
@real
@lazySingleton
class TmdbMediaDatasource {
  TmdbMediaDatasource(this._apiClient);

  final ApiClient _apiClient;

  /// `/trending/all/week`'s own `results` mix movies, TV shows, and
  /// people (TMDB's `media_type` field) — returned as raw maps instead
  /// of through [TmdbPagedResponseDto], since that generic wrapper needs
  /// one single item type. See `tmdb_mappers.dart`'s
  /// `mediaItemFromTrendingJson`, which reads `media_type` itself.
  Future<List<Map<String, dynamic>>> trendingAllWeek() async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/trending/all/week',
    );
    return List<Map<String, dynamic>>.from(
      response.data!['results'] as List,
    );
  }

  Future<TmdbPagedResponseDto<TmdbMovieListItemDto>> movieNowPlaying() =>
      _movies('/movie/now_playing');

  Future<TmdbPagedResponseDto<TmdbMovieListItemDto>> movieTopRated() =>
      _movies('/movie/top_rated');

  Future<TmdbPagedResponseDto<TmdbMovieListItemDto>> movieUpcoming() =>
      _movies('/movie/upcoming');

  // Not in this branch's own original endpoint list, but added anyway:
  // `CarouselSection.trending` (`docs/DECISIONS.md` §2's "Movies home" /
  // "TV shows home" rows) is one of `DiscoverCubit.sectionsBySegment`'s
  // *required* sections for both the Movies and TV Shows segments — a
  // plain `UnimplementedError` here would crash `loadDiscover` for either
  // segment, making this branch's own "Discover shows real TMDB data"
  // manual-verification step impossible to pass at all.
  Future<TmdbPagedResponseDto<TmdbMovieListItemDto>> trendingMovieWeek() =>
      _movies('/trending/movie/week');

  Future<TmdbPagedResponseDto<TmdbTvListItemDto>> tvOnTheAir() =>
      _tv('/tv/on_the_air');

  Future<TmdbPagedResponseDto<TmdbTvListItemDto>> tvTopRated() =>
      _tv('/tv/top_rated');

  Future<TmdbPagedResponseDto<TmdbTvListItemDto>> tvPopular() =>
      _tv('/tv/popular');

  Future<TmdbPagedResponseDto<TmdbTvListItemDto>> trendingTvWeek() =>
      _tv('/trending/tv/week');

  /// One call, per `docs/DECISIONS.md` §2: everything D1 needs
  /// (`credits`/`videos`/`similar`/`release_dates`/`watch/providers`)
  /// bundled via `append_to_response`.
  Future<TmdbMovieDetailDto> movieDetail(int id) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/movie/$id',
      queryParameters: const {
        'append_to_response': 'credits,videos,similar,release_dates,'
            'watch/providers',
      },
    );
    return TmdbMovieDetailDto.fromJson(response.data!);
  }

  /// Same as [movieDetail], for D2 — `content_ratings` instead of
  /// `release_dates`.
  Future<TmdbTvDetailDto> tvDetail(int id) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/tv/$id',
      queryParameters: const {
        'append_to_response': 'credits,videos,similar,content_ratings,'
            'watch/providers',
      },
    );
    return TmdbTvDetailDto.fromJson(response.data!);
  }

  /// D2's "Seasons" section, fetched on demand per season tapped — never
  /// bundled into [tvDetail]'s own call (`docs/DECISIONS.md` §2).
  Future<TmdbSeasonDetailDto> seasonDetail(int tvId, int seasonNumber) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/tv/$tvId/season/$seasonNumber',
    );
    return TmdbSeasonDetailDto.fromJson(response.data!);
  }

  /// B2's typing-state results — mixed movie/TV/person entries (TMDB's
  /// own `media_type`), same shape as [trendingAllWeek]'s own `results`,
  /// hence the same raw-maps-not-a-typed-DTO treatment.
  Future<List<Map<String, dynamic>>> searchMulti(String query) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/search/multi',
      queryParameters: {'query': query},
    );
    return List<Map<String, dynamic>>.from(
      response.data!['results'] as List,
    );
  }

  Future<TmdbPagedResponseDto<TmdbMovieListItemDto>> discoverMovie(
    Map<String, dynamic> params,
  ) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/discover/movie',
      queryParameters: params,
    );
    return TmdbPagedResponseDto.fromJson(
      response.data!,
      (json) => TmdbMovieListItemDto.fromJson(json! as Map<String, dynamic>),
    );
  }

  Future<TmdbPagedResponseDto<TmdbTvListItemDto>> discoverTv(
    Map<String, dynamic> params,
  ) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/discover/tv',
      queryParameters: params,
    );
    return TmdbPagedResponseDto.fromJson(
      response.data!,
      (json) => TmdbTvListItemDto.fromJson(json! as Map<String, dynamic>),
    );
  }

  /// D3 — one call, per `docs/DECISIONS.md` §2.
  Future<TmdbPersonDetailDto> personDetail(int id) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/person/$id',
      queryParameters: const {
        'append_to_response': 'movie_credits,tv_credits',
      },
    );
    return TmdbPersonDetailDto.fromJson(response.data!);
  }

  Future<TmdbPagedResponseDto<TmdbMovieListItemDto>> _movies(
    String path,
  ) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(path);
    return TmdbPagedResponseDto.fromJson(
      response.data!,
      (json) => TmdbMovieListItemDto.fromJson(json! as Map<String, dynamic>),
    );
  }

  Future<TmdbPagedResponseDto<TmdbTvListItemDto>> _tv(String path) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(path);
    return TmdbPagedResponseDto.fromJson(
      response.data!,
      (json) => TmdbTvListItemDto.fromJson(json! as Map<String, dynamic>),
    );
  }
}
