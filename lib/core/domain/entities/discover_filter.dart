import 'genre.dart';
import 'media_type.dart';

/// How `MediaRepository.discover` results should be ordered — H8's own
/// "sort by Popularity/Rating/Date/Title" (`docs/SCREENS.md` H8).
enum DiscoverSortBy { popularity, rating, releaseDate, title }

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
    this.yearFrom,
    this.yearTo,
    this.minVoteAverage,
    this.maxRuntimeMinutes,
    this.tvStatus,
    this.sortBy = DiscoverSortBy.popularity,
  });

  /// `null` = "All" (H8: "Type (All/Movies/TV Shows)"). C1: "All = both
  /// interleaved."
  final MediaType? type;

  /// H8: "multi-select genres" — an item matching *any* of these
  /// qualifies (TMDB's own `with_genres` OR semantics), not all.
  final Set<Genre> withGenres;

  /// Excludes an item matching *any* of these.
  final Set<Genre> withoutGenres;

  /// H8: "year (range slider 1950–present)" — inclusive bounds.
  final int? yearFrom;
  final int? yearTo;

  /// H8: "minimum rating (0–9 slider...)".
  final double? minVoteAverage;

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

  /// H8's "Reset" only shows "if something's active" — i.e. this isn't
  /// the default.
  bool get isDefault => this == const DiscoverFilter();

  /// [type]/[yearFrom]/[yearTo]/[minVoteAverage]/[maxRuntimeMinutes]/
  /// [tvStatus] take a *function* returning the new value, not the value
  /// itself — the usual `?? this.x` copyWith shortcut can't tell "leave
  /// this alone" apart from "clear it to null" for a field that's
  /// already nullable, and every one of these needs to support clearing
  /// (H8's own sliders/chips all have an "unset" position). Same idiom
  /// `MyListCubit`'s own `_updateCurrentTab` already uses for `TabFilter`.
  /// [withGenres]/[withoutGenres]/[sortBy] have no such ambiguity — they
  /// always hold a real value (an empty `Set`/the default sort), so the
  /// plain `?? this.x` form is unambiguous for them.
  DiscoverFilter copyWith({
    MediaType? Function()? type,
    Set<Genre>? withGenres,
    Set<Genre>? withoutGenres,
    int? Function()? yearFrom,
    int? Function()? yearTo,
    double? Function()? minVoteAverage,
    int? Function()? maxRuntimeMinutes,
    DiscoverTvStatus? Function()? tvStatus,
    DiscoverSortBy? sortBy,
  }) {
    return DiscoverFilter(
      type: type == null ? this.type : type(),
      withGenres: withGenres ?? this.withGenres,
      withoutGenres: withoutGenres ?? this.withoutGenres,
      yearFrom: yearFrom == null ? this.yearFrom : yearFrom(),
      yearTo: yearTo == null ? this.yearTo : yearTo(),
      minVoteAverage: minVoteAverage == null
          ? this.minVoteAverage
          : minVoteAverage(),
      maxRuntimeMinutes: maxRuntimeMinutes == null
          ? this.maxRuntimeMinutes
          : maxRuntimeMinutes(),
      tvStatus: tvStatus == null ? this.tvStatus : tvStatus(),
      sortBy: sortBy ?? this.sortBy,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DiscoverFilter &&
      other.type == type &&
      _setEquals(other.withGenres, withGenres) &&
      _setEquals(other.withoutGenres, withoutGenres) &&
      other.yearFrom == yearFrom &&
      other.yearTo == yearTo &&
      other.minVoteAverage == minVoteAverage &&
      other.maxRuntimeMinutes == maxRuntimeMinutes &&
      other.tvStatus == tvStatus &&
      other.sortBy == sortBy;

  @override
  int get hashCode => Object.hash(
    type,
    Object.hashAllUnordered(withGenres),
    Object.hashAllUnordered(withoutGenres),
    yearFrom,
    yearTo,
    minVoteAverage,
    maxRuntimeMinutes,
    tvStatus,
    sortBy,
  );

  @override
  String toString() =>
      'DiscoverFilter(type: $type, withGenres: $withGenres, '
      'withoutGenres: $withoutGenres, yearFrom: $yearFrom, '
      'yearTo: $yearTo, minVoteAverage: $minVoteAverage, '
      'maxRuntimeMinutes: $maxRuntimeMinutes, tvStatus: $tvStatus, '
      'sortBy: $sortBy)';
}

/// Order-independent set content equality — same local stand-in for
/// `package:collection`'s `SetEquality` that `TasteProfile` already has
/// its own copy of, for the same reason (no new dependency for just
/// this).
bool _setEquals<T>(Set<T> a, Set<T> b) =>
    a.length == b.length && a.containsAll(b);
