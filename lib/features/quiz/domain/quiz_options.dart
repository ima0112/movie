import '../../../core/domain/entities/collection.dart';
import '../../../core/domain/entities/genre.dart';
import '../../../core/domain/entities/genre_catalog.dart';
import '../../../core/domain/entities/media_type.dart';
import '../../match_engine/domain/vibe.dart';

/// Turns a TMDB genre id into the app's [Genre] for a kind of title (`null`
/// when the app has no genre by that id — Kids, Soap, Reality, Talk, News).
/// Injected so this file stays free of the TMDB data layer.
typedef GenreOfTmdbId = Genre? Function(int tmdbId, MediaType type);

/// What each step of the quiz offers, given what the previous steps picked —
/// collections first, then the genres to skip, then the vibes. Pure functions
/// over the catalogs: no state, no network.
///
/// A collection decides what everything comes from, so it takes some choices
/// off the table: a genre it **requires** (Kids: Family or Animation) can't be
/// vetoed, and one it **excludes** (Kids: no Horror) is vetoed already. Those
/// genres are not offered, and a vibe whose genres all fall in what is vetoed
/// or excluded can't produce anything, so it isn't offered either.
abstract final class QuizOptions {
  /// The genres of [type] that [collections] require or exclude.
  static Set<Genre> hiddenGenres(
    Iterable<Collection> collections,
    MediaType type,
    GenreOfTmdbId genreOf,
  ) {
    final hidden = <Genre>{};
    for (final collection in collections) {
      final rule = collection.ruleFor(type);
      if (rule == null) continue;
      for (final query in rule.queries) {
        for (final id in {
          ...query.withTmdbGenreIds,
          ...query.withoutTmdbGenreIds,
        }) {
          final genre = genreOf(id, type);
          if (genre != null) hidden.add(genre);
        }
      }
    }
    return hidden;
  }

  /// Step 2: the genres to choose from for a veto.
  static List<Genre> vetoOptions(
    MediaType type,
    Iterable<Collection> collections,
    GenreOfTmdbId genreOf,
  ) {
    final hidden = hiddenGenres(collections, type, genreOf);
    return [
      for (final genre in GenreCatalog.availableFor(type))
        if (!_inHidden(hidden, genre, type)) genre,
    ];
  }

  /// Step 3: the vibes of [type] that can still produce something. A vibe
  /// defined by genres (the ambientes, and Monster and Gritty, which pair
  /// them with keywords) needs one of them to be neither vetoed nor excluded
  /// by a collection; a keyword theme is always possible.
  static List<Vibe> vibeOptions(
    Iterable<Vibe> vibes,
    MediaType type,
    Iterable<Collection> collections,
    Set<Genre> vetoed,
    GenreOfTmdbId genreOf,
  ) {
    final excluded = <Genre>{};
    for (final collection in collections) {
      final rule = collection.ruleFor(type);
      if (rule == null) continue;
      for (final query in rule.queries) {
        for (final id in query.withoutTmdbGenreIds) {
          final genre = genreOf(id, type);
          if (genre != null) excluded.add(genre);
        }
      }
    }
    return [
      for (final vibe in vibes)
        if (vibe.isMeaningfulFor(type) &&
            _hasUsableGenre(vibe.genresFor(type), {
              ...vetoed,
              ...excluded,
            }, type))
          vibe,
    ];
  }

  /// [vetoed] without what a change of collection made unavailable.
  static Set<Genre> prunedVetoes(
    Set<Genre> vetoed,
    MediaType type,
    Iterable<Collection> collections,
    GenreOfTmdbId genreOf,
  ) {
    final hidden = hiddenGenres(collections, type, genreOf);
    return {
      for (final genre in vetoed)
        if (!_inHidden(hidden, genre, type)) genre,
    };
  }

  /// [vibeIds] without the vibes that can no longer produce anything.
  static Set<String> prunedVibes(
    Set<String> vibeIds,
    Iterable<Vibe> vibes,
    MediaType type,
    Iterable<Collection> collections,
    Set<Genre> vetoed,
    GenreOfTmdbId genreOf,
  ) {
    final offered = {
      for (final v in vibeOptions(vibes, type, collections, vetoed, genreOf))
        v.id,
    };
    return vibeIds.where(offered.contains).toSet();
  }

  /// A vibe with no genres is never blocked; one with genres needs a free one.
  static bool _hasUsableGenre(
    Set<Genre> genres,
    Set<Genre> blocked,
    MediaType type,
  ) => genres.isEmpty || genres.any((g) => !_inHidden(blocked, g, type));

  /// Whether [genre] is among [genres], counting TV's combined chips as one:
  /// Adventure is hidden where Action is (they are one genre on TV).
  static bool _inHidden(Set<Genre> genres, Genre genre, MediaType type) {
    if (genres.contains(genre)) return true;
    if (type != MediaType.tvShow) return false;
    return GenreCatalog.tvMembers(genre).any(genres.contains);
  }
}
