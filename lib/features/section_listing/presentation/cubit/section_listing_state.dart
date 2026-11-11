import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/result.dart';
import '../../domain/listing_source.dart';

/// The "See all" listing's state. [sort] is always the order being shown or
/// loaded.
sealed class SectionListingState {
  const SectionListingState({required this.sort});

  final ListingSort sort;
}

/// The first page is on its way (opening, a retry, or — for another order —
/// the rest of the list, which has to be complete before it can be sorted).
final class SectionListingLoading extends SectionListingState {
  const SectionListingLoading({required super.sort});
}

final class SectionListingError extends SectionListingState {
  const SectionListingError({required super.sort, required this.reason});

  final FailureReason reason;
}

/// The list, in [sort]'s order. In the section's own order more arrives as the
/// user scrolls; in any other order the whole list is already here.
final class SectionListingLoaded extends SectionListingState {
  const SectionListingLoaded({
    required super.sort,
    required this.items,
    required this.page,
    required this.hasMore,
    this.loadingMore = false,
    this.moreFailed = false,
  });

  /// What is shown, in [sort]'s order.
  final List<MediaItem> items;

  /// The last page that was loaded (what re-arms the next-page trigger).
  final int page;

  /// More pages can still be fetched (only in the section's own order).
  final bool hasMore;

  /// A next page is being fetched (the grid shows a spinner footer).
  final bool loadingMore;

  /// The last attempt at a next page failed (the footer shows "Retry").
  final bool moreFailed;

  SectionListingLoaded copyWith({
    List<MediaItem>? items,
    int? page,
    bool? hasMore,
    bool? loadingMore,
    bool? moreFailed,
  }) => SectionListingLoaded(
    sort: sort,
    items: items ?? this.items,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    loadingMore: loadingMore ?? this.loadingMore,
    moreFailed: moreFailed ?? this.moreFailed,
  );
}
