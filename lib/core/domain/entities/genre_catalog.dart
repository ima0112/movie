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
    Genre(id: 'action', name: 'Action'),
    Genre(id: 'adventure', name: 'Adventure'),
    Genre(id: 'animation', name: 'Animation'),
    Genre(id: 'comedy', name: 'Comedy'),
    Genre(id: 'crime', name: 'Crime'),
    Genre(id: 'documentary', name: 'Documentary'),
    Genre(id: 'drama', name: 'Drama'),
    Genre(id: 'family', name: 'Family'),
    Genre(id: 'history', name: 'History'),
    Genre(id: 'horror', name: 'Horror'),
    Genre(id: 'music', name: 'Music'),
    Genre(id: 'mystery', name: 'Mystery'),
    Genre(id: 'romance', name: 'Romance'),
    Genre(id: 'sci-fi', name: 'Science Fiction'),
    Genre(id: 'thriller', name: 'Thriller'),
  ];
}
