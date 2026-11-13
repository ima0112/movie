import 'discover_preset.dart';
import 'genre.dart';
import 'media_type.dart';

/// How `MediaRepository.discover` results should be ordered — H8's own
/// "sort by Popularity/Rating/Date/Title" (`docs/SCREENS.md` H8).
enum DiscoverSortBy {
  popularity,
  rating,

  /// Newest first.
  releaseDate,

  /// Oldest first.
  releaseDateAsc,
  title,
  voteCount,
}

/// H8's "status Airing/Ended (TV shows only)" — TMDB's own TV status
/// vocabulary has more values ("Returning Series", "Canceled", ...);
/// this is deliberately just the two H8 actually exposes as a filter.
enum DiscoverTvStatus { airing, ended }

/// C1/B2's filter set — everything one `MediaRepository.discover` call
/// needs, mirroring H8 (`docs/SCREENS.md` H8: "Type (All/Movies/TV
/// Shows); multi-select genres; year (range slider 1950–present);
/// minimum rating (0–9 slider...); max runtime (movies only); status
/// Airing/Ended (TV shows only); sort by Popularity/Rating/Date/Title.").
///
/// [withoutGenres] goes beyond H8's own literal wording (H8 only lists
/// one multi-select, inclusive, genre field) — it mirrors C5's "Genres
/// you never want" exclusion, applied here too, per the branch that
/// first added this field's own explicit ask for it.
///
/// **"Hide what I've watched" still isn't modeled** — unlike every
/// other field here, it can't become a `/discover` query parameter at
/// all (TMDB has no such filter); it needs cross-referencing this
/// repository's own results against `UserLibraryRepository`'s watched
/// keys, client-side, which is a job for whoever calls `discover`, not
/// something this value object can represent — left for a later branch.
class DiscoverFilter {
  const DiscoverFilter({
    this.type,
    this.withGenres = const {},
    this.withoutGenres = const {},
    this.withKeywords = const {},
    this.yearFrom,
    this.yearTo,
    this.minVoteAverage,
    this.maxVoteAverage,
    this.originalLanguage,
    this.maxRuntimeMinutes,
    this.tvStatus,
    this.sortBy = DiscoverSortBy.popularity,
    this.minVoteCount = 100,
    this.maxVoteCount,
    this.withWatchProviders = const {},
    this.releasedFrom,
    this.releasedTo,
  });

  /// `null` = "All" (H8: "Type (All/Movies/TV Shows)"). C1: "All = both
  /// interleaved."
  final MediaType? type;

  /// H8: "multi-select genres" — an item matching *any* of these
  /// qualifies (TMDB's own `with_genres` OR semantics), not all.
  final Set<Genre> withGenres;

  /// Excludes an item matching *any* of these.
  final Set<Genre> withoutGenres;

  /// TMDB keyword ids (numeric, not slugs) — `Vibe.ruleFor`'s own
  /// `VibeRule.keywordIds`, once a vibe has any. OR semantics, same as
  /// [withGenres] (TMDB's own `with_keywords` pipe-separated form): an
  /// item matching *any* of these qualifies. Combines with [withGenres]/
  /// [withoutGenres] as AND — different `/discover` parameters always
  /// AND together; only values *within* one parameter choose AND (`,`)
  /// or OR (`|`).
  final Set<int> withKeywords;

  /// H8: "year (range slider 1950–present)" — inclusive bounds.
  final int? yearFrom;
  final int? yearTo;

  /// H8: "minimum rating (0–9 slider...)".
  final double? minVoteAverage;

  /// The top of H8's rating range (`vote_average.lte`); `null` = no ceiling.
  final double? maxVoteAverage;

  /// H8's "Original language": an ISO 639-1 code (`with_original_language`),
  /// `null` = any. The language a title was made in, not the one it's shown
  /// in.
  final String? originalLanguage;

  /// H8: "max runtime (movies only)" — minutes. Meaningless for a TV
  /// filter; nothing enforces that here (the *screen* only shows this
  /// control when `type == MediaType.movie`, per H8 itself).
  ///
  /// **`FakeMediaRepository` can't act on this** — `MediaItem` (the
  /// list-level entity every sample title is) carries no runtime data
  /// at all, only `MediaDetail` does, fetched separately per title. A
  /// real `MediaRepositoryImpl` doesn't have that problem: this becomes
  /// TMDB's own `with_runtime.lte` query parameter, filtered server-side
  /// with no local runtime data needed. The field itself is a real,
  /// meaningful part of this contract; only today's fake can't honor it.
  final int? maxRuntimeMinutes;

