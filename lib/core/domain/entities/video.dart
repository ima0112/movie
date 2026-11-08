/// A YouTube (or other site) video — a trailer, teaser, etc.
///
/// Split into its own file per CLAUDE.md rule 13: reused independently
/// for season trailers (the future H4 season sheet), not just by
/// `MediaDetail` (`media_detail.dart`).
final class Video {
  const Video({
    required this.key,
    required this.site,
    required this.type,
    required this.name,
    this.official = false,
    this.iso6391 = '',
  });

  final String key;
  final String site;
  final String type;
  final String name;

  /// TMDB's own "official" flag — part of `MediaDetail.trailer`'s own
  /// selection ladder (`docs/SCREENS.md` D1).
  final bool official;

  /// ISO 639-1 language code (`"en"`, `"es"`...), `''` when TMDB didn't
  /// report one.
  final String iso6391;

  bool get isYoutube => site == 'YouTube';
}
