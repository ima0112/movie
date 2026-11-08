import 'package:injectable/injectable.dart';
import 'package:movies/app/environments.dart';

import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/domain/entities/genre.dart';
import '../../../../core/domain/entities/media_detail.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_key.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/domain/entities/person.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/entities/season_summary.dart';
import '../../../../core/domain/entities/video.dart';
import '../../../../core/domain/entities/watch_providers.dart';
import '../../../../core/domain/repositories/media_repository.dart';

/// Hardcoded stand-in for `MediaRepositoryImpl` (TMDB not wired up yet).
///
/// Lets Discover's presentation layer be built and demoed against
/// realistic-looking data. Swap for the real `core/data/repositories/
/// media_repository_impl.dart` once it exists — see `docs/STRUCTURE.md`.
@fake
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

  // Cast/crew/creators shared across the D2 sample details below — ids
  // 2000+ to stay clear of the D1 block above.
  static const _christopherStorer = Person(
    id: 2001,
    name: 'Christopher Storer',
    profilePath: null,
    knownForDepartment: 'Directing',
  );
  static const _jeremyAllenWhite = Person(
    id: 2002,
    name: 'Jeremy Allen White',
    profilePath: null,
    knownForDepartment: 'Acting',
  );
  static const _ayoEdebiri = Person(
    id: 2003,
    name: 'Ayo Edebiri',
    profilePath: null,
    knownForDepartment: 'Acting',
  );
  static const _ebonMossBachrach = Person(
    id: 2004,
    name: 'Ebon Moss-Bachrach',
    profilePath: null,
    knownForDepartment: 'Acting',
  );

  static const _nicPizzolatto = Person(
    id: 2005,
    name: 'Nic Pizzolatto',
    profilePath: null,
    knownForDepartment: 'Writing',
  );
  static const _matthewMcConaughey = Person(
    id: 2006,
    name: 'Matthew McConaughey',
    profilePath: null,
    knownForDepartment: 'Acting',
  );
  static const _woodyHarrelson = Person(
    id: 2007,
    name: 'Woody Harrelson',
    profilePath: null,
    knownForDepartment: 'Acting',
  );
  static const _jodieFoster = Person(
    id: 2008,
    name: 'Jodie Foster',
    profilePath: null,
    knownForDepartment: 'Acting',
  );

  static const _ericKripke = Person(
    id: 2009,
    name: 'Eric Kripke',
    profilePath: null,
    knownForDepartment: 'Writing',
  );
  static const _karlUrban = Person(
    id: 2010,
    name: 'Karl Urban',
    profilePath: null,
    knownForDepartment: 'Acting',
  );
  static const _jackQuaid = Person(
    id: 2011,
    name: 'Jack Quaid',
    profilePath: null,
    knownForDepartment: 'Acting',
  );
  static const _antonyStarr = Person(
    id: 2012,
    name: 'Antony Starr',
    profilePath: null,
    knownForDepartment: 'Acting',
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

  /// D2 sample detail data, covering the three statuses the "Seasons"
  /// section needs to exercise: an airing show with several seasons
  /// (The Boys), an ended one (True Detective), and one whose own
  /// season list includes a special season (The Bear's Season 0).
  /// Keyed by the [TvShow.id]s above; TV shows without an entry here
  /// fall back to [_genericTvDetail].
  static final Map<int, TvShowDetail> _tvShowDetails = {
    101: TvShowDetail(
      item: _tvShows[0], // The Bear
      overview:
          'A young chef from the fine dining world returns to Chicago to '
          'run his family\'s Italian beef sandwich shop after a family '
          'tragedy.',
      cast: const [
        CastMember(
          person: _jeremyAllenWhite,
          character: 'Carmen "Carmy" Berzatto',
          order: 0,
        ),
        CastMember(person: _ayoEdebiri, character: 'Sydney Adamu', order: 1),
        CastMember(
          person: _ebonMossBachrach,
          character: 'Richard "Richie" Jerimovich',
          order: 2,
        ),
      ],
      crew: const [
        CrewMember(
          person: _christopherStorer,
          job: 'Director',
          department: 'Directing',
        ),
      ],
      videos: const [
        Video(
          key: 'yK_sU_qkPlo',
          site: 'YouTube',
          type: 'Trailer',
          name: 'Official Trailer',
        ),
      ],
      similar: [_tvShows[3]], // Hacks
      imdbId: 'tt14452776',
      tagline: null,
      status: 'Returning Series',
      watchProviders: const WatchProviders(
        flatrate: ['Hulu'],
        rent: [],
        buy: [],
        link: 'https://www.themoviedb.org/tv/136315-the-bear/watch',
      ),
      creators: const [_christopherStorer],
      seasons: [
        SeasonSummary(
          seasonNumber: 0,
          name: 'Specials',
          episodeCount: 1,
          posterPath: null,
          airDate: DateTime(2022, 6, 23),
        ),
        SeasonSummary(
          seasonNumber: 1,
          name: 'Season 1',
          episodeCount: 8,
          posterPath: null,
          airDate: DateTime(2022, 6, 23),
        ),
        SeasonSummary(
          seasonNumber: 2,
          name: 'Season 2',
          episodeCount: 10,
          posterPath: null,
          airDate: DateTime(2023, 6, 22),
        ),
        SeasonSummary(
          seasonNumber: 3,
          name: 'Season 3',
          episodeCount: 10,
          posterPath: null,
          airDate: DateTime(2024, 6, 27),
        ),
      ],
      numberOfEpisodes: 29,
      episodeRuntimeMinutes: 30,
      firstAirDate: DateTime(2022, 6, 23),
      lastAirDate: DateTime(2024, 6, 27),
      inProduction: true,
      certification: 'TV-MA',
    ),
    103: TvShowDetail(
      item: _tvShows[2], // True Detective
      overview:
          'Seasonal anthology series in which police investigations unearth '
          'the personal and professional secrets of those involved, both '
          'within and outside the law.',
      cast: const [
        CastMember(
          person: _matthewMcConaughey,
          character: 'Rust Cohle',
          order: 0,
        ),
        CastMember(person: _woodyHarrelson, character: 'Marty Hart', order: 1),
        CastMember(person: _jodieFoster, character: 'Liz Danvers', order: 2),
      ],
      crew: const [
        CrewMember(
          person: _nicPizzolatto,
          job: 'Writer',
          department: 'Writing',
        ),
      ],
      videos: const [
        Video(
          key: 'HTzSfwl8ShU',
          site: 'YouTube',
          type: 'Trailer',
          name: 'Official Trailer',
        ),
      ],
      similar: [_tvShows[4]], // Shōgun
      imdbId: 'tt2356777',
      tagline: null,
      status: 'Ended',
      watchProviders: const WatchProviders(
        flatrate: ['Max'],
        rent: [],
        buy: [],
        link: 'https://www.themoviedb.org/tv/46648-true-detective/watch',
      ),
      creators: const [_nicPizzolatto],
      seasons: [
        SeasonSummary(
          seasonNumber: 1,
          name: 'Season 1',
          episodeCount: 8,
          posterPath: null,
          airDate: DateTime(2014, 1, 12),
        ),
        SeasonSummary(
          seasonNumber: 2,
          name: 'Season 2',
          episodeCount: 8,
          posterPath: null,
          airDate: DateTime(2015, 6, 21),
        ),
        SeasonSummary(
          seasonNumber: 3,
          name: 'Season 3',
          episodeCount: 8,
          posterPath: null,
          airDate: DateTime(2019, 1, 13),
        ),
        SeasonSummary(
          seasonNumber: 4,
          name: 'Night Country',
          episodeCount: 6,
          posterPath: null,
          airDate: DateTime(2024, 1, 14),
        ),
      ],
      numberOfEpisodes: 30,
      episodeRuntimeMinutes: 55,
      firstAirDate: DateTime(2014, 1, 12),
      lastAirDate: DateTime(2024, 2, 18),
      inProduction: false,
      certification: 'TV-MA',
    ),
    106: TvShowDetail(
      item: _tvShows[5], // The Boys
      overview:
          'A group of vigilantes set out to take down corrupt superheroes '
          'who abuse their superpowers.',
      cast: const [
        CastMember(person: _karlUrban, character: 'Billy Butcher', order: 0),
        CastMember(person: _jackQuaid, character: 'Hughie Campbell', order: 1),
        CastMember(person: _antonyStarr, character: 'Homelander', order: 2),
      ],
      crew: const [
        CrewMember(person: _ericKripke, job: 'Writer', department: 'Writing'),
      ],
      videos: const [
        Video(
          key: 'aHjpOzsQ9YI',
          site: 'YouTube',
          type: 'Trailer',
          name: 'Official Trailer',
        ),
      ],
      similar: [_tvShows[1]], // Fallout
      imdbId: 'tt1190634',
      tagline: null,
      status: 'Returning Series',
      watchProviders: const WatchProviders(
        flatrate: ['Amazon Prime Video'],
        rent: [],
        buy: [],
        link: 'https://www.themoviedb.org/tv/76479-the-boys/watch',
      ),
      creators: const [_ericKripke],
      seasons: [
        SeasonSummary(
          seasonNumber: 1,
          name: 'Season 1',
          episodeCount: 8,
          posterPath: null,
          airDate: DateTime(2019, 7, 26),
        ),
        SeasonSummary(
          seasonNumber: 2,
          name: 'Season 2',
          episodeCount: 8,
          posterPath: null,
          airDate: DateTime(2020, 9, 4),
        ),
        SeasonSummary(
          seasonNumber: 3,
          name: 'Season 3',
          episodeCount: 8,
          posterPath: null,
          airDate: DateTime(2022, 6, 3),
        ),
        SeasonSummary(
          seasonNumber: 4,
          name: 'Season 4',
          episodeCount: 8,
          posterPath: null,
          airDate: DateTime(2024, 6, 13),
        ),
      ],
      numberOfEpisodes: 32,
      episodeRuntimeMinutes: 60,
      firstAirDate: DateTime(2019, 7, 26),
      lastAirDate: DateTime(2024, 7, 18),
      inProduction: true,
      certification: 'TV-MA',
    ),
  };

  /// The fallback for a TV show id with no entry in [_tvShowDetails]:
  /// same [TvShow], but no cast/crew/seasons/watch providers data yet —
  /// mirrors [_genericDetail]'s own movie fallback.
  TvShowDetail _genericTvDetail(TvShow show) {
    return TvShowDetail(
      item: show,
      overview: '',
      cast: const [],
      crew: const [],
      videos: const [],
      similar: const [],
      imdbId: null,
      tagline: null,
      status: show.releaseDate == null ? 'In Production' : 'Returning Series',
      watchProviders: WatchProviders.empty,
      creators: const [],
      seasons: const [],
      numberOfEpisodes: 0,
      episodeRuntimeMinutes: null,
      firstAirDate: show.releaseDate,
      lastAirDate: null,
      inProduction: false,
      certification: null,
    );
  }

  /// H4's own on-demand fetch — only a couple of representative
  /// episodes per season, not every one [SeasonSummary.episodeCount]
  /// above claims, the same "enough to exercise the screen, not a full
  /// catalog" spirit as [_movieDetails]. Keyed by tv id, then season
  /// number; a season/show with no entry here is a [Failure] from
  /// [season], same as an unknown movie id from [detail].
  static final Map<int, Map<int, SeasonDetail>> _seasonDetails = {
    101: {
      // The Bear
      0: SeasonDetail(
        seasonNumber: 0,
        name: 'Specials',
        overview: 'Behind-the-scenes looks and bonus footage from the kitchen.',
        episodes: [
          Episode(
            episodeNumber: 1,
            name: 'Behind the Bear',
            overview:
                'A look at how the kitchen crew pulled off the first '
                'season.',
            stillPath: null,
            airDate: DateTime(2022, 6, 23),
            runtimeMinutes: 20,
          ),
        ],
      ),
      1: SeasonDetail(
        seasonNumber: 1,
        name: 'Season 1',
        overview:
            'Carmy returns home to Chicago to run his family\'s Italian '
            'beef sandwich shop after a heartbreaking death in the family.',
        episodes: [
          Episode(
            episodeNumber: 1,
            name: 'System',
            overview: 'Carmy tries to bring order to the kitchen.',
            stillPath: null,
            airDate: DateTime(2022, 6, 23),
            runtimeMinutes: 30,
          ),
          Episode(
            episodeNumber: 2,
            name: 'Hands',
            overview: 'The crew preps for a packed service.',
            stillPath: null,
            airDate: DateTime(2022, 6, 23),
            runtimeMinutes: 27,
          ),
        ],
      ),
    },
    103: {
      // True Detective
      1: SeasonDetail(
        seasonNumber: 1,
        name: 'Season 1',
        overview:
            'Two detectives investigate a ritualistic murder in '
            'Louisiana, with the case unraveling over 17 years.',
        episodes: [
          Episode(
            episodeNumber: 1,
            name: 'The Long Bright Dark',
            overview: 'Detectives Hart and Cohle recall their 1995 case.',
            stillPath: null,
            airDate: DateTime(2014, 1, 12),
            runtimeMinutes: 58,
          ),
          Episode(
            episodeNumber: 2,
            name: 'Seeing Things',
            overview: 'Cohle\'s visions lead to a possible suspect.',
            stillPath: null,
            airDate: DateTime(2014, 1, 19),
            runtimeMinutes: 52,
          ),
        ],
      ),
      4: SeasonDetail(
        seasonNumber: 4,
        name: 'Night Country',
        overview:
            'Police investigate the disappearance of eight men from a '
            'remote Alaskan research station.',
        episodes: [
          Episode(
            episodeNumber: 1,
            name: 'Part 1',
            overview: 'The men of the Tsalal research station vanish.',
            stillPath: null,
            airDate: DateTime(2024, 1, 14),
            runtimeMinutes: 56,
          ),
          Episode(
            episodeNumber: 2,
            name: 'Part 2',
            overview: 'Danvers and Navarro clash over the investigation.',
            stillPath: null,
            airDate: DateTime(2024, 1, 21),
            runtimeMinutes: 51,
          ),
        ],
      ),
    },
    106: {
      // The Boys
      1: SeasonDetail(
        seasonNumber: 1,
        name: 'Season 1',
        overview:
            'Hughie Campbell joins Billy Butcher\'s crusade to expose the '
            'corruption of Vought\'s superheroes.',
        episodes: [
          Episode(
            episodeNumber: 1,
            name: 'The Name of the Game',
            overview: 'Hughie\'s girlfriend is killed by a Supe.',
            stillPath: null,
            airDate: DateTime(2019, 7, 26),
            runtimeMinutes: 61,
          ),
          Episode(
            episodeNumber: 2,
            name: 'Cherry',
            overview: 'Hughie wrestles with what to do next.',
            stillPath: null,
            airDate: DateTime(2019, 7, 26),
            runtimeMinutes: 58,
          ),
        ],
      ),
      4: SeasonDetail(
        seasonNumber: 4,
        name: 'Season 4',
        overview: 'Homelander tightens his grip as the Boys race against time.',
        episodes: [
          Episode(
            episodeNumber: 1,
            name: 'Department of Dirty Tricks',
            overview: 'The team regroups after a devastating loss.',
            stillPath: null,
            airDate: DateTime(2024, 6, 13),
            runtimeMinutes: 64,
          ),
          Episode(
            episodeNumber: 2,
            name: 'Life Among the Septics',
            overview: 'Butcher confronts his own mortality.',
            stillPath: null,
            airDate: DateTime(2024, 6, 13),
            runtimeMinutes: 59,
          ),
        ],
      ),
    },
  };

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

    switch (key.type) {
      case MediaType.movie:
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

      case MediaType.tvShow:
        TvShow? show;
        for (final s in _tvShows) {
          if (s.id == key.tmdbId) {
            show = s;
            break;
          }
        }
        if (show == null) {
          return Failure('No TV show found for id ${key.tmdbId}.');
        }
        return Success(_tvShowDetails[key.tmdbId] ?? _genericTvDetail(show));
    }
  }

  @override
  Future<Result<SeasonDetail>> season(int tvId, int seasonNumber) async {
    await Future.delayed(_delay);

    final season = _seasonDetails[tvId]?[seasonNumber];
    if (season == null) {
      return Failure('No season $seasonNumber found for TV show id $tvId.');
    }
    return Success(season);
  }

  @override
  Future<Result<List<MediaItem>>> searchMulti(String query) async {
    await Future.delayed(_delay);

    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return const Success([]);

    final items = [
      ..._movies,
      ..._tvShows,
    ].where((item) => item.title.toLowerCase().contains(trimmed)).toList();

    return Success(items);
  }

  @override
  Future<Result<List<MediaItem>>> discover(DiscoverFilter filter) async {
    await Future.delayed(_delay);

    // filter.maxRuntimeMinutes / filter.tvStatus are deliberately never
    // read here — see DiscoverFilter's own doc comment on each: MediaItem
    // (what every sample title in this fake actually is) carries neither
    // a runtime nor a status, only MediaDetail does. A real
    // MediaRepositoryImpl doesn't have that gap: both become plain TMDB
    // query parameters (with_runtime.lte, with_status), filtered
    // server-side with no local field needed at all.
    Iterable<MediaItem> items = switch (filter.type) {
      MediaType.movie => _movies,
      MediaType.tvShow => _tvShows,
      null => [..._movies, ..._tvShows],
    };

    if (filter.withGenres.isNotEmpty) {
      items = items.where(
        (item) => item.genres.any(filter.withGenres.contains),
      );
    }
    if (filter.withoutGenres.isNotEmpty) {
      items = items.where(
        (item) => !item.genres.any(filter.withoutGenres.contains),
      );
    }
    if (filter.yearFrom case final from?) {
      items = items.where(
        (item) => item.releaseDate != null && item.releaseDate!.year >= from,
      );
    }
    if (filter.yearTo case final to?) {
      items = items.where(
        (item) => item.releaseDate != null && item.releaseDate!.year <= to,
      );
    }
    if (filter.minVoteAverage case final min?) {
      items = items.where((item) => item.voteAverage >= min);
    }

    final results = items.toList();
    final comparator = _comparatorFor(filter.sortBy);
    // `popularity` has no dedicated comparator: MediaItem carries no
    // separate popularity score (only voteAverage), so re-sorting by it
    // would just be a worse "rating" sort wearing a different name.
    // Keeping the sample lists' own declared order instead — earlier
    // entries are the more "popular" ones by construction — is the
    // closer stand-in until a real popularity field exists.
    if (comparator != null) results.sort(comparator);
    return Success(results);
  }

  @override
  Future<Result<List<MediaItem>>> getPosterWallItems() async {
    await Future.delayed(_delay);
    // The fake's whole sample universe (16 titles) — there's no TMDB
    // trending-week split to combine here, just every title this
    // environment has.
    return Success([..._movies, ..._tvShows]);
  }

  static int Function(MediaItem, MediaItem)? _comparatorFor(
    DiscoverSortBy sortBy,
  ) {
    return switch (sortBy) {
      DiscoverSortBy.popularity => null,
      DiscoverSortBy.rating => (a, b) => b.voteAverage.compareTo(a.voteAverage),
      DiscoverSortBy.releaseDate =>
        (a, b) => (b.releaseDate ?? DateTime(0)).compareTo(
          a.releaseDate ?? DateTime(0),
        ),
      DiscoverSortBy.title => (a, b) => a.title.compareTo(b.title),
    };
  }
}
