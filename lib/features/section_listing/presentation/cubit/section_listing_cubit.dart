import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/discover_page.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_key.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../domain/listing_source.dart';
import 'section_listing_state.dart';

/// The "See all" listing (`docs/SCREENS.md` C1b). Screen-local (CLAUDE.md
/// rule 10).
///
/// **The list is a fixed set**: the first [maxItems] titles of the section in
/// its own order. It is loaded page by page as the user scrolls (so opening
/// costs one request), kept in memory in [_pool], and **re-sorting reorders
/// that same set on the client** — it never asks TMDB for a different list.
/// Another order needs the whole set, so the first time one is picked the
/// missing pages (up to [maxItems]) are fetched in parallel; after that, any
/// order — including going back to the section's own — is instant and costs no
/// request. The pool lives only as long as this Cubit (nothing is persisted or
/// shared); pull-to-refresh drops it and starts over.
///
/// [loadMore] is idempotent while a page is in flight; pages are de-duplicated
/// by title; a generation counter drops any response that belongs to a load the
/// user has since left.
class SectionListingCubit extends Cubit<SectionListingState> {
  SectionListingCubit(this._mediaRepository, this.source)
    : super(const SectionListingLoading(sort: ListingSort.byDefault));

  final MediaRepository _mediaRepository;
  final ListingSource source;

  /// The most titles a listing holds ("Top 100").
  static const int maxItems = 100;

  /// A page made only of titles already shown doesn't leave the grid empty-
  /// handed at its end: [loadMore] keeps going, up to this many pages.
  static const int _maxSkippedPages = 3;

  /// The section's titles in its own order, de-duplicated, at most [maxItems].
  final List<MediaItem> _pool = [];
  final Set<MediaKey> _keys = {};
  int _page = 0;
  int _totalPages = 1;
  FailureReason? _failure;
  int _generation = 0;

  /// Nothing more to fetch: the cap is reached or the last page is in.
  bool get _complete => _pool.length >= maxItems || _page >= _totalPages;

  Future<void> load() => _start(state.sort);

  Future<void> retry() => _start(state.sort);

  /// Pull-to-refresh: forget the pool and start again in the current order.
  Future<void> refresh() => _start(state.sort);

  Future<void> setSort(ListingSort sort) async {
    if (sort == state.sort || !source.sorts.contains(sort)) return;
    if (_pool.isEmpty) return _start(sort);
    await _show(sort, ++_generation);
  }

  Future<void> _start(ListingSort sort) async {
    final generation = ++_generation;
    emit(SectionListingLoading(sort: sort));
    _pool.clear();
    _keys.clear();
    _page = 0;
    _totalPages = 1;

    final result = await _fetch(1);
    if (generation != _generation || isClosed) return;
    switch (result) {
      case Failure<DiscoverPage>(:final reason):
        emit(SectionListingError(sort: sort, reason: reason));
      case Success<DiscoverPage>(:final value):
        _absorb(value);
        await _show(sort, generation);
    }
  }

  /// Shows the pool in [sort]'s order, completing it first when another order
  /// than the section's own needs the whole set.
  Future<void> _show(ListingSort sort, int generation) async {
    if (sort != ListingSort.byDefault && !_complete) {
      emit(SectionListingLoading(sort: sort));
      final ok = await _completePool(generation);
      if (generation != _generation || isClosed) return;
      if (!ok) {
        emit(SectionListingError(sort: sort, reason: _failure!));
        return;
      }
    }
    if (generation != _generation || isClosed) return;
    emit(_loaded(sort));
  }

  /// Fetches the pages that are missing, in parallel, until the pool is
  /// complete. `false` if any of them failed ([_failure] says why).
  Future<bool> _completePool(int generation) async {
    for (var round = 0; round < 3 && !_complete; round++) {
      final perPage = math.max(1, _pool.length ~/ math.max(1, _page));
      final pagesNeeded = ((maxItems - _pool.length) / perPage).ceil();
      final last = math.min(_totalPages, _page + pagesNeeded);
      final results = await Future.wait([
        for (var p = _page + 1; p <= last; p++) _fetch(p),
      ]);
      if (generation != _generation || isClosed) return false;
      for (final result in results) {
        switch (result) {
          case Failure<DiscoverPage>(:final reason):
            _failure = reason;
            return false;
          case Success<DiscoverPage>(:final value):
            _absorb(value);
        }
      }
    }
    return true;
  }

