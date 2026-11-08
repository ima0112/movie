import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/result.dart';

/// C1 (Filtered listing)'s load state — `docs/SCREENS.md` C1.
///
/// Split out of `filtered_list_cubit.dart` per CLAUDE.md rule 11.
sealed class FilteredListState {
  const FilteredListState({required this.filter});

  final DiscoverFilter filter;
}

/// Before [FilteredListCubit.load] has been called.
final class FilteredListInitial extends FilteredListState {
  const FilteredListInitial({required super.filter});
}

/// Fetching [filter]'s results.
final class FilteredListLoading extends FilteredListState {
  const FilteredListLoading({required super.filter});
}

/// [allItems] is the *entire* filtered/sorted result `discover()`
/// returned; [visibleCount] is how much of it C1's grid has revealed so
/// far. `MediaRepository.discover` has no page parameter yet (see
/// `explore-domain`'s own commit — a deliberate, narrower scope than a
/// real TMDB-backed `/discover` call eventually needs), so "infinite
/// scroll" here means paginating client-side over one already-fetched
/// list, not fetching another page from the repository each time — a
/// real `MediaRepositoryImpl` will need this class's [visibleCount]
/// mechanism replaced with true server-side paging, not its callers.
final class FilteredListLoaded extends FilteredListState {
  const FilteredListLoaded({
    required super.filter,
    required this.allItems,
    required this.visibleCount,
  });

  final List<MediaItem> allItems;
  final int visibleCount;

  /// C1's own "312 results" line — the true total, not just what's
  /// currently revealed.
  int get totalCount => allItems.length;

  List<MediaItem> get visibleItems => allItems.take(visibleCount).toList();

  bool get hasMore => visibleCount < allItems.length;
}

/// The `discover()` call failed.
final class FilteredListError extends FilteredListState {
  const FilteredListError({required super.filter, required this.reason});

  final FailureReason reason;
}
