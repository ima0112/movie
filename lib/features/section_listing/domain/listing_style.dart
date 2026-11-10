import '../../../core/domain/entities/genre.dart';
import '../../../core/domain/entities/media_segment.dart';
import '../../../core/domain/entities/streaming_service.dart';

/// What each poster of a "See all" grid carries, mirroring the carousel it
/// came from.
enum ListingStyle {
  /// Just the poster.
  plain,

  /// A big outlined rank (1, 2, 3…) — only while the list is in its own order.
  ranked,

  /// An amber-star rating badge.
  rating,

  /// The release date and year.
  dated,
}

/// What the screen the user came from had set: shown as the pill under the
/// title. Explore also narrows by genre and platform; Home only by the
/// segment (All / Movies / TV Shows).
class ListingContext {
  const ListingContext.home(this.segment)
    : genre = null,
      platform = null,
      showsFilters = false;

  const ListingContext.explore({
    required this.segment,
    this.genre,
    this.platform,
  }) : showsFilters = true;

  final MediaSegment segment;
  final Genre? genre;
  final StreamingService? platform;

  /// Whether the genre / platform parts are shown at all (Explore only).
  final bool showsFilters;
}
