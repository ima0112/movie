import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/domain/entities/discover_page.dart';
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

  /// Provider id → name, for the chip of a streaming-service filter.
  Map<int, String> _providerNames = const {};

  /// Bumped by every [_fetch], so a slow answer to an old filter can't land
  /// over a newer one's (also guards [loadMore]'s page request).
  int _generation = 0;
  int _page = 1;
  bool _loadingMore = false;

  Future<void> _fetch(DiscoverFilter filter) async {
    final generation = ++_generation;
    _loadingMore = false;
    _page = 1;
    emit(FilteredListLoading(filter: filter, providerNames: _providerNames));

    final section = _collectionSection;
    final namesFuture = _loadProviderNames(filter);
    final Result<DiscoverPage> result;
    if (section != null) {
      result = switch (await _mediaRepository.getCarouselSection(
        section,
        type: filter.type,
      )) {
        Success(:final value) => Success(
          DiscoverPage(
            items: value,
            page: 1,
            totalPages: 1,
            totalResults: value.length,
          ),
        ),
        Failure(:final reason) => Failure(reason),
      };
    } else {
      result = await _mediaRepository.discoverPage(filter);
    }
    await namesFuture;
    if (isClosed || generation != _generation) return;

    switch (result) {
      case Success<DiscoverPage>(:final value):
        emit(
          FilteredListLoaded(
            filter: filter,
            providerNames: _providerNames,
            allItems: value.items,
            visibleCount: math.min(pageSize, value.items.length),
            totalCount: value.totalResults,
            hasMorePages: value.page < value.totalPages,
          ),
        );
      case Failure<DiscoverPage>(:final reason):
        emit(
          FilteredListError(
            filter: filter,
            providerNames: _providerNames,
            reason: reason,
          ),
        );
    }
  }

  /// Fetches the names of the streaming services [filter] uses, once; a
  /// failure just leaves the chip without a name to show (it is then left
  /// out, the filter still applies).
  Future<void> _loadProviderNames(DiscoverFilter filter) async {
    final missing = filter.withWatchProviders.where(
      (id) => !_providerNames.containsKey(id),
    );
    if (missing.isEmpty) return;
    final result = await _mediaRepository.streamingServices(type: filter.type);
    if (result case Success(:final value)) {
      _providerNames = {
        ..._providerNames,
        for (final service in value) service.id: service.name,
      };
    }
  }

  /// C1's infinite scroll — reveals the next [pageSize] already-fetched
  /// items and, once those run out, asks TMDB for the next page. A no-op
  /// while a page is on its way, once everything is visible, or if nothing
  /// has loaded (yet, or failed); a page that fails is simply asked for again
  /// on the next scroll.
  Future<void> loadMore() async {
    final current = state;
    if (current is! FilteredListLoaded || !current.hasMore) return;

    if (current.visibleCount < current.allItems.length) {
      emit(_revealed(current, current.allItems));
      return;
    }
    if (_loadingMore) return;

    _loadingMore = true;
    final generation = _generation;
    final result = await _mediaRepository.discoverPage(
      current.filter,
      page: _page + 1,
    );
    _loadingMore = false;
    if (isClosed || generation != _generation) return;

    if (result case Success<DiscoverPage>(:final value)) {
      _page = value.page;
      final known = {for (final item in current.allItems) item.key};
      final items = [
        ...current.allItems,
        for (final item in value.items)
          if (known.add(item.key)) item,
      ];
      emit(
        _revealed(
          current,
          items,
          totalCount: value.totalResults,
          hasMorePages: value.page < value.totalPages,
        ),
      );
    }
  }

  FilteredListLoaded _revealed(
    FilteredListLoaded from,
    List<MediaItem> items, {
    int? totalCount,
    bool? hasMorePages,
  }) => FilteredListLoaded(
    filter: from.filter,
    providerNames: from.providerNames,
    allItems: items,
    visibleCount: math.min(from.visibleCount + pageSize, items.length),
    totalCount: totalCount ?? from.totalCount,
    hasMorePages: hasMorePages ?? from.hasMorePages,
  );
}
