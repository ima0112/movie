// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_video_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbVideosDto _$TmdbVideosDtoFromJson(Map<String, dynamic> json) =>
    TmdbVideosDto(
      results: (json['results'] as List<dynamic>)
          .map((e) => TmdbVideoDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

TmdbVideoDto _$TmdbVideoDtoFromJson(Map<String, dynamic> json) => TmdbVideoDto(
  key: json['key'] as String,
  site: json['site'] as String,
  type: json['type'] as String,
  name: json['name'] as String,
  official: json['official'] as bool,
  iso6391: json['iso_639_1'] as String? ?? '',
);
