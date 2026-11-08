// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_movie_list_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbMovieListItemDto _$TmdbMovieListItemDtoFromJson(
  Map<String, dynamic> json,
) => TmdbMovieListItemDto(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  posterPath: json['poster_path'] as String?,
  genreIds:
      (json['genre_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  releaseDate: json['release_date'] as String? ?? '',
  voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
  mediaType: json['media_type'] as String?,
  character: json['character'] as String?,
  job: json['job'] as String?,
);
