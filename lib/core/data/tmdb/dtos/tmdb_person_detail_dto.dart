import 'package:json_annotation/json_annotation.dart';

import 'tmdb_movie_list_item_dto.dart';
import 'tmdb_tv_list_item_dto.dart';

part 'tmdb_person_detail_dto.g.dart';

/// `/person/{id}?append_to_response=movie_credits,tv_credits` — one call,
/// per `docs/DECISIONS.md` §2.
@JsonSerializable(createToJson: false)
class TmdbPersonDetailDto {
  const TmdbPersonDetailDto({
    required this.id,
    required this.name,
    required this.knownForDepartment,
    required this.biography,
    required this.birthday,
    required this.deathday,
    required this.placeOfBirth,
    required this.profilePath,
    required this.movieCredits,
    required this.tvCredits,
  });

  final int id;
  final String name;

  @JsonKey(name: 'known_for_department')
  final String? knownForDepartment;

  @JsonKey(defaultValue: '')
  final String biography;

  @JsonKey(defaultValue: '')
  final String birthday;

  @JsonKey(defaultValue: '')
  final String deathday;

  @JsonKey(name: 'place_of_birth')
  final String? placeOfBirth;

  @JsonKey(name: 'profile_path')
  final String? profilePath;

  @JsonKey(name: 'movie_credits')
  final TmdbPersonMovieCreditsDto movieCredits;

  @JsonKey(name: 'tv_credits')
  final TmdbPersonTvCreditsDto tvCredits;

  factory TmdbPersonDetailDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbPersonDetailDtoFromJson(json);
}

/// `movie_credits: {cast: [...], crew: [...]}` — each entry is a regular
/// movie list item plus `character`/`job`
/// (`TmdbMovieListItemDto`'s own doc comment).
@JsonSerializable(createToJson: false)
class TmdbPersonMovieCreditsDto {
  const TmdbPersonMovieCreditsDto({required this.cast, required this.crew});

  @JsonKey(defaultValue: <TmdbMovieListItemDto>[])
  final List<TmdbMovieListItemDto> cast;

  @JsonKey(defaultValue: <TmdbMovieListItemDto>[])
  final List<TmdbMovieListItemDto> crew;

  factory TmdbPersonMovieCreditsDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbPersonMovieCreditsDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TmdbPersonTvCreditsDto {
  const TmdbPersonTvCreditsDto({required this.cast, required this.crew});

  @JsonKey(defaultValue: <TmdbTvListItemDto>[])
  final List<TmdbTvListItemDto> cast;

  @JsonKey(defaultValue: <TmdbTvListItemDto>[])
  final List<TmdbTvListItemDto> crew;

  factory TmdbPersonTvCreditsDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbPersonTvCreditsDtoFromJson(json);
}
