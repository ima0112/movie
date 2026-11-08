import 'package:json_annotation/json_annotation.dart';

part 'tmdb_tv_list_item_dto.g.dart';

/// One entry of `/tv/on_the_air`, `/tv/top_rated`, `/tv/popular` — and a
/// tv-typed entry of `/trending/all/week` (see `TmdbMovieListItemDto`'s
/// own doc comment; the same applies here, mirrored for TV's different
/// field names: `name` instead of `title`, `first_air_date` instead of
/// `release_date`).
@JsonSerializable(createToJson: false)
class TmdbTvListItemDto {
  const TmdbTvListItemDto({
    required this.id,
    required this.name,
    required this.posterPath,
    required this.genreIds,
    required this.firstAirDate,
    required this.voteAverage,
    this.mediaType,
  });

  final int id;
  final String name;

  @JsonKey(name: 'poster_path')
  final String? posterPath;

  @JsonKey(name: 'genre_ids', defaultValue: <int>[])
  final List<int> genreIds;

  @JsonKey(name: 'first_air_date', defaultValue: '')
  final String firstAirDate;

  @JsonKey(name: 'vote_average', defaultValue: 0.0)
  final double voteAverage;

  @JsonKey(name: 'media_type')
  final String? mediaType;

  factory TmdbTvListItemDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbTvListItemDtoFromJson(json);
}
