/// A normalized genre, stable across movies and TV shows.
///
/// TMDB keeps separate — and sometimes differently named, e.g. "Action &
/// Adventure" for TV vs "Action" for movies — genre IDs per media type.
/// This entity is the normalized shape the rest of the app works with;
/// the TMDB-id mapping lives in `data/tmdb/` (never here — `domain` never
/// imports networking or DTOs, see the project's CLAUDE.md).
///
/// Source of truth: `docs/STRUCTURE.md`, `core/domain/entities/genre.dart`
/// — "normalized genre + TMDB mapping".
class Genre {
  const Genre({required this.id, required this.name});

  /// Stable, normalized identifier (e.g. `"action"`) — not a raw TMDB id.
  final String id;

  final String name;

  @override
  bool operator ==(Object other) => other is Genre && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Genre($id, $name)';
}
