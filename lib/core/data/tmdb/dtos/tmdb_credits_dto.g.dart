// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_credits_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbCreditsDto _$TmdbCreditsDtoFromJson(Map<String, dynamic> json) =>
    TmdbCreditsDto(
      cast: (json['cast'] as List<dynamic>)
          .map((e) => TmdbCastMemberDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      crew: (json['crew'] as List<dynamic>)
          .map((e) => TmdbCrewMemberDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

TmdbCastMemberDto _$TmdbCastMemberDtoFromJson(Map<String, dynamic> json) =>
    TmdbCastMemberDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      profilePath: json['profile_path'] as String?,
      knownForDepartment: json['known_for_department'] as String?,
      character: json['character'] as String,
      order: (json['order'] as num).toInt(),
    );

TmdbCrewMemberDto _$TmdbCrewMemberDtoFromJson(Map<String, dynamic> json) =>
    TmdbCrewMemberDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      profilePath: json['profile_path'] as String?,
      knownForDepartment: json['known_for_department'] as String?,
      job: json['job'] as String,
      department: json['department'] as String,
    );

TmdbAggregateCreditsDto _$TmdbAggregateCreditsDtoFromJson(
  Map<String, dynamic> json,
) => TmdbAggregateCreditsDto(
  cast:
      (json['cast'] as List<dynamic>?)
          ?.map((e) => TmdbAggregateCastDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  crew:
      (json['crew'] as List<dynamic>?)
          ?.map((e) => TmdbAggregateCrewDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

TmdbAggregateCastDto _$TmdbAggregateCastDtoFromJson(
  Map<String, dynamic> json,
) => TmdbAggregateCastDto(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  profilePath: json['profile_path'] as String?,
  knownForDepartment: json['known_for_department'] as String?,
  roles:
      (json['roles'] as List<dynamic>?)
          ?.map((e) => TmdbAggregateRoleDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  order: (json['order'] as num?)?.toInt() ?? 0,
);

TmdbAggregateRoleDto _$TmdbAggregateRoleDtoFromJson(
  Map<String, dynamic> json,
) => TmdbAggregateRoleDto(
  character: json['character'] as String? ?? '',
  episodeCount: (json['episode_count'] as num?)?.toInt() ?? 0,
);

TmdbAggregateCrewDto _$TmdbAggregateCrewDtoFromJson(
  Map<String, dynamic> json,
) => TmdbAggregateCrewDto(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  profilePath: json['profile_path'] as String?,
  knownForDepartment: json['known_for_department'] as String?,
  jobs:
      (json['jobs'] as List<dynamic>?)
          ?.map((e) => TmdbAggregateJobDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  department: json['department'] as String? ?? '',
);

TmdbAggregateJobDto _$TmdbAggregateJobDtoFromJson(Map<String, dynamic> json) =>
    TmdbAggregateJobDto(
      job: json['job'] as String? ?? '',
      episodeCount: (json['episode_count'] as num?)?.toInt() ?? 0,
    );
