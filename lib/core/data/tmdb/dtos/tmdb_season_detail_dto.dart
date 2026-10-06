import 'package:json_annotation/json_annotation.dart';

part 'tmdb_season_detail_dto.g.dart';

/// `/tv/{id}/season/{n}` — fetched on demand (D2's "Seasons" section,
/// per `docs/DECISIONS.md` §2: "seasons on demand via
/// `/tv/{id}/season/{n}`"), never bundled into `/tv/{id}` itself.
@JsonSerializable(createToJson: false)
class TmdbSeasonDetailDto {
  const TmdbSeasonDetailDto({
    required this.seasonNumber,
    required this.name,
    required this.overview,
    required this.episodes,
  });

  @JsonKey(name: 'season_number')
  final int seasonNumber;

  final String name;

  @JsonKey(defaultValue: '')
  final String overview;

  final List<TmdbEpisodeDto> episodes;

  factory TmdbSeasonDetailDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbSeasonDetailDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TmdbEpisodeDto {
  const TmdbEpisodeDto({
    required this.episodeNumber,
    required this.name,
    required this.overview,
    required this.stillPath,
    required this.airDate,
    required this.runtime,
  });

  @JsonKey(name: 'episode_number')
  final int episodeNumber;

  final String name;

  @JsonKey(defaultValue: '')
  final String overview;

  @JsonKey(name: 'still_path')
  final String? stillPath;

  @JsonKey(name: 'air_date', defaultValue: '')
  final String airDate;

  final int? runtime;

  factory TmdbEpisodeDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbEpisodeDtoFromJson(json);
}
