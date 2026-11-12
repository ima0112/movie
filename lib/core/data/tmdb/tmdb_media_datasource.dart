import 'dtos/tmdb_video_dto.dart';
import 'dtos/tmdb_watch_providers_dto.dart';
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
  /// One page of `/trending/all/week` with its totals, raw like
  /// [trendingAllWeek].
  Future<
    ({List<Map<String, dynamic>> results, int totalPages, int totalResults})
  >
  trendingAllWeekPage(int page) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/trending/all/week',
      queryParameters: {'page': page},
    );
    final data = response.data!;
    return (
      results: List<Map<String, dynamic>>.from(data['results'] as List),
      totalPages: (data['total_pages'] as num?)?.toInt() ?? 1,
      totalResults: (data['total_results'] as num?)?.toInt() ?? 0,
    );
  }

  Future<List<Map<String, dynamic>>> trendingAllWeek() async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/trending/all/week',
    );
    return List<Map<String, dynamic>>.from(response.data!['results'] as List);
  }

  Future<TmdbPagedResponseDto<TmdbMovieListItemDto>> movieNowPlaying({
    int page = 1,
  }) => _movies('/movie/now_playing', page);

  Future<TmdbPagedResponseDto<TmdbMovieListItemDto>> movieTopRated({
    int page = 1,
  }) => _movies('/movie/top_rated', page);

  Future<TmdbPagedResponseDto<TmdbMovieListItemDto>> movieUpcoming({
    int page = 1,
  }) => _movies('/movie/upcoming', page);

  // Not in this branch's own original endpoint list, but added anyway:
  // `CarouselSection.trending` (`docs/DECISIONS.md` §2's "Movies home" /
  // "TV shows home" rows) is one of `DiscoverCubit.sectionsBySegment`'s
  // *required* sections for both the Movies and TV Shows segments — a
  // plain `UnimplementedError` here would crash `loadDiscover` for either
  // segment, making this branch's own "Discover shows real TMDB data"
  // manual-verification step impossible to pass at all.
  Future<TmdbPagedResponseDto<TmdbMovieListItemDto>> trendingMovieWeek({
    int page = 1,
  }) => _movies('/trending/movie/week', page);

  Future<TmdbPagedResponseDto<TmdbTvListItemDto>> tvOnTheAir({int page = 1}) =>
      _tv('/tv/on_the_air', page);

  Future<TmdbPagedResponseDto<TmdbTvListItemDto>> tvTopRated({int page = 1}) =>
      _tv('/tv/top_rated', page);

  Future<TmdbPagedResponseDto<TmdbTvListItemDto>> tvPopular({int page = 1}) =>
      _tv('/tv/popular', page);

  Future<TmdbPagedResponseDto<TmdbTvListItemDto>> trendingTvWeek({
    int page = 1,
  }) => _tv('/trending/tv/week', page);

  /// B1's "Because you like X" — `RecommendationBuilder`'s own seed.
  /// Collaborative-filtering based (TMDB's own description), not the
  /// genre/keyword `similar` already bundled into [movieDetail]'s
  /// `append_to_response` — a better fit for "people who liked this
  /// also liked…", and far cheaper than fetching the full detail just
  /// to read that field.
  Future<TmdbPagedResponseDto<TmdbMovieListItemDto>> movieRecommendations(
    int id,
  ) => _movies('/movie/$id/recommendations');

  /// Same as [movieRecommendations], for a TV seed.
  Future<TmdbPagedResponseDto<TmdbTvListItemDto>> tvRecommendations(int id) =>
      _tv('/tv/$id/recommendations');

  /// One call, per `docs/DECISIONS.md` §2: everything D1 needs
  /// (`credits`/`videos`/`similar`/`release_dates`/`watch/providers`)
  /// bundled via `append_to_response`.
  Future<TmdbMovieDetailDto> movieDetail(int id) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/movie/$id',
      queryParameters: const {
        'append_to_response':
            'credits,videos,similar,release_dates,'
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
        'append_to_response':
            'credits,aggregate_credits,videos,similar,content_ratings,'
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
    return List<Map<String, dynamic>>.from(response.data!['results'] as List);
  }

  /// The streaming services TMDB lists for [type] in [region]
  /// (`/watch/providers/{movie|tv}`), as raw maps: `provider_id`,
  /// `provider_name`, `logo_path`, `display_priority`.
  Future<List<Map<String, dynamic>>> watchProviders(
    String type, {
    required String region,
  }) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/watch/providers/$type',
      queryParameters: {'watch_region': region},
    );
    return List<Map<String, dynamic>>.from(response.data!['results'] as List);
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

  /// D3 — one call, per `docs/DECISIONS.md` §2. [language] overrides
  /// `LocaleInterceptor`'s own default (it only fills in `language` via
  /// `putIfAbsent`, so an explicit value here always wins) — used to
  /// fetch an English-language biography when the user's own language
  /// has no translation for it (`personDetailFromDto`'s own
  /// `fallbackBiography`).
  Future<TmdbPersonDetailDto> personDetail(int id, {String? language}) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/person/$id',
      queryParameters: {
        'append_to_response': 'movie_credits,tv_credits',
        'language': ?language,
      },
    );
    return TmdbPersonDetailDto.fromJson(response.data!);
  }

  /// Where one title streams, per region (`/{movie|tv}/{id}/watch/providers`)
  /// — the small call behind a poster's platform logo, instead of a whole
  /// detail fetch.
  Future<TmdbWatchProvidersDto> watchProvidersOf(String type, int id) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/$type/$id/watch/providers',
    );
    return TmdbWatchProvidersDto.fromJson(response.data!);
  }

  /// A movie's videos in the user's language, English and unlabeled ones
  /// (TMDB would otherwise return only the exact language).
  Future<List<TmdbVideoDto>> movieVideos(int id) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/movie/$id/videos',
      queryParameters: {'include_video_language': 'en,es,null'},
    );
    return TmdbVideosDto.fromJson(response.data!).results;
  }

  Future<TmdbPagedResponseDto<TmdbMovieListItemDto>> _movies(
    String path, [
    int page = 1,
  ]) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      path,
      queryParameters: {'page': page},
    );
    return TmdbPagedResponseDto.fromJson(
      response.data!,
      (json) => TmdbMovieListItemDto.fromJson(json! as Map<String, dynamic>),
    );
  }

  Future<TmdbPagedResponseDto<TmdbTvListItemDto>> _tv(
    String path, [
    int page = 1,
  ]) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      path,
      queryParameters: {'page': page},
    );
    return TmdbPagedResponseDto.fromJson(
      response.data!,
      (json) => TmdbTvListItemDto.fromJson(json! as Map<String, dynamic>),
    );
  }
}
