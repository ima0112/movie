import 'package:json_annotation/json_annotation.dart';

part 'tmdb_movie_list_item_dto.g.dart';

/// One entry of `/movie/now_playing`, `/movie/top_rated`,
/// `/movie/upcoming` — and, read straight off the raw JSON rather than
/// through this `fromJson`'s own generated parsing path, a movie-typed
/// entry of `/trending/all/week`/`/search/multi` too (same fields;
/// `mediaType` is only ever populated for those — see
/// `tmdb_media_datasource.dart`). Also doubles as one entry of
/// `/person/{id}`'s own `movie_credits.cast`/`.crew` — `character`/`job`
/// are only ever populated there.
@JsonSerializable(createToJson: false)
class TmdbMovieListItemDto {
  const TmdbMovieListItemDto({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.genreIds,
    required this.releaseDate,
    required this.voteAverage,
    this.backdropPath,
    this.voteCount,
    this.popularity,
    this.mediaType,
    this.character,
    this.job,
  });

  final int id;
  final String title;

  @JsonKey(name: 'poster_path')
  final String? posterPath;

  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;

  @JsonKey(name: 'genre_ids', defaultValue: <int>[])
  final List<int> genreIds;

  /// `"2024-11-13"`, or empty when TMDB has no date yet (an unreleased
  /// title) — `tmdb_mappers.dart` parses this, not this DTO.
  @JsonKey(name: 'release_date', defaultValue: '')
  final String releaseDate;

  @JsonKey(name: 'vote_average', defaultValue: 0.0)
  final double voteAverage;

  @JsonKey(name: 'vote_count')
  final int? voteCount;

  final double? popularity;

  /// Only present on `/trending/all/week` entries — `"movie"`, `"tv"`,
  /// or `"person"`. `null` on every type-specific endpoint.
  @JsonKey(name: 'media_type')
  final String? mediaType;

  /// Only present in `/person/{id}`'s own `movie_credits.cast`.
  final String? character;

  /// Only present in `/person/{id}`'s own `movie_credits.crew`.
  final String? job;

  factory TmdbMovieListItemDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbMovieListItemDtoFromJson(json);
}
