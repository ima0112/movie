import 'genre.dart';
import 'media_item.dart';
import 'media_key.dart';

/// One row of "My List" — see `docs/DECISIONS.md` section 4 ("My List,
/// Watched, and taste profile").
///
/// [isFavorite] and [isWatchLater] are independent, **non-exclusive**
/// flags — an entry can be a favorite and in Watch later at the same
/// time. Watched is tracked via [watchedAt] (`null` = not watched) with
/// an optional 1–5 [rating], set together via [markWatched].
///
/// [runtimeMinutes]/[episodeCount]/[episodeRuntimeMinutes]/[posterUrl]/
/// [voteAverage]/[year] are a catalog/duration snapshot populated
/// whenever a `MediaDetail`/`MediaItem` happens to be on hand at a write
/// — H2's "Save" (`MarkAsWatchedSheet`), D1/D2's Favorite/Watch later
/// toggle (`MediaDetailActionRow`), E3's "Add to watch later", and the
/// detail screens' own lazy refresh on open (`MovieDetailCubit`/
/// `TvDetailCubit`) — never fetched live from this entry. [genres] is
/// the same idea and the oldest of the group. [catalogSnapshotFrom]
/// extracts the catalog half of this from a `MediaItem` in one place,
/// shared by every one of those call sites.
class UserMediaEntry {
  const UserMediaEntry({
    required this.key,
    required this.title,
    this.isFavorite = false,
    this.isWatchLater = false,
    this.favoritedAt,
    this.watchLaterAt,
    this.watchedAt,
    this.rating,
    this.runtimeMinutes,
    this.episodeCount,
    this.episodeRuntimeMinutes,
    this.genres = const [],
    this.posterUrl,
    this.voteAverage,
    this.year,
  }) : assert(
         rating == null || (rating >= 1 && rating <= 5),
         'rating must be 1-5',
       );

  final MediaKey key;

  /// `MediaItem.title`/`MediaDetail.item.title` at the moment this entry
  /// was created or last re-saved — same "capture what's on hand" rule
  /// as [genres], and for the same reason: "My List" and Export My List
  /// need to show/write a real title with no network round trip.
  ///
  /// Because it's a snapshot, it keeps whatever language TMDB returned
  /// it in **at that moment** — not the user's *current* Settings
  /// language (`AppSettings.languageCode`, `settings-screen` branch). A
  /// title favorited in Spanish still reads in Spanish in My List/the
  /// exported JSON after the user later switches Settings to English;
  /// it only picks up the new language the next time this exact entry
  /// is favorited/watch-latered/watched again (which re-saves [title]
  /// from whatever `MediaItem`/`MediaDetail` is on hand then). This is
  /// a deliberate consequence of the "capture what's on hand" rule
  /// above, not a bug to fix — re-fetching every saved title on every
  /// language change would mean a network round trip per entry just to
  /// keep My List's own offline snapshot in sync.
  final String title;

  final bool isFavorite;
  final bool isWatchLater;

  /// When the title was added to Favorites / Watch later ("Added 3 days ago",
  /// `docs/SCREENS.md` B4). `null` while it isn't in that list, and also for
  /// an entry saved before these fields existed (no date is invented for it).
  /// Stamped by the repository on `upsert` ([withSaveDates]), so callers
  /// never set them: a title that stays in a list keeps its date.
  final DateTime? favoritedAt;
  final DateTime? watchLaterAt;
  final DateTime? watchedAt;

  /// 1–5. Only meaningful once [watchedAt] is set.
  final int? rating;

  /// `MovieDetail.runtimeMinutes` at the moment this entry was last
  /// saved or refreshed with a `MovieDetail` on hand (marked watched,
  /// toggled favorite/watch later from D1, or the lazy refresh on
  /// reopening D1). Meant for movie entries only — not enforced by an
  /// assert, since evaluating `key.type` in this constructor's
  /// initializer list would stop it from being `const`, which every
  /// existing call site (including every test using
  /// `const UserMediaEntry(...)`) relies on. `null` for any entry that
  /// isn't a movie, and legitimately `null` for one that is — an entry
  /// saved before this field existed, one only ever saved from E3 (no
  /// `MediaDetail` on hand there), or one whose `MovieDetail` itself had
  /// no runtime from TMDB. Callers summing this (`your_activity_card.dart`,
  /// `LibraryStatsCalculator`) must treat a missing value as `0`, not an
  /// error.
  final int? runtimeMinutes;

  /// `TvShowDetail.numberOfEpisodes` at the moment this entry was last
  /// saved or refreshed with a `TvShowDetail` on hand (same set of
  /// moments as [runtimeMinutes]) — the whole show's episode count,
  /// since TV is tracked at the whole-show level (`MediaKey`'s own doc
  /// comment), not per episode. Meant for TV entries only — same
  /// not-a-const-assert reasoning as [runtimeMinutes].
  final int? episodeCount;

  /// `TvShowDetail.episodeRuntimeMinutes` at the moment this entry was
  /// last saved or refreshed with a `TvShowDetail` on hand. Meant for TV
  /// entries only; can still be `null` for one, same optionality as
  /// `TvShowDetail`'s own field (TMDB doesn't always give a per-episode
  /// runtime).
  final int? episodeRuntimeMinutes;

