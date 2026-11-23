import 'collection.dart';
import 'genre.dart';
import 'media_type.dart';

/// Turns a TMDB genre id into the app's [Genre] for a kind of title (`null`
/// when the app has no genre by that id — Kids, Soap, Reality, Talk, News).
/// Injected so the domain stays free of the TMDB data layer.
typedef GenreOfTmdbId = Genre? Function(int tmdbId, MediaType type);

/// Which of the app's genres a [Collection] **requires** (a title must have
/// one of them: Anime needs Animation, For kids needs Family) and which it
/// **excludes** (For kids: no Horror). Pure functions over the catalog.
abstract final class CollectionGenres {
  /// The genres [collection] requires for [type].
  static Set<Genre> required(
    Collection collection,
    MediaType type,
    GenreOfTmdbId genreOf,
  ) => _resolve(collection, type, genreOf, (q) => q.withTmdbGenreIds);

  /// The genres [collection] excludes for [type].
  static Set<Genre> excluded(
    Collection collection,
    MediaType type,
    GenreOfTmdbId genreOf,
  ) => _resolve(collection, type, genreOf, (q) => q.withoutTmdbGenreIds);

  /// The genres [collection] excludes for [type]; with no [type] (All), only
  /// those it excludes on **every** kind of title it exists for — the ones
  /// that give nothing whichever kind is searched.
  static Set<Genre> excludedFor(
    Collection collection,
    MediaType? type,
    GenreOfTmdbId genreOf,
  ) {
    if (type != null) return excluded(collection, type, genreOf);
    Set<Genre>? common;
    for (final t in MediaType.values) {
      if (!collection.isAvailableFor(t)) continue;
      final here = excluded(collection, t, genreOf);
      common = common == null ? here : common.intersection(here);
    }
    return common ?? const {};
  }

  /// The genres [collection] requires on **any** kind of title it exists for —
  /// what a taste profile (which isn't of one kind) must not veto if the
  /// collection is to give anything.
  static Set<Genre> requiredAnywhere(
    Collection collection,
    GenreOfTmdbId genreOf,
  ) => {
    for (final type in MediaType.values) ...required(collection, type, genreOf),
  };

  static Set<Genre> _resolve(
    Collection collection,
    MediaType type,
    GenreOfTmdbId genreOf,
    Set<int> Function(dynamic query) ids,
  ) {
    final rule = collection.ruleFor(type);
    if (rule == null) return const {};
    return {
      for (final query in rule.queries)
        for (final id in ids(query))
          if (genreOf(id, type) case final Genre genre) genre,
    };
  }
}
