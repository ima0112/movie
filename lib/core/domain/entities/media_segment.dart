import 'media_type.dart';

/// The three-way segmented control reused across Discover, Explore, My
/// List, and filmography.
///
/// Source of truth: `docs/SCREENS.md` ("Segmented control **All | Movies |
/// TV Shows**"). Distinct from [MediaType]: [all] has no `MediaType`
/// counterpart — it isn't a catalog kind, it means "don't filter by kind".
enum MediaSegment {
  all,
  movie,
  tvShow;

  /// The [MediaType] filter this segment implies for a repository call —
  /// `null` for [all] (no filter).
  MediaType? get mediaType => switch (this) {
    MediaSegment.all => null,
    MediaSegment.movie => MediaType.movie,
    MediaSegment.tvShow => MediaType.tvShow,
  };
}
