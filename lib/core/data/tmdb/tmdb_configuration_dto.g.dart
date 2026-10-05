// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_configuration_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbConfigurationDto _$TmdbConfigurationDtoFromJson(
  Map<String, dynamic> json,
) => TmdbConfigurationDto(
  images: TmdbImagesConfigDto.fromJson(json['images'] as Map<String, dynamic>),
);

TmdbImagesConfigDto _$TmdbImagesConfigDtoFromJson(Map<String, dynamic> json) =>
    TmdbImagesConfigDto(
      secureBaseUrl: json['secure_base_url'] as String,
      posterSizes: (json['poster_sizes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      backdropSizes: (json['backdrop_sizes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      profileSizes: (json['profile_sizes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
