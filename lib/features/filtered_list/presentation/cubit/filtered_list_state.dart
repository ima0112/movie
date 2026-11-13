import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/result.dart';

/// C1 (Filtered listing)'s load state — `docs/SCREENS.md` C1.
///
/// Split out of `filtered_list_cubit.dart` per CLAUDE.md rule 11.
sealed class FilteredListState {
  const FilteredListState({
    required this.filter,
    this.providerNames = const {},
  });

  final DiscoverFilter filter;

  /// Display names of the streaming services in [filter] (provider id →
  /// name), so the active-filter chip can say "Netflix" and not an id.
  /// Filled in as soon as the names are known.
  final Map<int, String> providerNames;
}

/// Before [FilteredListCubit.load] has been called.
final class FilteredListInitial extends FilteredListState {
  const FilteredListInitial({required super.filter, super.providerNames});
}

/// Fetching [filter]'s results.
final class FilteredListLoading extends FilteredListState {
  const FilteredListLoading({required super.filter, super.providerNames});
}

/// [allItems] is what has been fetched so far (one TMDB page at a time, more
/// requested as the grid nears its end); [visibleCount] is how much of it the
/// grid has revealed. [totalCount] is TMDB's own total for the filter — the
/// "38 results" line — which can be more than [allItems] holds.
final class FilteredListLoaded extends FilteredListState {
  const FilteredListLoaded({
    required super.filter,
    super.providerNames,
    required this.allItems,
    required this.visibleCount,
    int? totalCount,
    this.hasMorePages = false,
    // An initializing formal would make the public `totalCount` parameter
    // share the private field's name.
    // ignore: prefer_initializing_formals
  }) : _totalCount = totalCount;

  final List<MediaItem> allItems;
  final int visibleCount;
  final int? _totalCount;

  /// Whether TMDB has more pages beyond [allItems].
  final bool hasMorePages;

  /// C1's own "312 results" line — the true total, not just what's
  /// currently fetched or revealed.
  int get totalCount => _totalCount ?? allItems.length;

  List<MediaItem> get visibleItems => allItems.take(visibleCount).toList();

  bool get hasMore => visibleCount < allItems.length || hasMorePages;
}

/// The `discover()` call failed.
final class FilteredListError extends FilteredListState {
  const FilteredListError({
    required super.filter,
    super.providerNames,
    required this.reason,
  });

  final FailureReason reason;
}
