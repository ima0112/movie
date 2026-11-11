import 'genre.dart';
import 'media_key.dart';
import 'media_type.dart';

/// A catalog item at list level — carousels, grids, the Discover hero.
/// See `media_detail.dart` (a later step) for the richer entity D1/D2
/// need.
///
/// Source of truth: `docs/STRUCTURE.md`, `core/domain/entities/
/// media_item.dart` — "sealed: Movie | TvShow (list level)".
///
/// Two items are equal when they're the same concrete type with the same
/// [id] — that's catalog identity, not a snapshot comparison (a movie's
/// [voteAverage] can drift between fetches without it becoming "a
/// different movie").
sealed class MediaItem {
  const MediaItem({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.genres,
    required this.releaseDate,
    required this.voteAverage,
    this.backdropUrl,
    this.voteCount,
    this.popularity,
  });

  final int id;
  final String title;

  /// `null` when TMDB has no poster for this item.
  final String? posterUrl;

  /// The 16:9 backdrop's full URL, when TMDB has one — the wide cards of B2's
  /// "Top rated" use it. `null` for sources that don't carry it (the fake,
  /// My List snapshots): callers fall back to the poster.
  final String? backdropUrl;

  final List<Genre> genres;

  /// How many votes [voteAverage] is based on, when the source says
  /// (`vote_count`). `null` for sources that don't carry it (the fake, My List
  /// snapshots). What the "See all" listing's "Most voted" order sorts by.
  final int? voteCount;

  /// TMDB's rolling popularity score, when the source says. `null` like
  /// [voteCount]. What the listing's "Popularity" order sorts by.
  final double? popularity;

  /// `release_date` for a movie, `first_air_date` for a TV show —
  /// normalized under one name. `null` when TMDB doesn't have it yet
  /// (unreleased).
  final DateTime? releaseDate;

  final double voteAverage;

  MediaType get type => switch (this) {
    Movie() => MediaType.movie,
    TvShow() => MediaType.tvShow,
  };

  /// This item's own identity as a [MediaKey] — `MediaKey(type: type,
  /// tmdbId: id)` was already repeated at three call sites
  /// (`match_engine.dart` x2, `surprise_result_content.dart`) before
  /// navigation centralization added several more.
  MediaKey get key => MediaKey(type: type, tmdbId: id);

  @override
  bool operator ==(Object other) =>
      other is MediaItem && other.runtimeType == runtimeType && other.id == id;

  @override
  int get hashCode => Object.hash(runtimeType, id);
}

final class Movie extends MediaItem {
  const Movie({
    required super.id,
    required super.title,
    required super.posterUrl,
    required super.genres,
    required super.releaseDate,
    required super.voteAverage,
    super.backdropUrl,
    super.voteCount,
    super.popularity,
  });
}

final class TvShow extends MediaItem {
  const TvShow({
    required super.id,
    required super.title,
    required super.posterUrl,
    required super.genres,
    required super.releaseDate,
    required super.voteAverage,
    super.backdropUrl,
    super.voteCount,
    super.popularity,
  });
}