  /// `MediaItem.genres` at the moment this entry was created or last
  /// re-saved (favorited, watch-latered, or marked watched — whichever
  /// call site had a `MediaItem`/`MediaDetail` on hand). Defaults to
  /// `[]`, not populated retroactively for rows saved before this field
  /// existed. Powers C4's "Genres you watch most"
  /// (`LibraryStatsCalculator.topGenres`).
  final List<Genre> genres;

  /// `MediaItem.posterUrl` at the moment this entry was last saved or
  /// refreshed — already a fully resolved image URL (TMDB's image host +
  /// a size token baked in by the mapper), not a raw TMDB path. Same
  /// "capture what's on hand" rule as [title]/[genres]. Lets My List (B4)
  /// render its poster with no network round trip; `null` when TMDB had
  /// none, or for an entry saved before this field existed.
  final String? posterUrl;

  /// `MediaItem.voteAverage` at the moment this entry was last saved or
  /// refreshed. Powers H9's "TMDB rating" sort; `null` for an entry saved
  /// before this field existed.
  final double? voteAverage;

  /// `MediaItem.releaseDate?.year` (movie) / first-air year (TV) at the
  /// moment this entry was last saved or refreshed. Powers H9's "Year"
  /// sort and My List's offline metadata line; `null` for an entry saved
  /// before this field existed, or when TMDB had no release date yet.
  final int? year;

  bool get isWatched => watchedAt != null;

  /// Marks this entry watched. Per `docs/DECISIONS.md` section 4
  /// ("Marking as watched automatically removes it from 'Watch later'"),
  /// this always clears [isWatchLater] — regardless of its previous
  /// value — so callers never have to remember that rule themselves.
  ///
  /// Like [rating], the duration fields are a full replace, not merged
  /// with whatever this entry had before — H2 always passes what
  /// `MediaDetail` has on hand right now. [genres] is the one exception:
  /// it describes the *title*, not the watch event, so a `null` here
  /// (H2 has no fresher `MediaDetail` than what's already on the entry)
  /// preserves [this.genres] instead of wiping it — the same way
  /// [isFavorite] always carries forward below.
  UserMediaEntry markWatched({
    DateTime? watchedAt,
    int? rating,
    int? runtimeMinutes,
    int? episodeCount,
    int? episodeRuntimeMinutes,
    List<Genre>? genres,
    String? posterUrl,
    double? voteAverage,
    int? year,
  }) {
    return UserMediaEntry(
      key: key,
      title: title,
      isFavorite: isFavorite,
      isWatchLater: false,
      favoritedAt: favoritedAt,
      watchedAt: watchedAt ?? DateTime.now(),
      rating: rating,
      runtimeMinutes: runtimeMinutes,
      episodeCount: episodeCount,
      episodeRuntimeMinutes: episodeRuntimeMinutes,
      genres: genres ?? this.genres,
      posterUrl: posterUrl ?? this.posterUrl,
      voteAverage: voteAverage ?? this.voteAverage,
      year: year ?? this.year,
    );
  }

  /// Clears the "watched" mark, any rating, and the duration snapshot —
  /// e.g. H2's "Remove from Watched" link. [genres]/[title] carry
  /// forward: they describe the title itself, which hasn't changed just
  /// because "watched" was cleared — same as [isFavorite]/[isWatchLater]
  /// below.
  UserMediaEntry unmarkWatched() {
    return UserMediaEntry(
      key: key,
      title: title,
      isFavorite: isFavorite,
      isWatchLater: isWatchLater,
      favoritedAt: favoritedAt,
      watchLaterAt: watchLaterAt,
      genres: genres,
      posterUrl: posterUrl,
      voteAverage: voteAverage,
      year: year,
    );
  }

  UserMediaEntry copyWith({
    String? title,
    bool? isFavorite,
    bool? isWatchLater,
    DateTime? watchedAt,
    int? rating,
    int? runtimeMinutes,
    int? episodeCount,
    int? episodeRuntimeMinutes,
    List<Genre>? genres,
    String? posterUrl,
    double? voteAverage,
    int? year,
  }) {
    return UserMediaEntry(
      key: key,
      title: title ?? this.title,
      isFavorite: isFavorite ?? this.isFavorite,
      isWatchLater: isWatchLater ?? this.isWatchLater,
      favoritedAt: favoritedAt,
      watchLaterAt: watchLaterAt,
      watchedAt: watchedAt ?? this.watchedAt,
      rating: rating ?? this.rating,
      runtimeMinutes: runtimeMinutes ?? this.runtimeMinutes,
      episodeCount: episodeCount ?? this.episodeCount,
      episodeRuntimeMinutes:
          episodeRuntimeMinutes ?? this.episodeRuntimeMinutes,
      genres: genres ?? this.genres,
      posterUrl: posterUrl ?? this.posterUrl,
      voteAverage: voteAverage ?? this.voteAverage,
      year: year ?? this.year,
    );
  }

