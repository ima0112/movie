import '../../domain/entities/genre.dart';
import '../../domain/entities/media_item.dart';
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
    genres: _genresFor(dto.genreIds, MediaType.movie),
    releaseDate: _parseDate(dto.releaseDate),
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
    genres: _genresFor(dto.genreIds, MediaType.tvShow),
    releaseDate: _parseDate(dto.firstAirDate),
    voteAverage: dto.voteAverage,
  );
}

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

List<Genre> _genresFor(List<int> tmdbGenreIds, MediaType type) {
  return tmdbGenreIds
      .map((id) => TmdbGenreMapper.fromTmdbId(id, type))
      .nonNulls
      .toList();
}

/// `""` (TMDB's own "no date yet" shape for an unreleased title) and any
/// otherwise-unparseable string both become `null`, matching
/// [MediaItem.releaseDate]'s own documented contract.
DateTime? _parseDate(String value) {
  if (value.isEmpty) return null;
  return DateTime.tryParse(value);
}
