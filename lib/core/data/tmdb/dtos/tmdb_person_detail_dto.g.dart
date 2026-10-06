// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_person_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbPersonDetailDto _$TmdbPersonDetailDtoFromJson(Map<String, dynamic> json) =>
    TmdbPersonDetailDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      knownForDepartment: json['known_for_department'] as String?,
      biography: json['biography'] as String? ?? '',
      birthday: json['birthday'] as String? ?? '',
      deathday: json['deathday'] as String? ?? '',
      placeOfBirth: json['place_of_birth'] as String?,
      profilePath: json['profile_path'] as String?,
      movieCredits: TmdbPersonMovieCreditsDto.fromJson(
        json['movie_credits'] as Map<String, dynamic>,
      ),
      tvCredits: TmdbPersonTvCreditsDto.fromJson(
        json['tv_credits'] as Map<String, dynamic>,
      ),
    );

TmdbPersonMovieCreditsDto _$TmdbPersonMovieCreditsDtoFromJson(
  Map<String, dynamic> json,
) => TmdbPersonMovieCreditsDto(
  cast:
      (json['cast'] as List<dynamic>?)
          ?.map((e) => TmdbMovieListItemDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  crew:
      (json['crew'] as List<dynamic>?)
          ?.map((e) => TmdbMovieListItemDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

TmdbPersonTvCreditsDto _$TmdbPersonTvCreditsDtoFromJson(
  Map<String, dynamic> json,
) => TmdbPersonTvCreditsDto(
  cast:
      (json['cast'] as List<dynamic>?)
          ?.map((e) => TmdbTvListItemDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  crew:
      (json['crew'] as List<dynamic>?)
          ?.map((e) => TmdbTvListItemDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);
