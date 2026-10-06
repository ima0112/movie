import 'package:json_annotation/json_annotation.dart';

part 'tmdb_video_dto.g.dart';

/// `videos: {results: [...]}` — identical shape on both `/movie/{id}`
/// and `/tv/{id}`'s `append_to_response`.
@JsonSerializable(createToJson: false)
class TmdbVideosDto {
  const TmdbVideosDto({required this.results});

  final List<TmdbVideoDto> results;

  factory TmdbVideosDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbVideosDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TmdbVideoDto {
  const TmdbVideoDto({
    required this.key,
    required this.site,
    required this.type,
    required this.name,
    required this.official,
    required this.iso6391,
  });

  final String key;
  final String site;
  final String type;
  final String name;
  final bool official;

  @JsonKey(name: 'iso_639_1', defaultValue: '')
  final String iso6391;

  factory TmdbVideoDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbVideoDtoFromJson(json);
}
