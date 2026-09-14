import 'genre.dart';
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
  });

  final int id;
  final String title;

  /// `null` when TMDB has no poster for this item.
  final String? posterUrl;

  final List<Genre> genres;

  /// `release_date` for a movie, `first_air_date` for a TV show —
  /// normalized under one name. `null` when TMDB doesn't have it yet
  /// (unreleased).
  final DateTime? releaseDate;

  final double voteAverage;

  MediaType get type => switch (this) {
    Movie() => MediaType.movie,
    TvShow() => MediaType.tvShow,
  };

  @override
  bool operator ==(Object other) =>
      other is MediaItem &&
      other.runtimeType == runtimeType &&
      other.id == id;

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
  });
}
