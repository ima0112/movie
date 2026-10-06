import 'package:json_annotation/json_annotation.dart';

part 'tmdb_genre_ref_dto.g.dart';

/// `/movie/{id}` and `/tv/{id}`'s own `genres: [{id, name}]` — a
/// different shape than the list endpoints' `genre_ids: [int]`
/// (`tmdb_movie_list_item_dto.dart`/`tmdb_tv_list_item_dto.dart`), hence
/// its own small DTO shared by both detail endpoints.
@JsonSerializable(createToJson: false)
class TmdbGenreRefDto {
  const TmdbGenreRefDto({required this.id, required this.name});

  final int id;
  final String name;

  factory TmdbGenreRefDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbGenreRefDtoFromJson(json);
}
