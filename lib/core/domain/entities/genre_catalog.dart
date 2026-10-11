import 'genre.dart';

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
  ];

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
