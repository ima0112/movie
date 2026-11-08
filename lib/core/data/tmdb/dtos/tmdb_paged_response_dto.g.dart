// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_paged_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbPagedResponseDto<T> _$TmdbPagedResponseDtoFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => TmdbPagedResponseDto<T>(
  page: (json['page'] as num).toInt(),
  results: (json['results'] as List<dynamic>).map(fromJsonT).toList(),
  totalPages: (json['total_pages'] as num).toInt(),
  totalResults: (json['total_results'] as num).toInt(),
);
