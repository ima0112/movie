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
