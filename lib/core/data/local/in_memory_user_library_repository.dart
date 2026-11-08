import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../domain/entities/media_key.dart';
import '../../domain/entities/media_type.dart';
import '../../domain/entities/result.dart';
import '../../domain/entities/user_media_entry.dart';
import '../../domain/repositories/user_library_repository.dart';

// TODO(drift): replace with a persistent implementation (SQLite via
// drift, `user_media` table — see docs/STRUCTURE.md) once My List is
// built. Everything here is lost on app restart.
/// In-memory stand-in for [UserLibraryRepository].
///
/// `@LazySingleton` on purpose, not per-screen: its whole point is that
/// state survives for as long as the app is open and is the *same* for
/// every screen that reads it (My List, a detail screen's action row,
/// Stats...) — a new instance per screen would defeat that entirely. See
/// the project's CLAUDE.md rule 10 ("Global vs. screen-local Cubits" —
/// the same lifecycle argument applies to this repository).
@LazySingleton(as: UserLibraryRepository)
class InMemoryUserLibraryRepository implements UserLibraryRepository {
  final Map<MediaKey, UserMediaEntry> _entries = {};

  // Broadcasts a ping (no payload) on every write. `watch`/`watchEntry`
  // recompute their own filtered snapshot off `_entries` each time,
  // rather than this controller carrying the data itself.
  final StreamController<void> _changes = StreamController<void>.broadcast();

  List<UserMediaEntry> _matching({LibraryTab? tab, MediaType? type}) {
    return _entries.values.where((entry) {
      if (type != null && entry.key.type != type) return false;
      return switch (tab) {
        null => true,
        LibraryTab.favorites => entry.isFavorite,
        LibraryTab.watchLater => entry.isWatchLater,
        LibraryTab.watched => entry.isWatched,
      };
    }).toList(growable: false);
  }

  @override
  Stream<List<UserMediaEntry>> watch({LibraryTab? tab, MediaType? type}) async* {
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
