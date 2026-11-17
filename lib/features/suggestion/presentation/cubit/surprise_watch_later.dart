import '../../../../core/domain/entities/media_key.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../shared/widgets/media_detail_duration.dart';
import '../../../match_engine/domain/surprise_batch.dart';

/// Puts [suggestion]'s title in Watch later — "Ver después" — keeping whatever
/// else is already saved about it (a favorite, a rating, a watched date): the
/// existing entry is read and only its watch-later flag is set. The catalog
/// snapshot (title, genres, poster, rating, year, duration) is taken from the
/// details the card was built from, as every other save site does.
///
/// Already in Watch later: nothing changes.
Future<Result<void>> saveToWatchLater(
  UserLibraryRepository library,
  SurpriseSuggestion suggestion,
) async {
  final item = suggestion.item;
  final existing = await library.watchEntry(item.key).first;
  if (existing != null && existing.isWatchLater) return const Success(null);

  final snapshot = catalogSnapshotFrom(item);
  final duration = durationFieldsFrom(suggestion.detail);
  final entry =
      (existing ?? UserMediaEntry(key: item.key, title: snapshot.title))
          .copyWith(
            title: snapshot.title,
            genres: snapshot.genres,
            posterUrl: snapshot.posterUrl,
            voteAverage: snapshot.voteAverage,
            year: snapshot.year,
            runtimeMinutes: duration.runtimeMinutes,
            episodeCount: duration.episodeCount,
            episodeRuntimeMinutes: duration.episodeRuntimeMinutes,
            isWatchLater: true,
          );
  return library.upsert(entry);
}

/// Takes the title at [key] out of Watch later. What else is saved about it (a
/// favorite, a watched date) stays; an entry left in no list at all is deleted.
Future<Result<void>> removeFromWatchLater(
  UserLibraryRepository library,
  MediaKey key,
) async {
  final existing = await library.watchEntry(key).first;
  if (existing == null || !existing.isWatchLater) return const Success(null);
  final left = existing.copyWith(isWatchLater: false);
  final inAList = left.isFavorite || left.isWatchLater || left.isWatched;
  return inAList ? library.upsert(left) : library.remove(key);
}
