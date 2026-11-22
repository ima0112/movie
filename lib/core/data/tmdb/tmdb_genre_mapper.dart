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
/// [GenreCatalog.all] (TV Movie, Kids, News, Reality, Soap, Talk) —
/// [fromTmdbId] returns `null` for those,
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
    10752: 'war',
    37: 'western',
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
    10768: 'war', // "War & Politics"
    37: 'western',
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
  /// Catalog genres TMDB's TV list has no genre for at all (it has no Horror,
  /// Romance, Thriller, History or Music; id 37 is *Western*, which the
  /// catalog doesn't have — an earlier version mapped Thriller there, so
  /// vetoing Thriller on TV excluded Westerns) → a TMDB *keyword* that
  /// approximates each, used with `without_keywords` so a veto still does
  /// something on TV. Coverage is partial by nature: of ~3300 series with
  /// 150+ votes, horror tags 120, romance 338, thriller 105, history 10 and
  /// music 14 — History and Music are nearly no-ops, kept so the map is
  /// complete. Ids resolved with `/search/keyword`.
  /// The five genres TMDB's TV list **lacks** and the keywords that stand in
  /// for each, both to like them and to veto them. TMDB tags TV by keyword
  /// only, so these are approximations; measured on 100+ votes they hold
  /// 141 (horror), 464 (romance), 141 (thriller), 156 (history: period drama,
  /// historical, history) and 64 (music) shows. Music also leaves out Talk
  /// (10767), which collects talk shows with a music keyword.
  static const Map<String, TvKeywordStandIn> _tvStandIns = {
    'horror': TvKeywordStandIn({315058}),
    'romance': TvKeywordStandIn({9840}),
    'thriller': TvKeywordStandIn({316362}),
    'history': TvKeywordStandIn({15060, 15126, 282633}),
    'music': TvKeywordStandIn(
      {283297, 4344, 10229, 186120, 4048, 311916, 236650, 6029},
      withoutTmdbGenreIds: {10767},
    ),
  };

  static const Map<String, int> _tvToTmdbIdOnly = {
    'adventure': 10759,
    'fantasy': 10765,
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

  /// The `without_keywords` ids that stand in, on TV, for the vetoed [genres]
  /// that have no genre of their own there (see [_tvVetoKeywords]).
  /// Whether TMDB's TV list has no genre for [genre], so a keyword stands in.
  static bool isStandInOnTv(Genre genre) => _tvStandIns.containsKey(genre.id);

  /// The TMDB ids that **liking** the TV genres [genres] asks for: each genre's
  /// own id, and the combined ones too for `adventure` (10759) and `fantasy`
  /// (10765) — liking them on TV means liking the combined genre.
  static Set<int> tvLikeGenreIds(Iterable<Genre> genres) => {
    for (final genre in genres) ?toTmdbId(genre, MediaType.tvShow),
  };

  /// The TMDB ids that **vetoing** [genres] excludes on TV. A TV genre TMDB
  /// folds several of ours into ("Action & Adventure", "Sci-Fi & Fantasy") is
  /// excluded only when **every** member is vetoed: vetoing Fantasy alone
  /// leaves Sci-Fi shows in, and vetoing Adventure alone leaves Action in.
  static Set<int> tvVetoGenreIds(Iterable<Genre> genres) {
    final vetoed = genres.toSet();
    return {
      for (final genre in vetoed)
        if (_tvIdOf(genre) case final id?
            when GenreCatalog.tvMembers(genre).every(vetoed.contains))
          id,
    };
  }

  /// The stand-in genres a TV show has, from its [keywordIds] — TMDB's TV list
  /// gives it no Horror, Romance, Thriller, History or Music of its own, so the
  /// same keywords that stand in for them in a search say which it is. Music
  /// is left out for a talk show (its [tmdbGenreIds] hold Talk, 10767).
  static Set<Genre> tvStandInGenres(
    Iterable<int> keywordIds, {
    Iterable<int> tmdbGenreIds = const [],
  }) {
    final keywords = keywordIds.toSet();
    final genreIds = tmdbGenreIds.toSet();
    return {
      for (final entry in _tvStandIns.entries)
        if (entry.value.keywordIds.any(keywords.contains) &&
            !entry.value.withoutTmdbGenreIds.any(genreIds.contains))
          ?GenreCatalog.byId(entry.key),
    };
  }

  /// The keywords that exclude the stand-in genres among [genres] on TV.
  static Set<int> tvVetoKeywordIds(Iterable<Genre> genres) => {
    for (final genre in genres) ...?_tvStandIns[genre.id]?.keywordIds,
  };

  /// What liking the stand-in genres among [genres] asks of a TV search, in the
  /// fewest groups: one for all of them but Music, and one for Music (it
  /// carries its own exclusion). Each group is a "any of these keywords" query.
  static List<TvKeywordStandIn> tvStandInGroups(Iterable<Genre> genres) {
    final keywords = <int>{};
    TvKeywordStandIn? music;
    for (final genre in genres) {
      final standIn = _tvStandIns[genre.id];
      if (standIn == null) continue;
      if (standIn.withoutTmdbGenreIds.isEmpty) {
        keywords.addAll(standIn.keywordIds);
      } else {
        music = standIn;
      }
    }
    return [if (keywords.isNotEmpty) TvKeywordStandIn(keywords), ?music];
  }

  /// [genre]'s own TV id, when it has one *as the genre* (not a folded-in
  /// member): `action` → 10759, `sci-fi` → 10765, `war` → 10768…
  static int? _tvIdOf(Genre genre) {
    for (final entry in _tvIds.entries) {
      if (entry.value == genre.id) return entry.key;
    }
    return null;
  }

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

/// A keyword set that stands in for a genre TMDB's TV list lacks: a search
/// matches a show with any of [keywordIds], minus any with a genre in
/// [withoutTmdbGenreIds].
class TvKeywordStandIn {
  const TvKeywordStandIn(
    this.keywordIds, {
    this.withoutTmdbGenreIds = const {},
  });

  final Set<int> keywordIds;
  final Set<int> withoutTmdbGenreIds;
}