  /// This entry with [favoritedAt] / [watchLaterAt] settled against what was
  /// stored before ([previous], `null` when there was nothing): a list the
  /// title isn't in has no date; one it was already in keeps its date (even
  /// an absent one, for entries saved before dates existed); one it just
  /// joined gets [now]. Both repositories call this on `upsert`.
  UserMediaEntry withSaveDates(UserMediaEntry? previous, DateTime now) {
    DateTime? settle(bool on, bool wasOn, DateTime? before, DateTime? given) {
      if (!on) return null;
      return wasOn ? (before ?? given) : (given ?? now);
    }

    return UserMediaEntry(
      key: key,
      title: title,
      isFavorite: isFavorite,
      isWatchLater: isWatchLater,
      favoritedAt: settle(
        isFavorite,
        previous?.isFavorite ?? false,
        previous?.favoritedAt,
        favoritedAt,
      ),
      watchLaterAt: settle(
        isWatchLater,
        previous?.isWatchLater ?? false,
        previous?.watchLaterAt,
        watchLaterAt,
      ),
      watchedAt: watchedAt,
      rating: rating,
      runtimeMinutes: runtimeMinutes,
      episodeCount: episodeCount,
      episodeRuntimeMinutes: episodeRuntimeMinutes,
      genres: genres,
      posterUrl: posterUrl,
      voteAverage: voteAverage,
      year: year,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UserMediaEntry &&
      other.key == key &&
      other.title == title &&
      other.isFavorite == isFavorite &&
      other.isWatchLater == isWatchLater &&
      other.favoritedAt == favoritedAt &&
      other.watchLaterAt == watchLaterAt &&
      other.watchedAt == watchedAt &&
      other.rating == rating &&
      other.runtimeMinutes == runtimeMinutes &&
      other.episodeCount == episodeCount &&
      other.episodeRuntimeMinutes == episodeRuntimeMinutes &&
      _listEquals(other.genres, genres) &&
      other.posterUrl == posterUrl &&
      other.voteAverage == voteAverage &&
      other.year == year;

  @override
  int get hashCode => Object.hash(
    key,
    title,
    isFavorite,
    isWatchLater,
    favoritedAt,
    watchLaterAt,
    watchedAt,
    rating,
    runtimeMinutes,
    episodeCount,
    episodeRuntimeMinutes,
    Object.hashAll(genres),
    posterUrl,
    voteAverage,
    year,
  );

  @override
  String toString() =>
      'UserMediaEntry($key, title: $title, favorite: $isFavorite, '
      'watchLater: $isWatchLater, favoritedAt: $favoritedAt, '
      'watchLaterAt: $watchLaterAt, watchedAt: $watchedAt, rating: $rating, '
      'runtimeMinutes: $runtimeMinutes, episodeCount: $episodeCount, '
      'episodeRuntimeMinutes: $episodeRuntimeMinutes, genres: $genres, '
      'posterUrl: $posterUrl, voteAverage: $voteAverage, year: $year)';
}

/// The catalog-snapshot fields [UserMediaEntry] captures from a
/// [MediaItem] — pulled out as one function rather than inlined at each
/// of its 3+ call sites (My List toggles, Mark as watched, Surprise me's
/// "Add to watch later", the detail screens' lazy snapshot refresh), all
/// of which need exactly this same mapping.
({
  String title,
  List<Genre> genres,
  String? posterUrl,
  double? voteAverage,
  int? year,
})
catalogSnapshotFrom(MediaItem item) => (
  title: item.title,
  genres: item.genres,
  posterUrl: item.posterUrl,
  voteAverage: item.voteAverage,
  year: item.releaseDate?.year,
);

/// Per-genre affinity from [entries]: +1 for each favorite or ≥4-star
/// watch touching that genre, -1 for each ≤2-star watch. An entry with
/// neither signal (unrated, or rated 3) contributes nothing.
///
/// Shared by `TasteProfileBuilder` (ranking which liked genre maps to a
/// filler vibe first) and `RecommendationBuilder` ("Para ti"'s own
/// library-signal fallback when no usable `TasteProfile` exists —
/// `docs/DECISIONS.md` section 5/F1b) — pulled out here, in
/// `core/domain`, rather than left private to either feature, so
/// neither re-implements it (CLAUDE.md rule 1: a feature's `domain`
/// only imports `core/domain`, never another feature).
Map<Genre, int> genreAffinityFrom(List<UserMediaEntry> entries) {
  final affinity = <Genre, int>{};
  for (final entry in entries) {
    final rating = entry.rating;
    final isBoost = entry.isFavorite || (rating != null && rating >= 4);
    final isPenalty = rating != null && rating <= 2;
    if (!isBoost && !isPenalty) continue;

    final delta = isBoost ? 1 : -1;
    for (final genre in entry.genres) {
      affinity[genre] = (affinity[genre] ?? 0) + delta;
    }
  }
  return affinity;
}

/// Order-sensitive list content equality — see `LibraryStats`' own copy
/// of this same small helper for why: no `package:collection` dependency
/// for just this (CLAUDE.md "don't add one without discussing it").
bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
