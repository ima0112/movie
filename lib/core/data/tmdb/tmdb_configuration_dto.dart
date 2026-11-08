import 'package:json_annotation/json_annotation.dart';

part 'tmdb_configuration_dto.g.dart';

/// `GET /configuration`'s response shape — `docs/DECISIONS.md` §2:
/// "Image configuration | `GET /configuration` (cache once)". Only the
/// `images` block is modeled; `change_keys` (TMDB's own changelog
/// categories) has no use in this app.
///
/// Generated (`json_serializable`) — never leaves `data/`, per this
/// project's CLAUDE.md rule 3; `TmdbConfigurationService` maps this into
/// the plain `TmdbImagesConfig` that `shared/widgets/poster_image.dart`
/// actually consumes.
@JsonSerializable(createToJson: false)
class TmdbConfigurationDto {
  const TmdbConfigurationDto({required this.images});

  final TmdbImagesConfigDto images;

  factory TmdbConfigurationDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbConfigurationDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TmdbImagesConfigDto {
  const TmdbImagesConfigDto({
    required this.secureBaseUrl,
    required this.posterSizes,
    required this.backdropSizes,
    required this.profileSizes,
  });

  @JsonKey(name: 'secure_base_url')
  final String secureBaseUrl;

  @JsonKey(name: 'poster_sizes')
  final List<String> posterSizes;

  @JsonKey(name: 'backdrop_sizes')
  final List<String> backdropSizes;

  @JsonKey(name: 'profile_sizes')
  final List<String> profileSizes;

  factory TmdbImagesConfigDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbImagesConfigDtoFromJson(json);
}