  /// Loads the next page of the section's own order, if there is one and none
  /// is already loading.
  Future<void> loadMore() async {
    final generation = _generation;
    final start = state;
    if (start is! SectionListingLoaded || !start.hasMore || start.loadingMore) {
      return;
    }
    emit(start.copyWith(loadingMore: true, moreFailed: false));
    for (var skipped = 0; skipped <= _maxSkippedPages; skipped++) {
      final before = _pool.length;
      final result = await _fetch(_page + 1);
      if (generation != _generation || isClosed) return;
      final now = state;
      if (now is! SectionListingLoaded) return;
      switch (result) {
        case Failure<DiscoverPage>():
          emit(now.copyWith(loadingMore: false, moreFailed: true));
          return;
        case Success<DiscoverPage>(:final value):
          _absorb(value);
          final loaded = _loaded(ListingSort.byDefault);
          emit(loaded);
          if (_pool.length > before || _complete) return;
          emit(loaded.copyWith(loadingMore: true));
      }
    }
    final now = state;
    if (now is SectionListingLoaded) emit(now.copyWith(loadingMore: false));
  }

  /// The footer's "Retry" after a failed next page.
  Future<void> retryMore() => loadMore();

  Future<Result<DiscoverPage>> _fetch(int page) {
    final source = this.source;
    return switch (source) {
      FilterListing() => _mediaRepository.discoverPage(
        source.filter,
        page: page,
      ),
      CollectionListing(:final section, :final type) =>
        _mediaRepository.carouselSectionPage(section, type: type, page: page),
    };
  }

  /// Adds a page's new titles to the pool (up to [maxItems]).
  void _absorb(DiscoverPage page) {
    _page = math.max(_page, page.page);
    _totalPages = page.totalPages;
    for (final item in page.items) {
      if (_pool.length >= maxItems) break;
      if (_keys.add(item.key)) _pool.add(item);
    }
  }

  SectionListingLoaded _loaded(ListingSort sort) => SectionListingLoaded(
    sort: sort,
    items: sort == ListingSort.byDefault ? List.of(_pool) : _sorted(sort),
    page: _page,
    hasMore: sort == ListingSort.byDefault && !_complete,
  );

  /// The pool in [sort]'s order; ties keep the section's own order.
  List<MediaItem> _sorted(ListingSort sort) {
    final indexed = [for (var i = 0; i < _pool.length; i++) (i, _pool[i])];
    int compare((int, MediaItem) a, (int, MediaItem) b) {
      final byKey = switch (sort) {
        ListingSort.byDefault => 0,
        ListingSort.popularity => (b.$2.popularity ?? -1).compareTo(
          a.$2.popularity ?? -1,
        ),
        ListingSort.rating => _thenVotes(a.$2, b.$2),
        ListingSort.mostVoted => (b.$2.voteCount ?? -1).compareTo(
          a.$2.voteCount ?? -1,
        ),
        ListingSort.newest => _newestFirst(a.$2, b.$2),
      };
      return byKey != 0 ? byKey : a.$1.compareTo(b.$1);
    }

    indexed.sort(compare);
    return [for (final entry in indexed) entry.$2];
  }

  /// Higher rating first; among equal ratings, the one with more votes.
  int _thenVotes(MediaItem a, MediaItem b) {
    final byRating = b.voteAverage.compareTo(a.voteAverage);
    return byRating != 0
        ? byRating
        : (b.voteCount ?? -1).compareTo(a.voteCount ?? -1);
  }

  /// Latest release first; titles with no date last.
  int _newestFirst(MediaItem a, MediaItem b) {
    final da = a.releaseDate;
    final db = b.releaseDate;
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return db.compareTo(da);
  }
}
