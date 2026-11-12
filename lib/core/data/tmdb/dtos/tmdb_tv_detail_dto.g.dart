// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_tv_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbTvDetailDto _$TmdbTvDetailDtoFromJson(Map<String, dynamic> json) =>
    TmdbTvDetailDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      overview: json['overview'] as String,
      posterPath: json['poster_path'] as String?,
      genres: (json['genres'] as List<dynamic>)
          .map((e) => TmdbGenreRefDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      firstAirDate: json['first_air_date'] as String? ?? '',
      lastAirDate: json['last_air_date'] as String? ?? '',
      status: json['status'] as String,
      numberOfEpisodes: (json['number_of_episodes'] as num?)?.toInt() ?? 0,
      episodeRunTime:
          (json['episode_run_time'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      inProduction: json['in_production'] as bool,
      createdBy:
          (json['created_by'] as List<dynamic>?)
              ?.map((e) => TmdbCreatorDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      seasons: (json['seasons'] as List<dynamic>)
          .map((e) => TmdbSeasonSummaryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      credits: TmdbCreditsDto.fromJson(json['credits'] as Map<String, dynamic>),
      videos: TmdbVideosDto.fromJson(json['videos'] as Map<String, dynamic>),
      similar: TmdbPagedResponseDto<TmdbTvListItemDto>.fromJson(
        json['similar'] as Map<String, dynamic>,
        (value) => TmdbTvListItemDto.fromJson(value as Map<String, dynamic>),
      ),
      contentRatings: TmdbContentRatingsDto.fromJson(
        json['content_ratings'] as Map<String, dynamic>,
      ),
      watchProviders: TmdbWatchProvidersDto.fromJson(
        json['watch/providers'] as Map<String, dynamic>,
      ),
      backdropPath: json['backdrop_path'] as String?,
      originalLanguage: json['original_language'] as String?,
      originCountry:
          (json['origin_country'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      lastEpisodeToAir: json['last_episode_to_air'] == null
          ? null
          : TmdbEpisodeToAirDto.fromJson(
              json['last_episode_to_air'] as Map<String, dynamic>,
            ),
      nextEpisodeToAir: json['next_episode_to_air'] == null
          ? null
          : TmdbEpisodeToAirDto.fromJson(
              json['next_episode_to_air'] as Map<String, dynamic>,
            ),
      aggregateCredits: json['aggregate_credits'] == null
          ? null
          : TmdbAggregateCreditsDto.fromJson(
              json['aggregate_credits'] as Map<String, dynamic>,
            ),
    );

TmdbCreatorDto _$TmdbCreatorDtoFromJson(Map<String, dynamic> json) =>
    TmdbCreatorDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      profilePath: json['profile_path'] as String?,
    );

TmdbSeasonSummaryDto _$TmdbSeasonSummaryDtoFromJson(
  Map<String, dynamic> json,
) => TmdbSeasonSummaryDto(
  seasonNumber: (json['season_number'] as num).toInt(),
  name: json['name'] as String,
  episodeCount: (json['episode_count'] as num?)?.toInt() ?? 0,
  posterPath: json['poster_path'] as String?,
  airDate: json['air_date'] as String? ?? '',
  voteAverage: (json['vote_average'] as num?)?.toDouble(),
);

TmdbContentRatingsDto _$TmdbContentRatingsDtoFromJson(
  Map<String, dynamic> json,
) => TmdbContentRatingsDto(
  results: (json['results'] as List<dynamic>)
      .map((e) => TmdbContentRatingEntryDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

TmdbContentRatingEntryDto _$TmdbContentRatingEntryDtoFromJson(
  Map<String, dynamic> json,
) => TmdbContentRatingEntryDto(
  iso31661: json['iso_3166_1'] as String,
  rating: json['rating'] as String? ?? '',
);

TmdbEpisodeToAirDto _$TmdbEpisodeToAirDtoFromJson(Map<String, dynamic> json) =>
    TmdbEpisodeToAirDto(
      seasonNumber: (json['season_number'] as num).toInt(),
      episodeNumber: (json['episode_number'] as num).toInt(),
      name: json['name'] as String,
      airDate: json['air_date'] as String? ?? '',
      stillPath: json['still_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
    );
