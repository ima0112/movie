import '../../domain/entities/discover_filter.dart';
import '../../domain/entities/media_type.dart';
import 'tmdb_genre_mapper.dart';

/// [DiscoverFilter] → `/discover/{movie|tv}`'s own query parameters —
/// pure translation, no network, easily unit-tested per field.
///
/// Always built for one concrete [type] — `DiscoverFilter.type == null`
/// ("All", C1: "both interleaved") has no single `/discover` call of its
/// own; `TmdbMediaRepository.discover` calls this twice (once per type)
/// and merges, the same pattern `getHeroItems`'s own "All" composition
/// already uses.
Map<String, dynamic> discoverQueryParams(
  DiscoverFilter filter, {
  required MediaType type,
}) {
  final isMovie = type == MediaType.movie;
  final params = <String, dynamic>{
    'include_adult': false,
    // H8 (docs/SCREENS.md): "minimum rating (0-9 slider, vote_count.gte
    // =100 fixed)" — fixed regardless of the slider's own value.
    'vote_count.gte': 100,
    'sort_by': _sortBy(filter.sortBy, isMovie),
  };

  final withGenreIds = filter.withGenres
      .map((g) => TmdbGenreMapper.toTmdbId(g, type))
      .nonNulls
      .toList();
  if (withGenreIds.isNotEmpty) {
    // DiscoverFilter.withGenres' own doc comment: "an item matching
    // *any* of these qualifies" — TMDB's with_genres is AND by default
    // with commas; pipe-separated is its OR form.
    params['with_genres'] = withGenreIds.join('|');
  }

  final withoutGenreIds = filter.withoutGenres
      .map((g) => TmdbGenreMapper.toTmdbId(g, type))
      .nonNulls
      .toList();
  if (withoutGenreIds.isNotEmpty) {
    params['without_genres'] = withoutGenreIds.join(',');
  }

  final dateField = isMovie ? 'primary_release_date' : 'first_air_date';
  if (filter.yearFrom != null) {
    params['$dateField.gte'] = '${filter.yearFrom}-01-01';
  }
  if (filter.yearTo != null) {
    params['$dateField.lte'] = '${filter.yearTo}-12-31';
  }

  if (filter.minVoteAverage != null) {
    params['vote_average.gte'] = filter.minVoteAverage;
  }

  // Movies only — DiscoverFilter.maxRuntimeMinutes' own doc comment:
  // "meaningless for a TV filter."
  if (isMovie && filter.maxRuntimeMinutes != null) {
    params['with_runtime.lte'] = filter.maxRuntimeMinutes;
  }

  // TV only — DiscoverFilter.tvStatus' own doc comment: "TV shows only".
  // TMDB's with_status is a numeric code with more values than H8
  // exposes; 0 (Returning Series) and 3 (Ended) are the two closest to
  // "Airing"/"Ended" themselves.
  if (!isMovie && filter.tvStatus != null) {
    params['with_status'] = switch (filter.tvStatus!) {
      DiscoverTvStatus.airing => '0',
      DiscoverTvStatus.ended => '3',
    };
  }

  return params;
}

String _sortBy(DiscoverSortBy sortBy, bool isMovie) => switch (sortBy) {
  DiscoverSortBy.popularity => 'popularity.desc',
  DiscoverSortBy.rating => 'vote_average.desc',
  DiscoverSortBy.releaseDate =>
    isMovie ? 'primary_release_date.desc' : 'first_air_date.desc',
  // The *localized* title (not original_title), per DiscoverSortBy's own
  // "Title" — a user sorting alphabetically expects the title they're
  // shown, not whatever language TMDB first logged it in.
  DiscoverSortBy.title => isMovie ? 'title.asc' : 'name.asc',
};
