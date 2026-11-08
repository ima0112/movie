import '../../domain/entities/genre.dart';
import '../../domain/entities/genre_catalog.dart';
import '../../domain/entities/media_type.dart';

/// TMDB's own numeric genre ids → this app's normalized [Genre] catalog
/// — kept here, not on [Genre] itself: `genre.dart`'s own doc comment is
/// explicit that "the TMDB-id mapping lives in `data/tmdb/` (never
/// here)", since `domain` never imports networking/DTOs (CLAUDE.md rule
/// 1) and a TMDB numeric id is exactly the kind of external-system detail
/// that rule means to keep out.
///
/// TMDB keeps separate id spaces per media type with some genres merged
/// differently on the TV side — two deliberate choices on how those
/// merges fold into our smaller, 15-genre catalog:
/// - TV's "Action & Adventure" (10759) → [GenreCatalog.all]'s `action`.
/// - TV's "Sci-Fi & Fantasy" (10765) → `sci-fi`.
///
/// Several TMDB genres have **no equivalent at all** in
/// [GenreCatalog.all] (Fantasy, War, Western, TV Movie, Kids, News,
/// Reality, Soap, Talk, War & Politics) — [fromTmdbId] returns `null`
/// for those, and callers (`tmdb_mappers.dart`) simply drop them from a
/// title's genre list rather than inventing a catch-all bucket.
abstract final class TmdbGenreMapper {
  static const Map<int, String> _movieIds = {
    28: 'action',
    12: 'adventure',
    16: 'animation',
    35: 'comedy',
    80: 'crime',
    99: 'documentary',
    18: 'drama',
    10751: 'family',
    36: 'history',
    27: 'horror',
    10402: 'music',
    9648: 'mystery',
    10749: 'romance',
    878: 'sci-fi',
    53: 'thriller',
  };

  static const Map<int, String> _tvIds = {
    10759: 'action', // "Action & Adventure" — see class doc comment.
    16: 'animation',
    35: 'comedy',
    80: 'crime',
    99: 'documentary',
    18: 'drama',
    10751: 'family',
    9648: 'mystery',
    10765: 'sci-fi', // "Sci-Fi & Fantasy" — see class doc comment.
    37: 'thriller',
  };

  /// `null` when [tmdbId] has no equivalent in [GenreCatalog.all] for
  /// this [type] — a real, expected outcome (see class doc comment), not
  /// an error.
  static Genre? fromTmdbId(int tmdbId, MediaType type) {
    final ids = switch (type) {
      MediaType.movie => _movieIds,
      MediaType.tvShow => _tvIds,
    };
    final normalizedId = ids[tmdbId];
    if (normalizedId == null) return null;

    for (final genre in GenreCatalog.all) {
      if (genre.id == normalizedId) return genre;
    }
    return null;
  }
}
