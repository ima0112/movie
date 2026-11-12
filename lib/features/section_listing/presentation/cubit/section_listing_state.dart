import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/result.dart';
import '../../domain/listing_source.dart';

/// The "See all" listing's state. [sort] is always the order being shown or
/// loaded.
sealed class SectionListingState {
  const SectionListingState({required this.sort});

  final ListingSort sort;
}

/// The first page is on its way (opening, or after a re-sort / retry).
final class SectionListingLoading extends SectionListingState {
  const SectionListingLoading({required super.sort});
}

final class SectionListingError extends SectionListingState {
  const SectionListingError({required super.sort, required this.reason});

  final FailureReason reason;
}

/// At least the first page is loaded; more arrive as the user scrolls.
final class SectionListingLoaded extends SectionListingState {
  const SectionListingLoaded({
    required super.sort,
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalResults,
    this.loadingMore = false,
    this.moreFailed = false,
  });

  final List<MediaItem> items;

  /// The last page that was loaded.
  final int page;
  final int totalPages;
  final int totalResults;

  /// A next page is being fetched (the grid shows a spinner footer).
  final bool loadingMore;

  /// The last attempt at a next page failed (the footer shows "Retry").
  final bool moreFailed;

  bool get hasMore => page < totalPages;

  SectionListingLoaded copyWith({
    List<MediaItem>? items,
    int? page,
    int? totalPages,
    int? totalResults,
    bool? loadingMore,
    bool? moreFailed,
  }) => SectionListingLoaded(
    sort: sort,
    items: items ?? this.items,
    page: page ?? this.page,
    totalPages: totalPages ?? this.totalPages,
    totalResults: totalResults ?? this.totalResults,
    loadingMore: loadingMore ?? this.loadingMore,
    moreFailed: moreFailed ?? this.moreFailed,
  );
}
