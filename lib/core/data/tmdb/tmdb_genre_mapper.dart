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
/// merges fold into our smaller, 16-genre catalog:
/// - TV's "Action & Adventure" (10759) → [GenreCatalog.all]'s `action`.
/// - TV's "Sci-Fi & Fantasy" (10765) → `sci-fi`, for [fromTmdbId] — see
///   [_tvToTmdbIdOnly]'s own doc comment for the `fantasy` half of this.
///
/// Several TMDB genres have **no equivalent at all** in
/// [GenreCatalog.all] (War, Western, TV Movie, Kids, News, Reality,
/// Soap, Talk, War & Politics) — [fromTmdbId] returns `null` for those,
/// and callers (`tmdb_mappers.dart`) simply drop them from a title's
/// genre list rather than inventing a catch-all bucket.
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
    14: 'fantasy',
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

  /// TV-only, [toTmdbId]-only entries for a normalized genre that
  /// shares its TMDB id with another one already in [_tvIds] —
  /// [fromTmdbId] can only ever resolve one TMDB id to a single
  /// normalized genre (it's a plain `Map<int, String>`), so `10765`
  /// stays `sci-fi` there, unchanged. `fantasy` still needs to build
  /// `with_genres`/`without_genres` on the TV side (e.g. vetoing it
  /// from C5), hence this separate, `String`-keyed map, where two
  /// different keys mapping to the same TMDB id is no conflict at all.
  ///
  /// **Consequence, worth knowing**: on TV, `fantasy` and `sci-fi` are
  /// the *same* TMDB category (10765) — TMDB itself can't tell them
  /// apart for a TV show. Vetoing one in [toTmdbId]'s `without_genres`
  /// use vetoes the other too. Movies don't have this problem: Fantasy
  /// (14) is its own distinct id in [_movieIds].
  static const Map<String, int> _tvToTmdbIdOnly = {'fantasy': 10765};

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

  /// The reverse of [fromTmdbId] — `tmdb_discover_params.dart`'s own
  /// `with_genres`/`without_genres` translation. `null` when [genre] has
  /// no TMDB id for this [type].
  static int? toTmdbId(Genre genre, MediaType type) {
    final ids = switch (type) {
      MediaType.movie => _movieIds,
      MediaType.tvShow => _tvIds,
    };
    for (final entry in ids.entries) {
      if (entry.value == genre.id) return entry.key;
    }
    if (type == MediaType.tvShow) return _tvToTmdbIdOnly[genre.id];
    return null;
  }
}
