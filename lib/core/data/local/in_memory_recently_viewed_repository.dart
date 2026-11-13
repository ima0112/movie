import 'dart:async';

import '../../domain/entities/media_item.dart';
import '../../domain/entities/result.dart';
import '../../domain/repositories/recently_viewed_repository.dart';

/// In-memory stand-in for [RecentlyViewedRepository] — a fast test double
/// (unannotated: only the drift one is registered). Same rules as the real one:
/// newest first, a re-recorded title moves to the front, capped at
/// [RecentlyViewedRepository.limit].
class InMemoryRecentlyViewedRepository implements RecentlyViewedRepository {
  InMemoryRecentlyViewedRepository([List<MediaItem> initial = const []])
    : _items = [...initial];

  List<MediaItem> _items;
  final _changes = StreamController<List<MediaItem>>.broadcast();

  @override
  Stream<List<MediaItem>> watch() {
    // The current list on subscribe, then every change — a plain controller
    // (not an `async*` generator, whose cancel can wait on a pending yield).
    late final StreamController<List<MediaItem>> controller;
    StreamSubscription<List<MediaItem>>? changes;
    controller = StreamController<List<MediaItem>>(
      onListen: () {
        controller.add(List.unmodifiable(_items));
        changes = _changes.stream.listen(controller.add);
      },
      onCancel: () => changes?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<Result<void>> record(MediaItem item) async {
    _items = [
      item,
      ..._items.where((e) => e.key != item.key),
    ].take(RecentlyViewedRepository.limit).toList();
    _changes.add(List.unmodifiable(_items));
    return const Success(null);
  }
}
