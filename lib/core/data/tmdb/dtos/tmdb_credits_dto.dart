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

/// `aggregate_credits: {cast: [...], crew: [...]}` on `/tv/{id}` — the whole
/// run's people, unlike `credits` (which for a TV show is only the latest
/// season's regulars: a handful of cast and no crew at all).
@JsonSerializable(createToJson: false)
class TmdbAggregateCreditsDto {
  const TmdbAggregateCreditsDto({required this.cast, required this.crew});

  @JsonKey(defaultValue: <TmdbAggregateCastDto>[])
  final List<TmdbAggregateCastDto> cast;

  @JsonKey(defaultValue: <TmdbAggregateCrewDto>[])
  final List<TmdbAggregateCrewDto> crew;

  factory TmdbAggregateCreditsDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbAggregateCreditsDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TmdbAggregateCastDto {
  const TmdbAggregateCastDto({
    required this.id,
    required this.name,
    required this.profilePath,
    required this.knownForDepartment,
    required this.roles,
    required this.order,
  });

  final int id;
  final String name;

  @JsonKey(name: 'profile_path')
  final String? profilePath;

  @JsonKey(name: 'known_for_department')
  final String? knownForDepartment;

  /// One entry per character played, with its episode count.
  @JsonKey(defaultValue: <TmdbAggregateRoleDto>[])
  final List<TmdbAggregateRoleDto> roles;

  @JsonKey(defaultValue: 0)
  final int order;

  factory TmdbAggregateCastDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbAggregateCastDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TmdbAggregateRoleDto {
  const TmdbAggregateRoleDto({
    required this.character,
    required this.episodeCount,
  });

  @JsonKey(defaultValue: '')
  final String character;

  @JsonKey(name: 'episode_count', defaultValue: 0)
  final int episodeCount;

  factory TmdbAggregateRoleDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbAggregateRoleDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TmdbAggregateCrewDto {
  const TmdbAggregateCrewDto({
    required this.id,
    required this.name,
    required this.profilePath,
    required this.knownForDepartment,
    required this.jobs,
    required this.department,
  });

  final int id;
  final String name;

  @JsonKey(name: 'profile_path')
  final String? profilePath;

  @JsonKey(name: 'known_for_department')
  final String? knownForDepartment;

  /// One entry per job held, with its episode count.
  @JsonKey(defaultValue: <TmdbAggregateJobDto>[])
  final List<TmdbAggregateJobDto> jobs;

  @JsonKey(defaultValue: '')
  final String department;

  factory TmdbAggregateCrewDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbAggregateCrewDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TmdbAggregateJobDto {
  const TmdbAggregateJobDto({required this.job, required this.episodeCount});

  @JsonKey(defaultValue: '')
  final String job;

  @JsonKey(name: 'episode_count', defaultValue: 0)
  final int episodeCount;

  factory TmdbAggregateJobDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbAggregateJobDtoFromJson(json);
}
