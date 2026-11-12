import '../../domain/entities/genre.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/entities/streaming_service.dart';
import '../../domain/entities/person.dart';
import '../../domain/entities/media_type.dart';
import 'dtos/tmdb_movie_list_item_dto.dart';
import 'dtos/tmdb_tv_list_item_dto.dart';
import 'tmdb_genre_mapper.dart';
import 'tmdb_image_urls.dart';

/// DTO → [MediaItem] — CLAUDE.md rule 3: custom domain models only past
/// this point, never a TMDB DTO. [imagesConfig] is passed in (not read
/// from `TmdbConfigurationService` here) so these stay plain, easily
/// unit-testable functions — the repository is the one place that holds
/// the service and passes its `current` config through.
///
/// A genre id with no [TmdbGenreMapper] equivalent is silently dropped,
/// not an error — see that mapper's own doc comment.
Movie mediaItemFromMovieDto(
  TmdbMovieListItemDto dto, {
  required TmdbImagesConfig imagesConfig,
}) {
  return Movie(
    id: dto.id,
    title: dto.title,
    posterUrl: buildTmdbImageUrl(
      config: imagesConfig,
      kind: TmdbImageKind.poster,
      path: dto.posterPath,
      size: TmdbImageSizes.posterMedium,
    ),
    backdropUrl: _listBackdropUrl(dto.backdropPath, imagesConfig),
    genres: genresFromTmdbIds(dto.genreIds, MediaType.movie),
    releaseDate: parseTmdbDate(dto.releaseDate),
    voteAverage: dto.voteAverage,
  );
}

TvShow mediaItemFromTvDto(
  TmdbTvListItemDto dto, {
  required TmdbImagesConfig imagesConfig,
}) {
  return TvShow(
    id: dto.id,
    title: dto.name,
    posterUrl: buildTmdbImageUrl(
      config: imagesConfig,
      kind: TmdbImageKind.poster,
      path: dto.posterPath,
      size: TmdbImageSizes.posterMedium,
    ),
    backdropUrl: _listBackdropUrl(dto.backdropPath, imagesConfig),
    genres: genresFromTmdbIds(dto.genreIds, MediaType.tvShow),
    releaseDate: parseTmdbDate(dto.firstAirDate),
    voteAverage: dto.voteAverage,
  );
}

/// A list item's backdrop at the "medium" (w780) size — wide enough for a
/// ~300 px card at 2x.
String? _listBackdropUrl(String? path, TmdbImagesConfig config) =>
    buildTmdbImageUrl(
      config: config,
      kind: TmdbImageKind.backdrop,
      path: path,
      size: TmdbImageSizes.backdropMedium,
    );

/// `/trending/all/week`'s own entries carry a `media_type` TMDB uses to
/// tell movies, TV shows, and people apart in one mixed list — read
/// directly off the raw JSON (not through either list-item DTO's own
/// `fromJson`) since nothing else in this app needs a dedicated
/// "trending item" DTO for just this one field. Returns `null` for a
/// `"person"` entry (and for anything else unrecognized) — this app
/// doesn't show people in Discover.
MediaItem? mediaItemFromTrendingJson(
  Map<String, dynamic> json, {
  required TmdbImagesConfig imagesConfig,
}) {
  return switch (json['media_type']) {
    'movie' => mediaItemFromMovieDto(
      TmdbMovieListItemDto.fromJson(json),
      imagesConfig: imagesConfig,
    ),
    'tv' => mediaItemFromTvDto(
      TmdbTvListItemDto.fromJson(json),
      imagesConfig: imagesConfig,
    ),
    _ => null,
  };
}

/// One `/search/multi` entry as a [SearchResult]: a movie or TV show through
/// [mediaItemFromTrendingJson], or a `"person"` as a [PersonResult] (id, name,
/// photo path, known-for department). `null` for anything else.
SearchResult? searchResultFromJson(
  Map<String, dynamic> json, {
  required TmdbImagesConfig imagesConfig,
}) {
  if (json['media_type'] == 'person') {
    final name = json['name'];
    final id = json['id'];
    if (name is! String || id is! int) return null;
    return PersonResult(
      Person(
        id: id,
        name: name,
        profilePath: json['profile_path'] as String?,
        knownForDepartment: json['known_for_department'] as String?,
      ),
    );
  }
  final item = mediaItemFromTrendingJson(json, imagesConfig: imagesConfig);
  return item == null ? null : MediaResult(item);
}

/// `/watch/providers/{type}` entries as [StreamingService]s: duplicates across
/// movie and TV merged by id, most relevant first (TMDB's `display_priority`,
/// then name), at most [limit]. The logo uses the same `w92` size as D1/D2's
/// own provider logos.
List<StreamingService> streamingServicesFromJson(
  List<Map<String, dynamic>> raw, {
  required TmdbImagesConfig imagesConfig,
  required int limit,
}) {
  final byId = <int, ({StreamingService service, int priority})>{};
  for (final json in raw) {
    final id = json['provider_id'];
    final name = json['provider_name'];
    if (id is! int || name is! String) continue;
    final priority = (json['display_priority'] as num?)?.toInt() ?? 1 << 20;
    final existing = byId[id];
    if (existing != null && existing.priority <= priority) continue;
    byId[id] = (
      service: StreamingService(
        id: id,
        name: name,
        logoUrl: buildTmdbImageUrl(
          config: imagesConfig,
          kind: TmdbImageKind.poster,
          path: json['logo_path'] as String?,
          size: 'w92',
        ),
      ),
      priority: priority,
    );
  }
  final sorted = byId.values.toList()
    ..sort((a, b) {
      final byPriority = a.priority.compareTo(b.priority);
      return byPriority != 0
          ? byPriority
          : a.service.name.compareTo(b.service.name);
    });
  return [for (final e in sorted.take(limit)) e.service];
}

/// Public (not just this file's own concern): `tmdb_detail_mappers.dart`
/// reuses this for D1/D2's own `genres: [{id, name}]` ids too.
List<Genre> genresFromTmdbIds(List<int> tmdbGenreIds, MediaType type) {
  return tmdbGenreIds
      .map((id) => TmdbGenreMapper.fromTmdbId(id, type))
      .nonNulls
      .toList();
}

/// `""` (TMDB's own "no date yet" shape for an unreleased title) and any
/// otherwise-unparseable string both become `null`, matching
/// [MediaItem.releaseDate]'s own documented contract. Public: reused by
/// `tmdb_detail_mappers.dart` for every other TMDB date string (release
/// dates, air dates...).
DateTime? parseTmdbDate(String value) {
  if (value.isEmpty) return null;
  return DateTime.tryParse(value);
}
