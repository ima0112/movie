// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_watch_providers_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbWatchProvidersDto _$TmdbWatchProvidersDtoFromJson(
  Map<String, dynamic> json,
) => TmdbWatchProvidersDto(
  results: (json['results'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      k,
      TmdbWatchProviderRegionDto.fromJson(e as Map<String, dynamic>),
    ),
  ),
);

TmdbWatchProviderRegionDto _$TmdbWatchProviderRegionDtoFromJson(
  Map<String, dynamic> json,
) => TmdbWatchProviderRegionDto(
  link: json['link'] as String?,
  flatrate:
      (json['flatrate'] as List<dynamic>?)
          ?.map(
            (e) => TmdbWatchProviderRefDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
  rent:
      (json['rent'] as List<dynamic>?)
          ?.map(
            (e) => TmdbWatchProviderRefDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
  buy:
      (json['buy'] as List<dynamic>?)
          ?.map(
            (e) => TmdbWatchProviderRefDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
);

TmdbWatchProviderRefDto _$TmdbWatchProviderRefDtoFromJson(
  Map<String, dynamic> json,
) => TmdbWatchProviderRefDto(
  providerName: json['provider_name'] as String,
  logoPath: json['logo_path'] as String?,
  providerId: (json['provider_id'] as num?)?.toInt(),
);
