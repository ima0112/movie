import 'media_key.dart';

/// One row of "My List" — see `docs/DECISIONS.md` section 4 ("My List,
/// Watched, and taste profile").
///
/// [isFavorite] and [isWatchLater] are independent, **non-exclusive**
/// flags — an entry can be a favorite and in Watch later at the same
/// time. Watched is tracked via [watchedAt] (`null` = not watched) with
/// an optional 1–5 [rating], set together via [markWatched].
///
/// [runtimeMinutes]/[episodeCount]/[episodeRuntimeMinutes] are a
/// duration snapshot taken at the moment H2's "Save" is tapped (see
/// `MarkAsWatchedSheet`), not fetched live from this entry — the same
/// "capture what's on hand at write time" approach the drift table's own
/// catalog snapshot columns already use (`app_database.dart`). They live
/// on this domain entity rather than only in the drift row, unlike that
/// catalog snapshot, because domain-level code (`your_activity_card.dart`
/// today, Stats/C4 next) actually needs to read them back through
/// [UserLibraryRepository.watch] — the untouched catalog columns don't
/// have a reader yet, these do from the moment they're added.
class UserMediaEntry {
  const UserMediaEntry({
    required this.key,
    this.isFavorite = false,
    this.isWatchLater = false,
    this.watchedAt,
    this.rating,
    this.runtimeMinutes,
    this.episodeCount,
    this.episodeRuntimeMinutes,
  }) : assert(
         rating == null || (rating >= 1 && rating <= 5),
         'rating must be 1-5',
       );

  final MediaKey key;
  final bool isFavorite;
  final bool isWatchLater;
  final DateTime? watchedAt;

  /// 1–5. Only meaningful once [watchedAt] is set.
  final int? rating;

  /// `MovieDetail.runtimeMinutes` at the moment this entry was marked
  /// watched. Meant for movie entries only (H2 never populates it for a
  /// TV show) — not enforced by an assert, since evaluating `key.type`
  /// in this constructor's initializer list would stop it from being
  /// `const`, which every existing call site (including every test
  /// using `const UserMediaEntry(...)`) relies on. `null` for any entry
  /// that isn't a watched movie, and legitimately `null` even for one
  /// that is — an entry watched before this field existed, or one whose
  /// `MovieDetail` itself had no runtime from TMDB. Callers summing this
  /// (`your_activity_card.dart`) must treat a missing value as `0`, not
  /// an error.
  final int? runtimeMinutes;

  /// `TvShowDetail.numberOfEpisodes` at the moment this entry was marked
  /// watched — the whole show's episode count, since TV is tracked at
  /// the whole-show level (`MediaKey`'s own doc comment), not per
  /// episode. Meant for TV entries only — same not-a-const-assert
  /// reasoning as [runtimeMinutes].
  final int? episodeCount;

  /// `TvShowDetail.episodeRuntimeMinutes` at the moment this entry was
  /// marked watched. Meant for TV entries only; can still be `null` for
  /// one, same optionality as `TvShowDetail`'s own field (TMDB doesn't
  /// always give a per-episode runtime).
  final int? episodeRuntimeMinutes;

  bool get isWatched => watchedAt != null;

  /// Marks this entry watched. Per `docs/DECISIONS.md` section 4
  /// ("Marking as watched automatically removes it from 'Watch later'"),
  /// this always clears [isWatchLater] — regardless of its previous
  /// value — so callers never have to remember that rule themselves.
  ///
  /// Like [rating], the duration fields are a full replace, not merged
  /// with whatever this entry had before — H2 always passes what
  /// `MediaDetail` has on hand right now.
  UserMediaEntry markWatched({
    DateTime? watchedAt,
    int? rating,
    int? runtimeMinutes,
    int? episodeCount,
    int? episodeRuntimeMinutes,
  }) {
    return UserMediaEntry(
      key: key,
      isFavorite: isFavorite,
      isWatchLater: false,
      watchedAt: watchedAt ?? DateTime.now(),
      rating: rating,
      runtimeMinutes: runtimeMinutes,
      episodeCount: episodeCount,
      episodeRuntimeMinutes: episodeRuntimeMinutes,
    );
  }

  /// Clears the "watched" mark, any rating, and the duration snapshot —
  /// e.g. H2's "Remove from Watched" link.
  UserMediaEntry unmarkWatched() {
    return UserMediaEntry(
      key: key,
      isFavorite: isFavorite,
      isWatchLater: isWatchLater,
    );
  }

  UserMediaEntry copyWith({
    bool? isFavorite,
    bool? isWatchLater,
    DateTime? watchedAt,
    int? rating,
    int? runtimeMinutes,
    int? episodeCount,
    int? episodeRuntimeMinutes,
  }) {
    return UserMediaEntry(
      key: key,
      isFavorite: isFavorite ?? this.isFavorite,
      isWatchLater: isWatchLater ?? this.isWatchLater,
      watchedAt: watchedAt ?? this.watchedAt,
      rating: rating ?? this.rating,
      runtimeMinutes: runtimeMinutes ?? this.runtimeMinutes,
      episodeCount: episodeCount ?? this.episodeCount,
      episodeRuntimeMinutes:
          episodeRuntimeMinutes ?? this.episodeRuntimeMinutes,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UserMediaEntry &&
      other.key == key &&
      other.isFavorite == isFavorite &&
      other.isWatchLater == isWatchLater &&
      other.watchedAt == watchedAt &&
      other.rating == rating &&
      other.runtimeMinutes == runtimeMinutes &&
      other.episodeCount == episodeCount &&
      other.episodeRuntimeMinutes == episodeRuntimeMinutes;

  @override
  int get hashCode => Object.hash(
    key,
    isFavorite,
    isWatchLater,
    watchedAt,
    rating,
    runtimeMinutes,
    episodeCount,
    episodeRuntimeMinutes,
  );

  @override
  String toString() =>
      'UserMediaEntry($key, favorite: $isFavorite, '
      'watchLater: $isWatchLater, watchedAt: $watchedAt, rating: $rating, '
      'runtimeMinutes: $runtimeMinutes, episodeCount: $episodeCount, '
      'episodeRuntimeMinutes: $episodeRuntimeMinutes)';
}