  /// H8: "status Airing/Ended (TV shows only)". Same caveat as
  /// [maxRuntimeMinutes]: `MediaItem` carries no status field, so
  /// `FakeMediaRepository` can't filter by this either, while a real
  /// implementation would pass it straight through as TMDB's own
  /// `with_status`.
  final DiscoverTvStatus? tvStatus;

  final DiscoverSortBy sortBy;

  /// H8: "minimum rating (0–9 slider, `vote_count.gte=100` fixed)" —
  /// TMDB's own `vote_count.gte`, a floor on how many votes a title
  /// needs to even be considered, independent of [minVoteAverage]
  /// itself. H8's own slider never changes this; the default (`100`)
  /// is what every ordinary Discover/Explore/C1 call already sent
  /// before this field existed (`tmdb_discover_params.dart`'s own
  /// previously-hardcoded constant). `MatchEngine._filterForVibe` is
  /// the one real caller that *does* vary it — `MatchQuery.voteCountGte`
  /// (200 on the first attempt, 50 after relaxation step 4).
  final int minVoteCount;

  /// An upper bound on the vote count (`vote_count.lte`) — B2's "Hidden gems"
  /// (well rated but not widely voted). `null` = no ceiling.
  final int? maxVoteCount;

  /// TMDB provider ids (`with_watch_providers`): a title on *any* of these
  /// qualifies. Needs the user's region, which the repository adds
  /// (`watch_region`); B2's "Platform" pills set it.
  final Set<int> withWatchProviders;

  /// An exact release-date window (`primary_release_date` / `first_air_date`
  /// `.gte`/`.lte`), finer than [yearFrom]/[yearTo] and winning over them:
  /// B2's "New releases" is "the last two months", not a calendar year.
  final DateTime? releasedFrom;
  final DateTime? releasedTo;

  /// H8's "Reset" only shows "if something's active" — i.e. this isn't
  /// the default.
  bool get isDefault => this == const DiscoverFilter();

  /// How many filters the user has set — what the C1 filter icon's badge
  /// counts, one per streaming service, genre, the years, the rating range,
  /// the original language and a preset (Coming soon, Finished…). The kind
  /// of title and the sort never count: the first is the segment, the second
  /// is always set to something.
  int get activeFilterCount =>
      withWatchProviders.length +
      withGenres.length +
      withoutGenres.length +
      (yearFrom != null || yearTo != null ? 1 : 0) +
      (hasRatingRange ? 1 : 0) +
      (originalLanguage != null ? 1 : 0) +
      (preset != null ? 1 : 0);

  /// Whether a rating floor above 0 or a ceiling is set.
  bool get hasRatingRange =>
      (minVoteAverage != null && minVoteAverage! > 0) || maxVoteAverage != null;

