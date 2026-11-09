import 'package:json_annotation/json_annotation.dart';

import 'tmdb_credits_dto.dart';
import 'tmdb_genre_ref_dto.dart';
import 'tmdb_movie_list_item_dto.dart';
import 'tmdb_paged_response_dto.dart';
import 'tmdb_video_dto.dart';
import 'tmdb_watch_providers_dto.dart';

part 'tmdb_movie_detail_dto.g.dart';

/// `/movie/{id}?append_to_response=credits,videos,similar,release_dates,
/// watch/providers` — one call, per `docs/DECISIONS.md` §2.
@JsonSerializable(createToJson: false)
class TmdbMovieDetailDto {
  const TmdbMovieDetailDto({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.genres,
    required this.voteAverage,
    required this.releaseDate,
    required this.runtime,
    required this.tagline,
    required this.status,
    required this.imdbId,
    required this.credits,
    required this.videos,
    required this.similar,
    required this.releaseDates,
    required this.watchProviders,
    this.backdropPath,
  });

  final int id;
  final String title;
  final String overview;

  @JsonKey(name: 'poster_path')
  final String? posterPath;

  /// The 16:9 backdrop, for D1's header (`null` when TMDB has none).
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;

  final List<TmdbGenreRefDto> genres;

  @JsonKey(name: 'vote_average', defaultValue: 0.0)
  final double voteAverage;

  @JsonKey(name: 'release_date', defaultValue: '')
  final String releaseDate;

  final int? runtime;
  final String? tagline;
  final String status;

  @JsonKey(name: 'imdb_id')
  final String? imdbId;

  final TmdbCreditsDto credits;
  final TmdbVideosDto videos;
  final TmdbPagedResponseDto<TmdbMovieListItemDto> similar;

  @JsonKey(name: 'release_dates')
  final TmdbReleaseDatesDto releaseDates;

  @JsonKey(name: 'watch/providers')
  final TmdbWatchProvidersDto watchProviders;

  factory TmdbMovieDetailDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbMovieDetailDtoFromJson(json);
}

/// `release_dates: {results: [{iso_3166_1, release_dates: [{certification,
/// ...}]}]}` — movie-only (TV's equivalent is `content_ratings`, a
/// simpler shape — see `tmdb_tv_detail_dto.dart`). Small and only ever
/// used by [TmdbMovieDetailDto], so it stays colocated rather than its
/// own file.
@JsonSerializable(createToJson: false)
class TmdbReleaseDatesDto {
  const TmdbReleaseDatesDto({required this.results});

  final List<TmdbReleaseDatesRegionDto> results;

  factory TmdbReleaseDatesDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbReleaseDatesDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TmdbReleaseDatesRegionDto {
  const TmdbReleaseDatesRegionDto({
    required this.iso31661,
    required this.releaseDates,
  });

  @JsonKey(name: 'iso_3166_1')
  final String iso31661;

  @JsonKey(name: 'release_dates')
  final List<TmdbReleaseDateEntryDto> releaseDates;

  factory TmdbReleaseDatesRegionDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbReleaseDatesRegionDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TmdbReleaseDateEntryDto {
  const TmdbReleaseDateEntryDto({required this.certification});

  @JsonKey(defaultValue: '')
  final String certification;

  factory TmdbReleaseDateEntryDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbReleaseDateEntryDtoFromJson(json);
}
