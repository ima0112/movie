import 'media_key.dart';

/// One row of "My List" — see `docs/DECISIONS.md` section 4 ("My List,
/// Watched, and taste profile").
///
/// [isFavorite] and [isWatchLater] are independent, **non-exclusive**
/// flags — an entry can be a favorite and in Watch later at the same
/// time. Watched is tracked via [watchedAt] (`null` = not watched) with
/// an optional 1–5 [rating], set together via [markWatched].
class UserMediaEntry {
  const UserMediaEntry({
    required this.key,
    this.isFavorite = false,
    this.isWatchLater = false,
    this.watchedAt,
    this.rating,
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

  bool get isWatched => watchedAt != null;

  /// Marks this entry watched. Per `docs/DECISIONS.md` section 4
  /// ("Marking as watched automatically removes it from 'Watch later'"),
  /// this always clears [isWatchLater] — regardless of its previous
  /// value — so callers never have to remember that rule themselves.
  UserMediaEntry markWatched({DateTime? watchedAt, int? rating}) {
    return UserMediaEntry(
      key: key,
      isFavorite: isFavorite,
      isWatchLater: false,
      watchedAt: watchedAt ?? DateTime.now(),
      rating: rating,
    );
  }

  /// Clears the "watched" mark and any rating — e.g. H2's "Remove from
  /// Watched" link.
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
  }) {
    return UserMediaEntry(
      key: key,
      isFavorite: isFavorite ?? this.isFavorite,
      isWatchLater: isWatchLater ?? this.isWatchLater,
      watchedAt: watchedAt ?? this.watchedAt,
      rating: rating ?? this.rating,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UserMediaEntry &&
      other.key == key &&
      other.isFavorite == isFavorite &&
      other.isWatchLater == isWatchLater &&
      other.watchedAt == watchedAt &&
      other.rating == rating;

  @override
  int get hashCode =>
      Object.hash(key, isFavorite, isWatchLater, watchedAt, rating);

  @override
  String toString() =>
      'UserMediaEntry($key, favorite: $isFavorite, '
      'watchLater: $isWatchLater, watchedAt: $watchedAt, rating: $rating)';
}
