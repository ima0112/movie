import 'media_type.dart';

/// Identifies one library entry: a movie or TV show by its TMDB id.
///
/// TV shows are tracked at the whole-show level — see
/// `docs/DECISIONS.md` section 4 ("TV shows: marked watched at the
/// whole-show level"), never per season/episode. Used as a `Map` key by
/// `InMemoryUserLibraryRepository`, hence the value equality.
class MediaKey {
  const MediaKey({required this.type, required this.tmdbId});

  final MediaType type;
  final int tmdbId;

  @override
  bool operator ==(Object other) =>
      other is MediaKey && other.type == type && other.tmdbId == tmdbId;

  @override
  int get hashCode => Object.hash(type, tmdbId);

  @override
  String toString() => 'MediaKey($type, $tmdbId)';
}