  /// [type]/[yearFrom]/[yearTo]/[minVoteAverage]/[maxRuntimeMinutes]/
  /// [tvStatus] take a *function* returning the new value, not the value
  /// itself — the usual `?? this.x` copyWith shortcut can't tell "leave
  /// this alone" apart from "clear it to null" for a field that's
  /// already nullable, and every one of these needs to support clearing
  /// (H8's own sliders/chips all have an "unset" position). Same idiom
  /// `MyListCubit`'s own `_updateCurrentTab` already uses for `TabFilter`.
  /// [withGenres]/[withoutGenres]/[withKeywords]/[sortBy] have no such
  /// ambiguity — they always hold a real value (an empty `Set`/the
  /// default sort), so the plain `?? this.x` form is unambiguous for
  /// them.
  DiscoverFilter copyWith({
    MediaType? Function()? type,
    Set<Genre>? withGenres,
    Set<Genre>? withoutGenres,
    Set<int>? withKeywords,
    int? Function()? yearFrom,
    int? Function()? yearTo,
    double? Function()? minVoteAverage,
    double? Function()? maxVoteAverage,
    String? Function()? originalLanguage,
    int? Function()? maxRuntimeMinutes,
    DiscoverTvStatus? Function()? tvStatus,
    DiscoverSortBy? sortBy,
    int? minVoteCount,
    int? Function()? maxVoteCount,
    Set<int>? withWatchProviders,
    DateTime? Function()? releasedFrom,
    DateTime? Function()? releasedTo,
  }) {
    return DiscoverFilter(
      type: type == null ? this.type : type(),
      withGenres: withGenres ?? this.withGenres,
      withoutGenres: withoutGenres ?? this.withoutGenres,
      withKeywords: withKeywords ?? this.withKeywords,
      yearFrom: yearFrom == null ? this.yearFrom : yearFrom(),
      yearTo: yearTo == null ? this.yearTo : yearTo(),
      minVoteAverage: minVoteAverage == null
          ? this.minVoteAverage
          : minVoteAverage(),
      maxVoteAverage: maxVoteAverage == null
          ? this.maxVoteAverage
          : maxVoteAverage(),
      originalLanguage: originalLanguage == null
          ? this.originalLanguage
          : originalLanguage(),
      maxRuntimeMinutes: maxRuntimeMinutes == null
          ? this.maxRuntimeMinutes
          : maxRuntimeMinutes(),
      tvStatus: tvStatus == null ? this.tvStatus : tvStatus(),
      sortBy: sortBy ?? this.sortBy,
      minVoteCount: minVoteCount ?? this.minVoteCount,
      maxVoteCount: maxVoteCount == null ? this.maxVoteCount : maxVoteCount(),
      withWatchProviders: withWatchProviders ?? this.withWatchProviders,
      releasedFrom: releasedFrom == null ? this.releasedFrom : releasedFrom(),
      releasedTo: releasedTo == null ? this.releasedTo : releasedTo(),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DiscoverFilter &&
      other.type == type &&
      _setEquals(other.withGenres, withGenres) &&
      _setEquals(other.withoutGenres, withoutGenres) &&
      _setEquals(other.withKeywords, withKeywords) &&
      other.yearFrom == yearFrom &&
      other.yearTo == yearTo &&
      other.minVoteAverage == minVoteAverage &&
      other.maxVoteAverage == maxVoteAverage &&
      other.originalLanguage == originalLanguage &&
      other.maxRuntimeMinutes == maxRuntimeMinutes &&
      other.tvStatus == tvStatus &&
      other.sortBy == sortBy &&
      other.minVoteCount == minVoteCount &&
      other.maxVoteCount == maxVoteCount &&
      _setEquals(other.withWatchProviders, withWatchProviders) &&
      other.releasedFrom == releasedFrom &&
      other.releasedTo == releasedTo;

  @override
  int get hashCode => Object.hash(
    type,
    Object.hashAllUnordered(withGenres),
    Object.hashAllUnordered(withoutGenres),
    Object.hashAllUnordered(withKeywords),
    yearFrom,
    yearTo,
    minVoteAverage,
    maxVoteAverage,
    originalLanguage,
    maxRuntimeMinutes,
    tvStatus,
    sortBy,
    minVoteCount,
    maxVoteCount,
    Object.hashAllUnordered(withWatchProviders),
    releasedFrom,
    releasedTo,
  );

  @override
  String toString() =>
      'DiscoverFilter(type: $type, withGenres: $withGenres, '
      'withoutGenres: $withoutGenres, withKeywords: $withKeywords, '
      'yearFrom: $yearFrom, '
      'yearTo: $yearTo, minVoteAverage: $minVoteAverage, '
      'maxVoteAverage: $maxVoteAverage, '
      'originalLanguage: $originalLanguage, '
      'maxRuntimeMinutes: $maxRuntimeMinutes, tvStatus: $tvStatus, '
      'sortBy: $sortBy, minVoteCount: $minVoteCount, '
      'maxVoteCount: $maxVoteCount, '
      'withWatchProviders: $withWatchProviders, '
      'releasedFrom: $releasedFrom, releasedTo: $releasedTo)';
}

/// Order-independent set content equality — same local stand-in for
/// `package:collection`'s `SetEquality` that `TasteProfile` already has
/// its own copy of, for the same reason (no new dependency for just
/// this).
bool _setEquals<T>(Set<T> a, Set<T> b) =>
    a.length == b.length && a.containsAll(b);
