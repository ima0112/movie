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
