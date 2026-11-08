import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import 'filtered_list_state.dart';

/// C1 (Filtered listing)'s Cubit — `docs/SCREENS.md` C1: "See all ·
/// Genre · Results", reached from a B2 genre tile, H8's "See N
/// results", or B1's "See all". Screen-local, constructed with
/// whichever [DiscoverFilter] got the user here (per this task's own
/// "recibe un DiscoverFilter inicial").
///
/// Matches `DiscoverCubit`'s own convention: the constructor only
/// stores what it needs, [load] is a separate explicit call the screen
/// makes right after constructing this Cubit — not fired automatically,
/// so a widget test can build the Cubit and control exactly when the
/// fetch happens.
class FilteredListCubit extends Cubit<FilteredListState> {
  FilteredListCubit(this._mediaRepository, DiscoverFilter initialFilter)
    : super(FilteredListInitial(filter: initialFilter));

  final MediaRepository _mediaRepository;

  /// How many more items [loadMore] reveals per call — C1's "3-column
  /// grid", so 12 is 4 full rows at a time.
  static const int pageSize = 12;

  Future<void> load() => _fetch(state.filter);

  /// H8 applying a different filter set while C1 is already open (e.g.
  /// "Reset", or changing "sort by") — re-fetches from scratch.
  Future<void> updateFilter(DiscoverFilter filter) => _fetch(filter);

  /// The error state's "Retry".
  Future<void> retry() => _fetch(state.filter);

  Future<void> _fetch(DiscoverFilter filter) async {
    emit(FilteredListLoading(filter: filter));

    final result = await _mediaRepository.discover(filter);
    if (isClosed) return;

    switch (result) {
      case Success<List<MediaItem>>(:final value):
        emit(
          FilteredListLoaded(
            filter: filter,
            allItems: value,
            visibleCount: math.min(pageSize, value.length),
          ),
        );
      case Failure<List<MediaItem>>(:final message):
        emit(FilteredListError(filter: filter, message: message));
    }
  }

  /// C1's infinite scroll — reveals the next [pageSize] already-fetched
  /// items. A no-op once [FilteredListLoaded.hasMore] is false, or if
  /// nothing has loaded (yet, or failed).
  void loadMore() {
    final current = state;
    if (current is! FilteredListLoaded || !current.hasMore) return;

    emit(
      FilteredListLoaded(
        filter: current.filter,
        allItems: current.allItems,
        visibleCount: math.min(
          current.visibleCount + pageSize,
          current.allItems.length,
        ),
      ),
    );
  }
}
