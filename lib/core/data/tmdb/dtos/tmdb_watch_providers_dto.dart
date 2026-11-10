import 'package:json_annotation/json_annotation.dart';

part 'tmdb_watch_providers_dto.g.dart';

/// `"watch/providers": {results: {<ISO 3166-1>: {...}}}` — note the
/// literal `/` in TMDB's own JSON key, and that `results` is a *map*
/// keyed by region, not a list (every other `append_to_response` block
/// this app reads is a list). Identical shape on `/movie/{id}` and
/// `/tv/{id}`.
@JsonSerializable(createToJson: false)
class TmdbWatchProvidersDto {
  const TmdbWatchProvidersDto({required this.results});

  final Map<String, TmdbWatchProviderRegionDto> results;

  factory TmdbWatchProvidersDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbWatchProvidersDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TmdbWatchProviderRegionDto {
  const TmdbWatchProviderRegionDto({
    required this.link,
    required this.flatrate,
    required this.rent,
    required this.buy,
  });

  final String? link;

  @JsonKey(defaultValue: <TmdbWatchProviderRefDto>[])
  final List<TmdbWatchProviderRefDto> flatrate;

  @JsonKey(defaultValue: <TmdbWatchProviderRefDto>[])
  final List<TmdbWatchProviderRefDto> rent;

  @JsonKey(defaultValue: <TmdbWatchProviderRefDto>[])
  final List<TmdbWatchProviderRefDto> buy;

  factory TmdbWatchProviderRegionDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbWatchProviderRegionDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TmdbWatchProviderRefDto {
  const TmdbWatchProviderRefDto({required this.providerName, this.logoPath});

  @JsonKey(name: 'provider_name')
  final String providerName;

  /// The service's logo (`/abc.png`), or `null` when TMDB has none.
  @JsonKey(name: 'logo_path')
  final String? logoPath;

  factory TmdbWatchProviderRefDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbWatchProviderRefDtoFromJson(json);
}
