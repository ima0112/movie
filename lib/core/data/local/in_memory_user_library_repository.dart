import 'dart:async';

import '../../domain/entities/media_key.dart';
import '../../domain/entities/media_type.dart';
import '../../domain/entities/result.dart';
import '../../domain/entities/user_media_entry.dart';
import '../../domain/repositories/user_library_repository.dart';

/// In-memory stand-in for [UserLibraryRepository]. Superseded by
/// `DriftUserLibraryRepository` (`drift_user_library_repository.dart`) as
/// the app's real "My List" storage — kept, unannotated, as a fast,
/// dependency-free test double (see `in_memory_user_library_repository_test.dart`).
/// Not `@LazySingleton` anymore: only one implementation may be
/// registered `as: UserLibraryRepository`, or injectable's codegen fails
/// on the ambiguity.
class InMemoryUserLibraryRepository implements UserLibraryRepository {
  final Map<MediaKey, UserMediaEntry> _entries = {};

  // Broadcasts a ping (no payload) on every write. `watch`/`watchEntry`
  // recompute their own filtered snapshot off `_entries` each time,
  // rather than this controller carrying the data itself.
  final StreamController<void> _changes = StreamController<void>.broadcast();

  List<UserMediaEntry> _matching({LibraryTab? tab, MediaType? type}) {
    return _entries.values
        .where((entry) {
          if (type != null && entry.key.type != type) return false;
          return switch (tab) {
            null => true,
            LibraryTab.favorites => entry.isFavorite,
            LibraryTab.watchLater => entry.isWatchLater,
            LibraryTab.watched => entry.isWatched,
          };
        })
        .toList(growable: false);
  }

  @override
  Stream<List<UserMediaEntry>> watch({
    LibraryTab? tab,
    MediaType? type,
  }) async* {
    // A subscriber joining after entries already exist should see them
    // immediately, not just future changes — hence yielding once upfront.
    yield _matching(tab: tab, type: type);
    await for (final _ in _changes.stream) {
      yield _matching(tab: tab, type: type);
    }
  }

  @override
  Stream<UserMediaEntry?> watchEntry(MediaKey key) async* {
    yield _entries[key];
    await for (final _ in _changes.stream) {
      yield _entries[key];
    }
  }

  @override
  Future<Result<void>> upsert(UserMediaEntry entry) async {
    _entries[entry.key] = entry;
    _changes.add(null);
    return const Success(null);
  }

  @override
  Future<Result<void>> remove(MediaKey key) async {
    _entries.remove(key);
    _changes.add(null);
    return const Success(null);
  }

  @override
  Future<Result<List<MediaKey>>> watchedKeys(
    MediaType type, {
    int limit = 500,
  }) async {
    final watched =
        _entries.values
            .where((entry) => entry.key.type == type && entry.isWatched)
            .toList()
          ..sort((a, b) => b.watchedAt!.compareTo(a.watchedAt!));
    return Success(watched.take(limit).map((entry) => entry.key).toList());
  }

  @override
  Future<Result<List<UserMediaEntry>>> all() async {
    return Success(_entries.values.toList(growable: false));
  }
}
