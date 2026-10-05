import 'package:json_annotation/json_annotation.dart';

part 'tmdb_paged_response_dto.g.dart';

/// TMDB's standard `{page, results, total_pages, total_results}` envelope
/// — every list endpoint this app calls (`/movie/now_playing`,
/// `/tv/popular`, etc.) returns this shape around a different `results`
/// item type, hence the generic + `genericArgumentFactories`.
///
/// `/trending/all/week` does NOT use this wrapper as-is in this app —
/// its `results` mixes movies, TV shows, and people (TMDB's own
/// `media_type` discriminator), which `TmdbMediaDatasource` handles by
/// reading the raw JSON list directly instead of through this generic
/// type. See `tmdb_media_datasource.dart`.
@JsonSerializable(genericArgumentFactories: true, createToJson: false)
class TmdbPagedResponseDto<T> {
  const TmdbPagedResponseDto({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  final int page;
  final List<T> results;

  @JsonKey(name: 'total_pages')
  final int totalPages;

  @JsonKey(name: 'total_results')
  final int totalResults;

  factory TmdbPagedResponseDto.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$TmdbPagedResponseDtoFromJson(json, fromJsonT);
}
