/// A streaming service TMDB (JustWatch) lists for the user's region — what
/// B2's "Platform" pills show and filter by (`DiscoverFilter.withWatchProviders`
/// takes its [id]).
///
/// Split into its own file per CLAUDE.md rule 13: it has an identity of its
/// own and is used by the repository interface, the filter row and its tests.
final class StreamingService {
  const StreamingService({required this.id, required this.name, this.logoUrl});

  /// TMDB's provider id (`with_watch_providers`).
  final int id;
  final String name;

  /// The logo's full URL, or `null` when TMDB has none (the pill then shows
  /// the name's first letter).
  final String? logoUrl;

  @override
  bool operator ==(Object other) =>
      other is StreamingService &&
      other.id == id &&
      other.name == name &&
      other.logoUrl == logoUrl;

  @override
  int get hashCode => Object.hash(id, name, logoUrl);

  @override
  String toString() => 'StreamingService($id, $name)';
}
