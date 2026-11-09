// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_season_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbSeasonDetailDto _$TmdbSeasonDetailDtoFromJson(Map<String, dynamic> json) =>
    TmdbSeasonDetailDto(
      seasonNumber: (json['season_number'] as num).toInt(),
      name: json['name'] as String,
      overview: json['overview'] as String? ?? '',
      episodes: (json['episodes'] as List<dynamic>)
          .map((e) => TmdbEpisodeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

TmdbEpisodeDto _$TmdbEpisodeDtoFromJson(Map<String, dynamic> json) =>
    TmdbEpisodeDto(
      episodeNumber: (json['episode_number'] as num).toInt(),
      name: json['name'] as String,
      overview: json['overview'] as String? ?? '',
      stillPath: json['still_path'] as String?,
      airDate: json['air_date'] as String? ?? '',
      runtime: (json['runtime'] as num?)?.toInt(),
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      guestStars:
          (json['guest_stars'] as List<dynamic>?)
              ?.map((e) => TmdbGuestStarDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

TmdbGuestStarDto _$TmdbGuestStarDtoFromJson(Map<String, dynamic> json) =>
    TmdbGuestStarDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      character: json['character'] as String? ?? '',
      profilePath: json['profile_path'] as String?,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
