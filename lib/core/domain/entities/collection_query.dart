/// One `/discover` query that a [Collection] is made of: the TMDB-side facts
/// that define it (where it comes from, what language, which format…), with
/// raw TMDB ids because several of them (Kids, Reality, Soap, Talk, News)
/// have no genre of our own — they are formats or audiences, not genres.
///
/// Within one query every field is ANDed with the others, as TMDB does with
/// separate parameters; inside a field the values are alternatives (OR).
class CollectionQuery {
  const CollectionQuery({
    this.originCountries = const {},
    this.originalLanguage,
    this.withTmdbGenreIds = const {},
    this.withoutTmdbGenreIds = const {},
    this.withKeywordIds = const {},
    this.tvType,
    this.minVoteCount = 100,
    this.requireAllGenres = false,
  });

  /// ISO 3166-1 codes (`with_origin_country`, a title qualifies for any).
  final Set<String> originCountries;

  /// ISO 639-1 code (`with_original_language`); TMDB takes a single value.
  final String? originalLanguage;

  /// TMDB genre ids a title must have: any of them, or every one when
  /// [requireAllGenres] (Anime is Animation **and** Japan, not either).
  final Set<int> withTmdbGenreIds;
  final bool requireAllGenres;

  /// TMDB genre ids a title must not have (Talk 10767, News 10763, Reality
  /// 10764 keep non-fiction formats out of a country's fiction).
  final Set<int> withoutTmdbGenreIds;

  /// TMDB keyword ids, any of them (`with_keywords`).
  final Set<int> withKeywordIds;

  /// TMDB's TV `with_type` (2 miniseries, 3 reality…); TV only.
  final int? tvType;

  /// A floor for `vote_count.gte`: small catalogs (Turkish series) need a
  /// lower one than the default to have anything to show.
  final int minVoteCount;

  factory CollectionQuery.fromJson(Map<String, dynamic> json) {
    Set<int> ints(String key) => {
      for (final v in (json[key] as List?) ?? const []) (v as num).toInt(),
    };
    return CollectionQuery(
      originCountries: {
        for (final v in (json['originCountries'] as List?) ?? const [])
          v as String,
      },
      originalLanguage: json['originalLanguage'] as String?,
      withTmdbGenreIds: ints('withGenres'),
      requireAllGenres: json['requireAllGenres'] as bool? ?? false,
      withoutTmdbGenreIds: ints('withoutGenres'),
      withKeywordIds: ints('withKeywords'),
      tvType: json['tvType'] as int?,
      minVoteCount: json['minVoteCount'] as int? ?? 100,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CollectionQuery &&
      _eq(other.originCountries, originCountries) &&
      other.originalLanguage == originalLanguage &&
      _eq(other.withTmdbGenreIds, withTmdbGenreIds) &&
      other.requireAllGenres == requireAllGenres &&
      _eq(other.withoutTmdbGenreIds, withoutTmdbGenreIds) &&
      _eq(other.withKeywordIds, withKeywordIds) &&
      other.tvType == tvType &&
      other.minVoteCount == minVoteCount;

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(originCountries),
    originalLanguage,
    Object.hashAllUnordered(withTmdbGenreIds),
    requireAllGenres,
    Object.hashAllUnordered(withoutTmdbGenreIds),
    Object.hashAllUnordered(withKeywordIds),
    tvType,
    minVoteCount,
  );

  @override
  String toString() =>
      'CollectionQuery(countries: $originCountries, '
      'language: $originalLanguage, genres: $withTmdbGenreIds, '
      'without: $withoutTmdbGenreIds, keywords: $withKeywordIds, '
      'tvType: $tvType, minVotes: $minVoteCount)';
}

bool _eq<T>(Set<T> a, Set<T> b) => a.length == b.length && a.containsAll(b);
