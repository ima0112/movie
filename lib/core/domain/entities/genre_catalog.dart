import 'genre.dart';
import 'media_type.dart';

/// The full set of normalized genres PakoTV works with — a fixed,
/// hand-maintained list, not fetched from TMDB at runtime (the raw
/// TMDB-id mapping still lives in `data/tmdb/`, per `genre.dart`'s own
/// doc comment; this is the normalized side of that mapping).
///
/// Built to close a real gap: C5 ("My Tastes")'s "Genres you like"/
/// "Genres you never want" grids need a fixed list of every selectable
/// genre, and nothing enumerated one anywhere in `core/domain` before
/// this (only ad hoc constants scattered in `FakeMediaRepository`, and
/// `UserMediaEntry.genres`, which only ever holds whatever a *specific*
/// title's genres are, never the full catalog).
///
/// Pure domain — no Flutter: each genre's icon (`AppIcons.genreXxx`) is
/// a presentation-layer concern resolved by whoever renders these (see
/// `my_tastes_screen.dart`), the same split `Vibe.icon` already uses.
class GenreCatalog {
  const GenreCatalog._();

  static const List<Genre> all = [
    Genre(id: 'action'),
    Genre(id: 'adventure'),
    Genre(id: 'animation'),
    Genre(id: 'comedy'),
    Genre(id: 'crime'),
    Genre(id: 'documentary'),
    Genre(id: 'drama'),
    Genre(id: 'family'),
    Genre(id: 'fantasy'),
    Genre(id: 'history'),
    Genre(id: 'horror'),
    Genre(id: 'music'),
    Genre(id: 'mystery'),
    Genre(id: 'romance'),
    Genre(id: 'sci-fi'),
    Genre(id: 'thriller'),
    Genre(id: 'war'),
    Genre(id: 'western'),
  ];

  /// The genres a kind of title can be liked, vetoed or browsed by — what a
  /// screen should list. **Movies: every genre.** **TV shows: all but
  /// `adventure` and `fantasy`**: TMDB's TV list has one "Action & Adventure"
  /// and one "Sci-Fi & Fantasy", so on TV `action` and `sci-fi` are those
  /// combined chips (see [tvMembers]) and the other two have no chip of their
  /// own. (A TV genre TMDB lacks — horror, romance, thriller, history, music —
  /// stays: the data layer stands in for it with keywords.)
  static List<Genre> availableFor(MediaType type) => switch (type) {
    MediaType.movie => all,
    MediaType.tvShow => [
      for (final genre in all)
        if (!_tvFoldedInto.containsKey(genre.id)) genre,
    ],
  };

  /// The genres that are **one genre on TV**: `action`+`adventure` (TMDB's
  /// "Action & Adventure") and `sci-fi`+`fantasy` ("Sci-Fi & Fantasy"). For any
  /// other genre, just itself. A TV chip for [genre] stands for all of these, so
  /// picking it to veto vetoes every member, and vetoing only one member
  /// (Fantasy alone, say) leaves the combined TV genre alone.
  static Set<Genre> tvMembers(Genre genre) {
    final primary = _tvFoldedInto[genre.id] ?? genre.id;
    return {
      for (final g in all)
        if (g.id == primary || _tvFoldedInto[g.id] == primary) g,
    };
  }

  /// Whether [genre] is shown on TV under another genre's chip (`adventure`
  /// under `action`, `fantasy` under `sci-fi`).
  static bool isFoldedOnTv(Genre genre) => _tvFoldedInto.containsKey(genre.id);

  static const Map<String, String> _tvFoldedInto = {
    'adventure': 'action',
    'fantasy': 'sci-fi',
  };

  /// Reconstructs a [Genre] from a persisted [id] — local storage only
  /// ever keeps the id (CLAUDE.md rule 15), never a display name, so
  /// loading a saved [Genre] means looking it back up here rather than
  /// rebuilding it from stored text.
  ///
  /// `null` when [id] isn't one of [all]'s own ids — e.g. a row saved
  /// by an older build whose catalog has since dropped that genre.
  /// Callers drop it rather than invent a catch-all bucket, the same
  /// rule `TmdbGenreMapper.fromTmdbId`'s own doc comment already
  /// follows for a TMDB id with no equivalent here. Returning a
  /// `Genre(id: id)` for an unknown id instead (an earlier version of
  /// this method did) silently manufactures a `Genre` that
  /// `GenreLocalization.localizedName`'s exhaustive switch has no
  /// branch for — it round-trips through storage fine and only throws
  /// later, deep in the UI.
  static Genre? byId(String id) {
    for (final genre in all) {
      if (genre.id == id) return genre;
    }
    return null;
  }
}
