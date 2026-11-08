// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_season_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbSeasonDetailDto _$TmdbSeasonDetailDtoFromJson(Map<String, dynamic> json) =>
    TmdbSeasonDetailDto(
      seasonNumber: (json['season_number'] as num).toInt(),
      name: json['name'] as String,
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
    );
