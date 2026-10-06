import 'package:json_annotation/json_annotation.dart';

part 'tmdb_credits_dto.g.dart';

/// `credits: {cast: [...], crew: [...]}` — identical shape on both
/// `/movie/{id}` and `/tv/{id}`'s `append_to_response`, hence shared.
@JsonSerializable(createToJson: false)
class TmdbCreditsDto {
  const TmdbCreditsDto({required this.cast, required this.crew});

  final List<TmdbCastMemberDto> cast;
  final List<TmdbCrewMemberDto> crew;

  factory TmdbCreditsDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbCreditsDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TmdbCastMemberDto {
  const TmdbCastMemberDto({
    required this.id,
    required this.name,
    required this.profilePath,
    required this.knownForDepartment,
    required this.character,
    required this.order,
  });

  final int id;
  final String name;

  @JsonKey(name: 'profile_path')
  final String? profilePath;

  @JsonKey(name: 'known_for_department')
  final String? knownForDepartment;

  final String character;
  final int order;

  factory TmdbCastMemberDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbCastMemberDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TmdbCrewMemberDto {
  const TmdbCrewMemberDto({
    required this.id,
    required this.name,
    required this.profilePath,
    required this.knownForDepartment,
    required this.job,
    required this.department,
  });

  final int id;
  final String name;

  @JsonKey(name: 'profile_path')
  final String? profilePath;

  @JsonKey(name: 'known_for_department')
  final String? knownForDepartment;

  final String job;
  final String department;

  factory TmdbCrewMemberDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbCrewMemberDtoFromJson(json);
}
