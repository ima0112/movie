import '../../domain/entities/collection_query.dart';
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

  // On TV the likes are TMDB's own TV genres (a genre TMDB's TV list lacks is
  // asked for by keyword — see [discoverQueryParamSets]); in movies every
  // genre has its id.
  final withGenreIds = isMovie
      ? filter.withGenres
            .map((g) => TmdbGenreMapper.toTmdbId(g, type))
            .nonNulls
            .toList()
      : TmdbGenreMapper.tvLikeGenreIds(filter.withGenres).toList();
  if (withGenreIds.isNotEmpty) {
    // DiscoverFilter.withGenres' own doc comment: "an item matching
    // *any* of these qualifies" — TMDB's with_genres is AND by default
    // with commas; pipe-separated is its OR form.
    params['with_genres'] = withGenreIds.join('|');
  }

  // A veto on TV excludes a combined TV genre ("Action & Adventure", "Sci-Fi &
  // Fantasy") only when every genre of ours it stands for is vetoed.
  final withoutGenreIds = isMovie
      ? filter.withoutGenres
            .map((g) => TmdbGenreMapper.toTmdbId(g, type))
            .nonNulls
            .toList()
      : {
          ...TmdbGenreMapper.tvVetoGenreIds(filter.withoutGenres),
          if (filter.excludeTalkAndNews) ..._tvTalkAndNewsGenreIds,
        }.toList();
  if (withoutGenreIds.isNotEmpty) {
    params['without_genres'] = withoutGenreIds.join(',');
  }

  if (filter.withKeywords.isNotEmpty) {
    // Same OR-via-pipe form as with_genres (DiscoverFilter.withKeywords'
    // own doc comment) — a different TMDB parameter, so it still ANDs
    // with with_genres/without_genres regardless.
    params['with_keywords'] = filter.withKeywords.join('|');
  }

  // A TV veto for a genre TMDB's TV list lacks (Horror, Romance…) falls back
  // to a keyword — see `TmdbGenreMapper.tvVetoKeywordIds`.
  final withoutKeywordIds = {
    ...filter.withoutKeywords,
    if (!isMovie) ...TmdbGenreMapper.tvVetoKeywordIds(filter.withoutGenres),
  };
  if (withoutKeywordIds.isNotEmpty) {
    params['without_keywords'] = withoutKeywordIds.join(',');
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

  // Availability only means something within a region. Specific providers
  // narrow it to those services; monetization types alone ("any service in the
  // region, included in a plan / to rent / to buy") need no provider list.
  if (watchRegion != null &&
      (filter.withWatchProviders.isNotEmpty ||
          filter.monetizationTypes.isNotEmpty)) {
    params['watch_region'] = watchRegion;
    if (filter.withWatchProviders.isNotEmpty) {
      params['with_watch_providers'] = filter.withWatchProviders.join('|');
    }
    if (filter.monetizationTypes.isNotEmpty) {
      params['with_watch_monetization_types'] = filter.monetizationTypes
          .map((m) => m.name)
          .join('|');
    }
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

/// The `/discover` queries one [filter] needs for [type] — one for every filter
/// but a TV filter that **likes** a genre TMDB's TV list lacks (horror, romance,
/// thriller, history, music), whose keyword stand-in cannot share a request with
/// the genres TV does have: TMDB would AND the `with_genres` and `with_keywords`
/// of one request, while a like means "any of these". So that filter becomes up
/// to three requests — the native genres, the keyword stand-ins, and music's
/// (which carries its own exclusion) — whose results the repository merges.
///
/// A filter that already has `withKeywords` (a vibe's) cannot take a stand-in
/// either: both would land in the same `with_keywords`, OR-ed instead of AND-ed.
/// There the stand-in genres are left out, as they were before they existed.
///
/// A filter with a **collection** multiplies that by the collection's own
/// queries (Soaps: the keyword, or the Soap genre) and, when both name genres,
/// by the genres' combinations. For a type the collection doesn't exist on the
/// list is **empty**: nothing to ask TMDB for.
List<Map<String, dynamic>> discoverQueryParamSets(
  DiscoverFilter filter, {
  required MediaType type,
  String? watchRegion,
}) {
  final collection = filter.collection;
  if (collection == null) {
    return _plainQueryParamSets(filter, type: type, watchRegion: watchRegion);
  }
  final rule = collection.ruleFor(type);
  if (rule == null) return const [];
  final bases = _plainQueryParamSets(
    filter,
    type: type,
    watchRegion: watchRegion,
  );
  return [
    for (final base in bases)
      for (final query in rule.queries)
        ..._withCollectionQuery(base, query, filter, type),
  ];
}

List<Map<String, dynamic>> _plainQueryParamSets(
  DiscoverFilter filter, {
  required MediaType type,
  String? watchRegion,
}) {
  final single = discoverQueryParams(
    filter,
    type: type,
    watchRegion: watchRegion,
  );
  if (type == MediaType.movie || filter.withKeywords.isNotEmpty) {
    return [single];
  }
  final groups = TmdbGenreMapper.tvStandInGroups(filter.withGenres);
  if (groups.isEmpty) return [single];

  final hasNative = TmdbGenreMapper.tvLikeGenreIds(
    filter.withGenres,
  ).isNotEmpty;
  final noLikes = discoverQueryParams(
    filter.copyWith(withGenres: const {}),
    type: type,
    watchRegion: watchRegion,
  );
  return [
    if (hasNative) single,
    for (final group in groups)
      {
        ...noLikes,
        'with_keywords': group.keywordIds.join('|'),
        if (group.withoutTmdbGenreIds.isNotEmpty)
          'without_genres': {
            ...?_ids(noLikes['without_genres']),
            ...group.withoutTmdbGenreIds,
          }.join(','),
      },
  ];
}

/// [base] narrowed by one collection [query]: where it comes from, its
/// language, its format and genres, all ANDed with what [base] already asks.
///
/// Genres cannot be ANDed across two `with_genres` values, so a collection's
/// genre (Anime: Animation) and the user's picked ones (Comedy, Drama: any)
/// become one request per pair, `with_genres=a,b` (a comma is AND). A query
/// whose keywords would share `with_keywords` with a stand-in's (Soaps' "telenovela" +
/// a picked Horror) is dropped: TMDB would OR them, and the other query of that
/// collection still covers it.
List<Map<String, dynamic>> _withCollectionQuery(
  Map<String, dynamic> base,
  CollectionQuery query,
  DiscoverFilter filter,
  MediaType type,
) {
  if (query.withKeywordIds.isNotEmpty && base['with_keywords'] != null) {
    return const [];
  }
  final params = {...base};
  // Any floor but the default is the section's own (Top rated 300, New releases
  // 10, Coming soon 0) and wins; the default gives way to the collection's,
  // which is lower for small catalogs.
  if (filter.minVoteCount == const DiscoverFilter().minVoteCount) {
    params['vote_count.gte'] = query.minVoteCount;
  }
  if (query.originCountries.isNotEmpty) {
    params['with_origin_country'] = query.originCountries.join('|');
  }
  if (query.originalLanguage != null) {
    params['with_original_language'] = query.originalLanguage;
  }
  if (query.withKeywordIds.isNotEmpty) {
    params['with_keywords'] = query.withKeywordIds.join('|');
  }
  if (query.tvType != null && type == MediaType.tvShow) {
    params['with_type'] = query.tvType;
  }
  if (query.withoutTmdbGenreIds.isNotEmpty) {
    params['without_genres'] = {
      ...?_ids(base['without_genres']),
      ...query.withoutTmdbGenreIds,
    }.join(',');
  }
  if (query.withTmdbGenreIds.isEmpty) return [params];

  final alternatives = query.requireAllGenres
      ? [query.withTmdbGenreIds.join(',')]
      : [for (final id in query.withTmdbGenreIds) '$id'];
  final picked = base['with_genres'] == null
      ? const <String>[]
      : '${base['with_genres']}'.split('|');
  if (picked.isEmpty) {
    return [
      {
        ...params,
        'with_genres': alternatives.join(query.requireAllGenres ? ',' : '|'),
      },
    ];
  }
  return [
    for (final a in alternatives)
      for (final p in picked) {...params, 'with_genres': '$a,$p'},
  ];
}

/// TMDB's TV "Talk" (10767) and "News" (10763) genres.
const Set<int> _tvTalkAndNewsGenreIds = {10767, 10763};

Set<int>? _ids(Object? commaSeparated) => commaSeparated == null
    ? null
    : {for (final id in '$commaSeparated'.split(',')) int.parse(id)};
