import '../entities/genre.dart';
import '../entities/media_key.dart';
import '../entities/media_type.dart';
import '../entities/result.dart';
import '../entities/user_media_entry.dart';

enum LibraryTab { favorites, watchLater, watched }

abstract interface class UserLibraryRepository {
  /// Reactive stream so My List and the action buttons in any detail
  /// screen update without a manual refresh. This is what rule 10 refers
  /// to: screens subscribe to this directly, no global Cubit in between.
  Stream<List<UserMediaEntry>> watch({LibraryTab? tab, MediaType? type});

  /// What MovieActionRow subscribes to — just one entry, not the whole list.
  Stream<UserMediaEntry?> watchEntry(MediaKey key);

  Future<Result<void>> upsert(UserMediaEntry entry);

  /// Refreshes only the catalog-snapshot fields of whatever is already
  /// saved at [key] — never `isFavorite`/`isWatchLater`/`watchedAt`/
  /// `rating`. A no-op if [key] has no saved entry. A `null` optional
  /// field means "nothing fresher than what's already there," not "set
  /// it to null" — the stored value is left untouched, not blanked.
  ///
  /// Used by the movie/TV detail screens' own lazy "refresh on open"
  /// (`MovieDetailCubit`/`TvDetailCubit`): it must never race a
  /// favorite/watch-later toggle landing on the same row, so this talks
  /// to storage directly rather than reading the current entry and
  /// [upsert]-ing a full replacement back.
  Future<Result<void>> updateCatalogSnapshot(
    MediaKey key, {
    required String title,
    required List<Genre> genres,
    String? posterUrl,
    double? voteAverage,
    int? year,
    int? runtimeMinutes,
    int? episodeCount,
    int? episodeRuntimeMinutes,
  });

  Future<Result<void>> remove(MediaKey key);

  /// "Delete My List" (F11/C6) — every entry, regardless of
  /// favorite/watch-later/watched state.
  Future<Result<void>> clearAll();

  /// IDs only — used to exclude watched titles in the match engine and to
  /// publish into a Matcher room (capped at [limit], most recent first).
  Future<Result<List<MediaKey>>> watchedKeys(
    MediaType type, {
    int limit = 500,
  });

  /// Raw material for Stats and the taste profile's implicit signals.
  Future<Result<List<UserMediaEntry>>> all();
}
