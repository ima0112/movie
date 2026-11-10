import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/domain/entities/discover_page.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_key.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/domain/services/carousel_section_filter.dart';
import '../../domain/listing_source.dart';
import 'section_listing_state.dart';

/// The "See all" listing (`docs/SCREENS.md` C1b): a [ListingSource] loaded one
/// page at a time as the user scrolls, re-sortable. Screen-local (CLAUDE.md
/// rule 10).
///
/// [loadMore] is idempotent while a page is in flight; pages are
/// de-duplicated by title (TMDB can repeat one across pages when a ranking
/// shifts between requests). A generation counter drops any response that
/// belongs to a sort the user has since left.
class SectionListingCubit extends Cubit<SectionListingState> {
  SectionListingCubit(
    this._mediaRepository,
    this.source, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       super(const SectionListingLoading(sort: ListingSort.byDefault));

  final MediaRepository _mediaRepository;
  final ListingSource source;
  final DateTime Function() _clock;
  int _generation = 0;

  /// A page made only of titles already shown doesn't leave the grid empty-
  /// handed at its end: [loadMore] keeps going, up to this many pages.
  static const int _maxSkippedPages = 3;

  /// The least votes a title needs for the Rating sort, so a 10.0 from three
  /// votes can't top the list.
  static const int ratingMinVotes = 200;

  Future<void> load() => _loadFirst(state.sort);

  Future<void> retry() => _loadFirst(state.sort);

  Future<void> setSort(ListingSort sort) async {
    if (sort == state.sort || !source.sorts.contains(sort)) return;
    await _loadFirst(sort);
  }

  Future<void> _loadFirst(ListingSort sort) async {
    final generation = ++_generation;
    emit(SectionListingLoading(sort: sort));
    final result = await _fetch(sort, 1);
    if (generation != _generation || isClosed) return;
    switch (result) {
      case Success<DiscoverPage>(:final value):
        emit(
          SectionListingLoaded(
            sort: sort,
            items: _unique(const [], value.items),
            page: value.page,
            totalPages: value.totalPages,
            totalResults: value.totalResults,
          ),
        );
      case Failure<DiscoverPage>(:final reason):
        emit(SectionListingError(sort: sort, reason: reason));
    }
  }

  /// Loads the next page, if there is one and none is already loading.
  Future<void> loadMore() async {
    final generation = _generation;
    final start = state;
    if (start is! SectionListingLoaded || !start.hasMore || start.loadingMore) {
      return;
    }
    var current = start;
    for (var skipped = 0; skipped <= _maxSkippedPages; skipped++) {
      emit(current.copyWith(loadingMore: true, moreFailed: false));
      final result = await _fetch(current.sort, current.page + 1);
      if (generation != _generation || isClosed) return;
      final now = state;
      if (now is! SectionListingLoaded) return;
      switch (result) {
        case Failure<DiscoverPage>():
          emit(now.copyWith(loadingMore: false, moreFailed: true));
          return;
        case Success<DiscoverPage>(:final value):
          final merged = _unique(now.items, value.items);
          final added = merged.length - now.items.length;
          current = now.copyWith(
            items: merged,
            page: value.page,
            totalPages: value.totalPages,
            totalResults: value.totalResults,
            loadingMore: false,
          );
          emit(current);
          if (added > 0 || !current.hasMore) return;
      }
    }
  }

  /// The footer's "Retry" after a failed next page.
  Future<void> retryMore() => loadMore();

  /// Pull-to-refresh: start again in the current sort.
  Future<void> refresh() => _loadFirst(state.sort);

  Future<Result<DiscoverPage>> _fetch(ListingSort sort, int page) {
    final source = this.source;
    switch (source) {
      case FilterListing():
        return _mediaRepository.discoverPage(
          _sorted(source.filter, sort),
          page: page,
        );
      case CollectionListing(:final section, :final type):
        if (sort == ListingSort.byDefault) {
          return _mediaRepository.carouselSectionPage(
            section,
            type: type,
            page: page,
          );
        }
        final base =
            carouselSectionFilter(section, type: type, today: _clock()) ??
            DiscoverFilter(type: type);
        return _mediaRepository.discoverPage(_sorted(base, sort), page: page);
    }
  }

  DiscoverFilter _sorted(DiscoverFilter filter, ListingSort sort) {
    final by = sort.discoverSort;
    if (by == null) return filter;
    return filter.copyWith(
      sortBy: by,
      minVoteCount: sort == ListingSort.rating
          ? math.max(filter.minVoteCount, ratingMinVotes)
          : null,
    );
  }

  List<MediaItem> _unique(List<MediaItem> shown, List<MediaItem> incoming) {
    final seen = <MediaKey>{for (final item in shown) item.key};
    return [
      ...shown,
      for (final item in incoming)
        if (seen.add(item.key)) item,
    ];
  }
}
