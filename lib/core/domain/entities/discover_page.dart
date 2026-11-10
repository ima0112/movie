import 'media_item.dart';

/// One page of a paginated list (`/discover`, or a collection endpoint like
/// `/movie/now_playing`) — what the "See all" listing loads as it scrolls.
final class DiscoverPage {
  const DiscoverPage({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalResults,
  });

  final List<MediaItem> items;

  /// 1-based number of this page.
  final int page;

  /// How many pages exist (TMDB caps a query at 500).
  final int totalPages;

  /// How many results the whole query has.
  final int totalResults;

  bool get hasMore => page < totalPages;

  static const empty = DiscoverPage(
    items: [],
    page: 1,
    totalPages: 1,
    totalResults: 0,
  );
}
