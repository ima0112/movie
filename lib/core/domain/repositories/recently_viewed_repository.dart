import '../entities/media_item.dart';
import '../entities/result.dart';

/// The titles whose detail screen the user opened most recently — Home's
/// "Recently viewed" (All tab only). A device-local list of at most [limit]
/// titles, newest first, no account: opening a title's detail moves it to the
/// front instead of repeating it, and the oldest drops off past [limit].
///
/// It stores a small snapshot of each title (type, id, title, poster, rating,
/// release date) so the section can draw its posters without a network call.
/// The snapshot's genres aren't kept (the section doesn't use them), so the
/// items it emits have none.
///
/// Lives in `core/domain` because three features need it: the movie and TV
/// detail screens write it and Home reads it.
abstract interface class RecentlyViewedRepository {
  /// How many titles are kept.
  static const int limit = 10;

  /// Newest first, at most [limit]; emits again after every [record].
  Stream<List<MediaItem>> watch();

  /// Notes that [item]'s detail was opened: it goes to the front of the list
  /// (an already-present title moves, never duplicates) and the oldest past
  /// [limit] is dropped.
  Future<Result<void>> record(MediaItem item);
}
