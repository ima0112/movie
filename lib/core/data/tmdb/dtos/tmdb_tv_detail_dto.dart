import 'package:json_annotation/json_annotation.dart';

import 'tmdb_credits_dto.dart';
import 'tmdb_genre_ref_dto.dart';
import 'tmdb_paged_response_dto.dart';
import 'tmdb_tv_list_item_dto.dart';
import 'tmdb_video_dto.dart';
import 'tmdb_watch_providers_dto.dart';

part 'tmdb_tv_detail_dto.g.dart';

/// `/tv/{id}?append_to_response=credits,videos,similar,content_ratings,
/// watch/providers` — one call, per `docs/DECISIONS.md` §2. Season
/// *episodes* are on demand (`/tv/{id}/season/{n}`, `tmdb_season_detail_
/// dto.dart`) — `seasons` here is only the summary TMDB already embeds
/// in this same response.
@JsonSerializable(createToJson: false)
class TmdbTvDetailDto {
  const TmdbTvDetailDto({
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.genres,
    required this.voteAverage,
    required this.firstAirDate,
    required this.lastAirDate,
    required this.status,
    required this.numberOfEpisodes,
    required this.episodeRunTime,
    required this.inProduction,
    required this.createdBy,
    required this.seasons,
    required this.credits,
    required this.videos,
    required this.similar,
    required this.contentRatings,
    required this.watchProviders,
    this.backdropPath,
  });

  final int id;
  final String name;
  final String overview;

  @JsonKey(name: 'poster_path')
  final String? posterPath;

  /// The 16:9 backdrop, for D2's header (`null` when TMDB has none).
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;

  final List<TmdbGenreRefDto> genres;

  @JsonKey(name: 'vote_average', defaultValue: 0.0)
  final double voteAverage;

  @JsonKey(name: 'first_air_date', defaultValue: '')
  final String firstAirDate;

  @JsonKey(name: 'last_air_date', defaultValue: '')
  final String lastAirDate;

  final String status;

  @JsonKey(name: 'number_of_episodes', defaultValue: 0)
  final int numberOfEpisodes;

  @JsonKey(name: 'episode_run_time', defaultValue: <int>[])
  final List<int> episodeRunTime;

  @JsonKey(name: 'in_production')
  final bool inProduction;

  @JsonKey(name: 'created_by', defaultValue: <TmdbCreatorDto>[])
  final List<TmdbCreatorDto> createdBy;

  final List<TmdbSeasonSummaryDto> seasons;
  final TmdbCreditsDto credits;
  final TmdbVideosDto videos;
  final TmdbPagedResponseDto<TmdbTvListItemDto> similar;

  @JsonKey(name: 'content_ratings')
  final TmdbContentRatingsDto contentRatings;

  @JsonKey(name: 'watch/providers')
  final TmdbWatchProvidersDto watchProviders;

  factory TmdbTvDetailDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbTvDetailDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TmdbCreatorDto {
  const TmdbCreatorDto({
    required this.id,
    required this.name,
    required this.profilePath,
  });

  final int id;
  final String name;

  @JsonKey(name: 'profile_path')
  final String? profilePath;

  factory TmdbCreatorDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbCreatorDtoFromJson(json);
}

/// One entry of `/tv/{id}`'s own embedded `seasons` summary list — not
/// to be confused with `tmdb_season_detail_dto.dart`'s
/// `TmdbSeasonDetailDto`, which is `/tv/{id}/season/{n}`'s own, much
/// richer, on-demand response (full episode list).
@JsonSerializable(createToJson: false)
class TmdbSeasonSummaryDto {
  const TmdbSeasonSummaryDto({
    required this.seasonNumber,
    required this.name,
    required this.episodeCount,
    required this.posterPath,
    required this.airDate,
  });

  @JsonKey(name: 'season_number')
  final int seasonNumber;

  final String name;

  @JsonKey(name: 'episode_count', defaultValue: 0)
  final int episodeCount;

  @JsonKey(name: 'poster_path')
  final String? posterPath;

  @JsonKey(name: 'air_date', defaultValue: '')
  final String airDate;

  factory TmdbSeasonSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbSeasonSummaryDtoFromJson(json);
}

/// `content_ratings: {results: [{iso_3166_1, rating}]}` — TV's own,
/// simpler equivalent of movie's `release_dates` (one rating per region,
/// not a list of them).
@JsonSerializable(createToJson: false)
class TmdbContentRatingsDto {
  const TmdbContentRatingsDto({required this.results});

  final List<TmdbContentRatingEntryDto> results;

  factory TmdbContentRatingsDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbContentRatingsDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TmdbContentRatingEntryDto {
  const TmdbContentRatingEntryDto({
    required this.iso31661,
    required this.rating,
  });

  @JsonKey(name: 'iso_3166_1')
  final String iso31661;

  @JsonKey(defaultValue: '')
  final String rating;

  factory TmdbContentRatingEntryDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbContentRatingEntryDtoFromJson(json);
}
