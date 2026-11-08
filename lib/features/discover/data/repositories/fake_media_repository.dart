import 'package:injectable/injectable.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/domain/entities/media_detail.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_key.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/domain/entities/person.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/entities/video.dart';
import '../../../../core/domain/entities/watch_providers.dart';
import '../../../../core/domain/repositories/media_repository.dart';

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

  // Cast/crew shared across the D1 sample details below.
  static const _timotheeChalamet = Person(
    id: 1001,
    name: 'Timothée Chalamet',
    profilePath: null,
    knownForDepartment: 'Acting',
  );
  static const _zendaya = Person(
    id: 1002,
    name: 'Zendaya',
    profilePath: null,
    knownForDepartment: 'Acting',
  );
  static const _rebeccaFerguson = Person(
    id: 1003,
    name: 'Rebecca Ferguson',
    profilePath: null,
    knownForDepartment: 'Acting',
  );
  static const _denisVilleneuve = Person(
    id: 1004,
    name: 'Denis Villeneuve',
    profilePath: null,
    knownForDepartment: 'Directing',
  );
  static const _jonSpaihts = Person(
    id: 1005,
    name: 'Jon Spaihts',
    profilePath: null,
    knownForDepartment: 'Writing',
  );

  static const _cillianMurphy = Person(
    id: 1006,
    name: 'Cillian Murphy',
    profilePath: null,
    knownForDepartment: 'Acting',
  );
  static const _emilyBlunt = Person(
    id: 1007,
    name: 'Emily Blunt',
    profilePath: null,
    knownForDepartment: 'Acting',
  );
  static const _robertDowneyJr = Person(
    id: 1008,
    name: 'Robert Downey Jr.',
    profilePath: null,
    knownForDepartment: 'Acting',
  );
  static const _christopherNolan = Person(
    id: 1009,
    name: 'Christopher Nolan',
    profilePath: null,
    knownForDepartment: 'Directing',
  );

  static const _emmaStone = Person(
    id: 1010,
    name: 'Emma Stone',
    profilePath: null,
    knownForDepartment: 'Acting',
  );
  static const _markRuffalo = Person(
    id: 1011,
    name: 'Mark Ruffalo',
    profilePath: null,
    knownForDepartment: 'Acting',
  );
  static const _willemDafoe = Person(
    id: 1012,
    name: 'Willem Dafoe',
    profilePath: null,
    knownForDepartment: 'Acting',
  );
  static const _yorgosLanthimos = Person(
    id: 1013,
    name: 'Yorgos Lanthimos',
    profilePath: null,
    knownForDepartment: 'Directing',
  );
  static const _tonyMcNamara = Person(
    id: 1014,
    name: 'Tony McNamara',
    profilePath: null,
    knownForDepartment: 'Writing',
  );

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

  /// D1 sample detail data — coherent enough to exercise every section of
  /// SCREENS.md D1 (trailer, cast, crew, similar, where to watch). Keyed by
  /// the [Movie.id]s above; movies without an entry here fall back to
  /// [_genericDetail].
  static final Map<int, MovieDetail> _movieDetails = {
    1: MovieDetail(
      item: _movies[0], // Dune: Part Two
      overview:
          'Paul Atreides unites with Chani and the Fremen while seeking '
          'revenge against the conspirators who destroyed his family. Facing '
          'a choice between the love of his life and the fate of the known '
          'universe, he endeavors to prevent a terrible future only he can '
          'foresee.',
      cast: const [
        CastMember(
          person: _timotheeChalamet,
          character: 'Paul Atreides',
          order: 0,
        ),
        CastMember(person: _zendaya, character: 'Chani', order: 1),
        CastMember(
          person: _rebeccaFerguson,
          character: 'Lady Jessica',
          order: 2,
        ),
      ],
      crew: const [
        CrewMember(
          person: _denisVilleneuve,
          job: 'Director',
          department: 'Directing',
        ),
        CrewMember(person: _jonSpaihts, job: 'Writer', department: 'Writing'),
      ],
      videos: const [
        Video(
          key: 'Way9Dexny3w',
          site: 'YouTube',
          type: 'Trailer',
          name: 'Official Trailer',
        ),
      ],
      similar: [_movies[6], _movies[8]], // Furiosa, Untitled Sci-Fi Project
      imdbId: 'tt15239678',
      tagline: 'Long live the fighters.',
      status: 'Released',
      watchProviders: const WatchProviders(
        flatrate: ['Max'],
        rent: ['Apple TV', 'Amazon Video'],
        buy: ['Apple TV', 'Amazon Video'],
        link: 'https://www.themoviedb.org/movie/693134-dune-part-two/watch',
      ),
      runtimeMinutes: 166,
      releaseDate: DateTime(2024, 3, 1),
      certification: 'PG-13',
    ),
    2: MovieDetail(
      item: _movies[1], // Oppenheimer
      overview:
          'The story of American scientist J. Robert Oppenheimer and his '
          'role in the development of the atomic bomb.',
      cast: const [
        CastMember(
          person: _cillianMurphy,
          character: 'J. Robert Oppenheimer',
          order: 0,
        ),
        CastMember(
          person: _emilyBlunt,
          character: 'Kitty Oppenheimer',
          order: 1,
        ),
        CastMember(
          person: _robertDowneyJr,
          character: 'Lewis Strauss',
          order: 2,
        ),
      ],
      crew: const [
        CrewMember(
          person: _christopherNolan,
          job: 'Director',
          department: 'Directing',
        ),
        CrewMember(
          person: _christopherNolan,
          job: 'Writer',
          department: 'Writing',
        ),
      ],
      videos: const [
        Video(
          key: 'uYPbbksJxIg',
          site: 'YouTube',
          type: 'Trailer',
          name: 'Official Trailer',
        ),
      ],
      similar: [_movies[2]], // Poor Things
      imdbId: 'tt15398776',
      tagline: 'The world forever changes.',
      status: 'Released',
      watchProviders: const WatchProviders(
        flatrate: ['Peacock'],
        rent: ['Apple TV', 'Amazon Video'],
        buy: ['Apple TV', 'Amazon Video'],
        link: 'https://www.themoviedb.org/movie/872585-oppenheimer/watch',
      ),
      runtimeMinutes: 180,
      releaseDate: DateTime(2023, 7, 21),
      certification: 'R',
    ),
    3: MovieDetail(
      item: _movies[2], // Poor Things
      overview:
          'Brought back to life by an unorthodox scientist, a young woman '
          'runs off with a debauched lawyer on a whirlwind adventure across '
          'the continents. Free from the prejudices of her times, she '
          'grows steadfast in her purpose to stand for the rights of women '
          'and the freedom of humankind.',
      cast: const [
        CastMember(person: _emmaStone, character: 'Bella Baxter', order: 0),
        CastMember(
          person: _markRuffalo,
          character: 'Duncan Wedderburn',
          order: 1,
        ),
        CastMember(
          person: _willemDafoe,
          character: 'Dr. Godwin Baxter',
          order: 2,
        ),
      ],
      crew: const [
        CrewMember(
          person: _yorgosLanthimos,
          job: 'Director',
          department: 'Directing',
        ),
        CrewMember(person: _tonyMcNamara, job: 'Writer', department: 'Writing'),
      ],
      videos: const [
        Video(
          key: 'RlbR5N6veqw',
          site: 'YouTube',
          type: 'Trailer',
          name: 'Official Trailer',
        ),
      ],
      similar: [_movies[3], _movies[1]], // Knives Out, Oppenheimer
      imdbId: 'tt14230458',
      tagline: 'Just imagine how much happier you would be if you were free.',
      status: 'Released',
      watchProviders: const WatchProviders(
        flatrate: ['Hulu'],
        rent: ['Apple TV', 'Amazon Video'],
        buy: ['Apple TV', 'Amazon Video'],
        link: 'https://www.themoviedb.org/movie/792307-poor-things/watch',
      ),
      runtimeMinutes: 141,
      releaseDate: DateTime(2023, 12, 8),
      certification: 'R',
    ),
  };

  /// The fallback for a movie id with no entry in [_movieDetails]: same
  /// [Movie], but no cast/crew/videos/watch providers data yet.
  MovieDetail _genericDetail(Movie movie) {
    return MovieDetail(
      item: movie,
      overview: '',
      cast: const [],
      crew: const [],
      videos: const [],
      similar: const [],
      imdbId: null,
      tagline: null,
      status: movie.releaseDate == null ? 'In Production' : 'Released',
      watchProviders: WatchProviders.empty,
      runtimeMinutes: null,
      releaseDate: movie.releaseDate,
      certification: null,
    );
  }

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

  @override
  Future<Result<MediaDetail>> detail(MediaKey key) async {
    await Future.delayed(_delay);

    if (key.type != MediaType.movie) {
      return const Failure('TV show detail is not implemented yet.');
    }

    Movie? movie;
    for (final m in _movies) {
      if (m.id == key.tmdbId) {
        movie = m;
        break;
      }
    }
    if (movie == null) {
      return Failure('No movie found for id ${key.tmdbId}.');
    }

    return Success(_movieDetails[key.tmdbId] ?? _genericDetail(movie));
  }
}
