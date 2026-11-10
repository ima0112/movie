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
    this.voteAverage,
    this.guestStars = const [],
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

  /// TMDB's average rating; `0` (or missing) when nobody has voted.
  @JsonKey(name: 'vote_average')
  final double? voteAverage;

  @JsonKey(name: 'guest_stars', defaultValue: <TmdbGuestStarDto>[])
  final List<TmdbGuestStarDto> guestStars;

  factory TmdbEpisodeDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbEpisodeDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TmdbGuestStarDto {
  const TmdbGuestStarDto({
    required this.id,
    required this.name,
    this.character = '',
    this.profilePath,
    this.order = 0,
  });

  final int id;
  final String name;

  @JsonKey(defaultValue: '')
  final String character;

  @JsonKey(name: 'profile_path')
  final String? profilePath;

  @JsonKey(defaultValue: 0)
  final int order;

  factory TmdbGuestStarDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbGuestStarDtoFromJson(json);
}
