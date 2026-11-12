// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_tv_list_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbTvListItemDto _$TmdbTvListItemDtoFromJson(Map<String, dynamic> json) =>
    TmdbTvListItemDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      posterPath: json['poster_path'] as String?,
      genreIds:
          (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      firstAirDate: json['first_air_date'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      backdropPath: json['backdrop_path'] as String?,
      voteCount: (json['vote_count'] as num?)?.toInt(),
      popularity: (json['popularity'] as num?)?.toDouble(),
      mediaType: json['media_type'] as String?,
      character: json['character'] as String?,
      job: json['job'] as String?,
    );
