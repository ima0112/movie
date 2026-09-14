import 'package:injectable/injectable.dart';

import '../../../core/domain/entities/genre.dart';
import '../../../core/domain/entities/media_item.dart';
import '../../../core/domain/entities/media_type.dart';
import '../../../core/domain/entities/result.dart';
import '../../../core/domain/repositories/media_repository.dart';

/// Hardcoded stand-in for `MediaRepositoryImpl` (TMDB not wired up yet).
///
/// Lets Discover's presentation layer be built and demoed against
/// realistic-looking data. Swap for the real `core/data/repositories/
/// media_repository_impl.dart` once it exists — see `docs/STRUCTURE.md`.
@LazySingleton(as: MediaRepository)
class FakeMediaRepository implements MediaRepository {
  static const _delay = Duration(milliseconds: 400);

  static const _action = Genre(id: 'action', name: 'Action');
  static const _animation = Genre(id: 'animation', name: 'Animation');
  static const _comedy = Genre(id: 'comedy', name: 'Comedy');
  static const _documentary = Genre(id: 'documentary', name: 'Documentary');
  static const _drama = Genre(id: 'drama', name: 'Drama');
  static const _horror = Genre(id: 'horror', name: 'Horror');
  static const _mystery = Genre(id: 'mystery', name: 'Mystery');
  static const _sciFi = Genre(id: 'sci-fi', name: 'Science Fiction');

  static final List<Movie> _movies = [
    Movie(
      id: 1,
      title: 'Dune: Part Two',
      posterUrl: null,
      genres: const [_sciFi, _drama],
      releaseDate: DateTime(2024, 3, 1),
      voteAverage: 8.4,
    ),
    Movie(
      id: 2,
      title: 'Oppenheimer',
      posterUrl: null,
      genres: const [_drama],
      releaseDate: DateTime(2023, 7, 21),
      voteAverage: 8.2,
    ),
    Movie(
      id: 3,
      title: 'Poor Things',
      posterUrl: null,
      genres: const [_comedy, _drama],
      releaseDate: DateTime(2023, 12, 8),
      voteAverage: 8.0,
    ),
    Movie(
      id: 4,
      title: 'Knives Out',
      posterUrl: null,
      genres: const [_mystery, _comedy],
      releaseDate: DateTime(2019, 11, 27),
      voteAverage: 7.9,
    ),
    Movie(
      id: 5,
      title: 'The Substance',
      posterUrl: null,
      genres: const [_horror],
      releaseDate: DateTime(2024, 9, 7),
      voteAverage: 7.3,
    ),
    Movie(
      id: 6,
      title: 'Inside Out 2',
      posterUrl: null,
      genres: const [_animation, _comedy],
      releaseDate: DateTime(2024, 6, 14),
      voteAverage: 7.7,
    ),
    Movie(
      id: 7,
      title: 'Furiosa',
      posterUrl: null,
      genres: const [_action, _sciFi],
      releaseDate: DateTime(2024, 5, 24),
      voteAverage: 7.6,
    ),
    Movie(
      id: 8,
      title: 'My Octopus Teacher',
      posterUrl: null,
      genres: const [_documentary],
      releaseDate: DateTime(2020, 9, 7),
      voteAverage: 8.1,
    ),
    // Not yet released — exercises the nullable release date.
    Movie(
      id: 9,
      title: 'Untitled Sci-Fi Project',
      posterUrl: null,
      genres: const [_sciFi],
      releaseDate: null,
      voteAverage: 0,
    ),
  ];

  static final List<TvShow> _tvShows = [
    TvShow(
      id: 101,
      title: 'The Bear',
      posterUrl: null,
      genres: const [_comedy, _drama],
      releaseDate: DateTime(2022, 6, 23),
      voteAverage: 8.5,
    ),
    TvShow(
      id: 102,
      title: 'Fallout',
      posterUrl: null,
      genres: const [_sciFi, _action],
      releaseDate: DateTime(2024, 4, 10),
      voteAverage: 8.3,
    ),
    TvShow(
      id: 103,
      title: 'True Detective',
      posterUrl: null,
      genres: const [_mystery, _drama],
      releaseDate: DateTime(2014, 1, 12),
      voteAverage: 8.2,
    ),
    TvShow(
      id: 104,
      title: 'Hacks',
      posterUrl: null,
      genres: const [_comedy],
      releaseDate: DateTime(2021, 5, 13),
      voteAverage: 8.0,
    ),
    TvShow(
      id: 105,
      title: 'Shōgun',
      posterUrl: null,
      genres: const [_drama, _action],
      releaseDate: DateTime(2024, 2, 27),
      voteAverage: 8.7,
    ),
    TvShow(
      id: 106,
      title: 'The Boys',
      posterUrl: null,
      genres: const [_action, _sciFi],
      releaseDate: DateTime(2019, 7, 26),
      voteAverage: 8.4,
    ),
    TvShow(
      id: 107,
      title: 'Planet Earth III',
      posterUrl: null,
      genres: const [_documentary],
      releaseDate: DateTime(2023, 10, 18),
      voteAverage: 9.0,
    ),
  ];

  @override
  Future<Result<List<MediaItem>>> getHeroItems({MediaType? type}) async {
    await Future.delayed(_delay);

    final items = switch (type) {
      MediaType.movie => _movies,
      MediaType.tvShow => _tvShows,
      null => [..._movies.take(4), ..._tvShows.take(4)],
    };

    return Success(items.take(8).toList());
  }

  @override
  Future<Result<List<MediaItem>>> getCarouselSection(
    CarouselSection section, {
    MediaType? type,
    Genre? genre,
  }) async {
    await Future.delayed(_delay);

    final List<MediaItem> pool = switch (type) {
      MediaType.movie => _movies,
      MediaType.tvShow => _tvShows,
      null => [..._movies, ..._tvShows],
    };

    final items = section == CarouselSection.becauseYouLike && genre != null
        ? pool.where((item) => item.genres.contains(genre)).toList()
        : pool;

    return Success(items.take(10).toList());
  }
}
