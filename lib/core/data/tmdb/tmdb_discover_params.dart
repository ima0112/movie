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
  String? watchRegion,
}) {
  final isMovie = type == MediaType.movie;
  final params = <String, dynamic>{
    'include_adult': false,
    // H8 (docs/SCREENS.md): "minimum rating (0-9 slider, vote_count.gte
    // =100 fixed)" — fixed regardless of the slider's own value. Not
    // hardcoded here anymore: DiscoverFilter.minVoteCount carries it
    // (default 100, same as before, so Discover/Explore/C1 don't
    // change), and MatchEngine._filterForVibe is the one real caller
    // that varies it.
    'vote_count.gte': filter.minVoteCount,
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

  if (filter.withKeywords.isNotEmpty) {
    // Same OR-via-pipe form as with_genres (DiscoverFilter.withKeywords'
    // own doc comment) — a different TMDB parameter, so it still ANDs
    // with with_genres/without_genres regardless.
    params['with_keywords'] = filter.withKeywords.join('|');
  }

  final dateField = isMovie ? 'primary_release_date' : 'first_air_date';
  if (filter.yearFrom != null) {
    params['$dateField.gte'] = '${filter.yearFrom}-01-01';
  }
  if (filter.yearTo != null) {
    params['$dateField.lte'] = '${filter.yearTo}-12-31';
  }

  // An exact window wins over the whole-year bounds above.
  if (filter.releasedFrom case final from?) {
    params['$dateField.gte'] = _isoDate(from);
  }
  if (filter.releasedTo case final to?) {
    params['$dateField.lte'] = _isoDate(to);
  }

  if (filter.maxVoteCount != null) {
    params['vote_count.lte'] = filter.maxVoteCount;
  }

  // A provider filter only means something within a region.
  if (filter.withWatchProviders.isNotEmpty && watchRegion != null) {
    params['with_watch_providers'] = filter.withWatchProviders.join('|');
    params['watch_region'] = watchRegion;
  }

  if (filter.minVoteAverage != null) {
    params['vote_average.gte'] = filter.minVoteAverage;
  }
  if (filter.maxVoteAverage != null) {
    params['vote_average.lte'] = filter.maxVoteAverage;
  }

  if (filter.originalLanguage != null) {
    params['with_original_language'] = filter.originalLanguage;
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

String _isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

String _sortBy(DiscoverSortBy sortBy, bool isMovie) => switch (sortBy) {
  DiscoverSortBy.popularity => 'popularity.desc',
  DiscoverSortBy.rating => 'vote_average.desc',
  DiscoverSortBy.releaseDate =>
    isMovie ? 'primary_release_date.desc' : 'first_air_date.desc',
  DiscoverSortBy.releaseDateAsc =>
    isMovie ? 'primary_release_date.asc' : 'first_air_date.asc',
  // Careful: TMDB sorts by the *original* title, not the localized one the
  // user sees, and stops at page 500 (10,000 results, about the letter M of a
  // big catalog) — so the app offers no alphabetical order.
  DiscoverSortBy.title => isMovie ? 'title.asc' : 'name.asc',
  // The most voted of all time — the "Popular" classics, unlike
  // `popularity`, which is TMDB's rolling current-interest figure.
  DiscoverSortBy.voteCount => 'vote_count.desc',
};
