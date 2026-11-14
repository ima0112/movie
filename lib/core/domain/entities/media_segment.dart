import 'media_type.dart';

/// The segmented control of Discover and Explore: All | Movies | TV Shows,
/// and — in Explore only — People.
///
/// Source of truth: `docs/SCREENS.md` ("Segmented control **All | Movies |
/// TV Shows**"). Distinct from [MediaType]: [all] has no `MediaType`
/// counterpart — it isn't a catalog kind, it means "don't filter by kind".
enum MediaSegment {
  all,
  movie,
  tvShow,

  /// Explore only: search results narrowed to people. Not a catalog kind —
  /// there is nothing to browse for it, so no repository call takes it.
  person;

  /// The segments of Discover and every other control that lists titles:
  /// everything but [person].
  static const List<MediaSegment> media = [all, movie, tvShow];

  /// Explore's segments: the titles' ones and then [person].
  static const List<MediaSegment> explore = [all, movie, tvShow, person];

  /// The [MediaType] filter this segment implies for a repository call —
  /// `null` for [all] (no filter) and for [person] (no catalog kind).
  MediaType? get mediaType => switch (this) {
    MediaSegment.all || MediaSegment.person => null,
    MediaSegment.movie => MediaType.movie,
    MediaSegment.tvShow => MediaType.tvShow,
  };
}
