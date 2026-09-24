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
  FilteredListCubit(
    this._mediaRepository,
    DiscoverFilter initialFilter, {
    CarouselSection? collectionSection,
  }) : // An initializing formal here would force this public parameter
       // to share `_collectionSection`'s private name, which external
       // callers couldn't then pass by name.
       // ignore: prefer_initializing_formals
       _collectionSection = collectionSection,
       super(FilteredListInitial(filter: initialFilter));

  final MediaRepository _mediaRepository;

  /// Set only when this listing started from a Discover collection
  /// ("See all") that arrived with no filter touched yet —
  /// `docs/SCREENS.md` C1's own "Source" line: "'See all' collections
  /// use their own endpoint until a filter is touched, at which point
  /// they switch to the equivalent /discover call." [updateFilter]
  /// clears this the first time it runs, since that's the "a filter is
  /// touched" moment; every other origin (a B2 genre tile, H8's "See N
  /// results") already arrives with a real filter, so this stays `null`
  /// for them from the start. Under today's `FakeMediaRepository`, every
  /// [CarouselSection] returns the same 10-item pool regardless of which
  /// one it is (only `becauseYouLike` branches on anything), so this
  /// makes no visible difference yet — it's here for when a real
  /// TMDB-backed repository actually has distinct per-collection
  /// endpoints.
  CarouselSection? _collectionSection;

  /// How many more items [loadMore] reveals per call — C1's "3-column
  /// grid", so 12 is 4 full rows at a time.
  static const int pageSize = 12;

  Future<void> load() => _fetch(state.filter);

  /// H8 applying a different filter set while C1 is already open (e.g.
  /// "Reset", or changing "sort by") — re-fetches from scratch.
  Future<void> updateFilter(DiscoverFilter filter) {
    _collectionSection = null;
    return _fetch(filter);
  }

  /// The error state's "Retry".
  Future<void> retry() => _fetch(state.filter);

  Future<void> _fetch(DiscoverFilter filter) async {
    emit(FilteredListLoading(filter: filter));

    final section = _collectionSection;
    final result = section != null
        ? await _mediaRepository.getCarouselSection(section, type: filter.type)
        : await _mediaRepository.discover(filter);
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
