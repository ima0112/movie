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
  });

  final String key;
  final String site;
  final String type;
  final String name;

  bool get isYoutube => site == 'YouTube';
}
