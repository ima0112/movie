import 'package:injectable/injectable.dart';
import 'package:movies/app/environments.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/person.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/repositories/person_repository.dart';

const _drama = Genre(id: 'drama');
const _sciFi = Genre(id: 'sci-fi');
const _comedy = Genre(id: 'comedy');
const _horror = Genre(id: 'horror');
const _action = Genre(id: 'action');

/// Hardcoded stand-in for [PersonRepository] — same role as
/// `FakeMediaRepository` (`docs/STRUCTURE.md`), feature-local rather
/// than `core/` since nothing outside D3's own tests constructs it
/// directly.
///
/// Six sample people, chosen to exercise every branch D3 needs:
/// - 1001 Timothée Chalamet: cast-only, one credit with no release
///   date yet ("Coming soon").
/// - 1004 Denis Villeneuve: crew-only (no "As director" tab — that
///   needs *both* cast and crew), and his own biography is the
///   English-fallback case.
/// - 1006 Cillian Murphy: cast-only, across both a movie and a TV show.
/// - 1050 Jordan Peele: both cast and crew credits — the one case that
///   gets the extra "As director" filmography tab.
/// - 1060 Walter Voss (fictional, not a real person — deceased sample
///   data stays invented rather than attaching a death date to someone
///   real): has both a birthday and a deathday, for the "years lived"
///   age calculation.
/// - 2010 Karl Urban: the one id this file shares with
///   `FakeMediaRepository`'s own cast data (he's "The Boys"' Billy
///   Butcher there) — tapping his D2 cast circle and then a filmography
///   credit of his own (Oppenheimer) needs his id to resolve to *some*
///   `PersonDetail` here, not just the five above, which were all
///   originally only cross-referenced with D1's own movie cast.
@fake
@LazySingleton(as: PersonRepository)
class FakePersonRepository implements PersonRepository {
  static const _delay = Duration(milliseconds: 400);

  static final _duneTwo = Movie(
    id: 9001,
    title: 'Dune: Part Two',
    posterUrl: null,
    genres: [_sciFi, _drama],
    releaseDate: DateTime(2024, 3, 1),
    voteAverage: 8.4,
  );
  static final _dune = Movie(
    id: 9000,
    title: 'Dune',
    posterUrl: null,
    genres: [_sciFi, _drama],
    releaseDate: DateTime(2021, 10, 22),
    voteAverage: 8.0,
  );
  static final _wonka = Movie(
    id: 9002,
    title: 'Wonka',
    posterUrl: null,
    genres: [_comedy],
    releaseDate: DateTime(2023, 12, 15),
    voteAverage: 7.2,
  );
  static final _martySupreme = Movie(
    id: 9003,
    title: 'Marty Supreme',
    posterUrl: null,
    genres: [_drama],
    releaseDate: null,
    voteAverage: 0,
  );
  static final _oppenheimer = Movie(
    id: 9010,
    title: 'Oppenheimer',
    posterUrl: null,
    genres: [_drama],
    releaseDate: DateTime(2023, 7, 21),
    voteAverage: 8.2,
  );
  static final _peakyBlinders = TvShow(
    id: 9011,
    title: 'Peaky Blinders',
    posterUrl: null,
    genres: [_drama],
    releaseDate: DateTime(2013, 9, 12),
    voteAverage: 8.5,
  );
  static final _keanu = Movie(
    id: 9020,
    title: 'Keanu',
    posterUrl: null,
    genres: [_comedy],
    releaseDate: DateTime(2016, 4, 29),
    voteAverage: 6.3,
  );
  static final _getOut = Movie(
    id: 9021,
    title: 'Get Out',
    posterUrl: null,
    genres: [_horror],
    releaseDate: DateTime(2017, 2, 24),
    voteAverage: 7.7,
  );
  static final _theTwilightZone = TvShow(
    id: 9022,
    title: 'The Twilight Zone',
    posterUrl: null,
    genres: [_horror, _sciFi],
    releaseDate: DateTime(2019, 4, 1),
    voteAverage: 6.8,
  );
  static final _theLongHorizon = Movie(
    id: 9030,
    title: 'The Long Horizon',
    posterUrl: null,
    genres: [_drama],
    releaseDate: DateTime(1965, 6, 11),
    voteAverage: 7.0,
  );

  // Same ids as FakeMediaRepository's own "The Boys" (106) and
  // "Oppenheimer" (2) — Karl Urban's own credits below need to resolve
  // to the real D1/D2 sample pages when tapped, not a generic fallback.
  static final _theBoys = TvShow(
    id: 106,
    title: 'The Boys',
    posterUrl: null,
    genres: [_action, _sciFi],
    releaseDate: DateTime(2019, 7, 26),
    voteAverage: 8.4,
  );
  static final _oppenheimerFromMediaRepository = Movie(
    id: 2,
    title: 'Oppenheimer',
    posterUrl: null,
    genres: [_drama],
    releaseDate: DateTime(2023, 7, 21),
    voteAverage: 8.2,
  );

  static final Map<int, PersonDetail> _people = {
    1001: PersonDetail(
      person: Person(
        id: 1001,
        name: 'Timothée Chalamet',
        profilePath: null,
        knownForDepartment: 'Acting',
      ),
      biography:
          'Timothée Hal Chalamet is an American actor known for his roles '
          'in major studio and independent films.',
      biographyIsEnglishFallback: false,
      birthday: DateTime(1995, 12, 27),
      deathday: null,
      placeOfBirth: 'New York City, New York, USA',
      credits: [
        MediaCredit(item: _duneTwo, character: 'Paul Atreides'),
        MediaCredit(item: _wonka, character: 'Willy Wonka'),
        MediaCredit(item: _martySupreme, character: 'Marty'),
      ],
    ),
    1004: PersonDetail(
      person: Person(
        id: 1004,
        name: 'Denis Villeneuve',
        profilePath: null,
        knownForDepartment: 'Directing',
      ),
      // Empty in the (fake) requested language — this id's own stand-in
      // for personDetailFromDto's English-fallback branch.
      biography:
          'Denis Villeneuve is a Canadian film director known for Dune, '
          'Arrival, and Blade Runner 2049.',
      biographyIsEnglishFallback: true,
      birthday: DateTime(1967, 10, 3),
      deathday: null,
      placeOfBirth: 'Bécancour, Quebec, Canada',
      credits: [
        MediaCredit(item: _duneTwo, job: 'Director'),
        MediaCredit(item: _dune, job: 'Director'),
      ],
    ),
    1006: PersonDetail(
      person: Person(
        id: 1006,
        name: 'Cillian Murphy',
        profilePath: null,
        knownForDepartment: 'Acting',
      ),
      biography:
          'Cillian Murphy is an Irish actor known for Peaky Blinders and '
          'Oppenheimer.',
      biographyIsEnglishFallback: false,
      birthday: DateTime(1976, 5, 25),
      deathday: null,
      placeOfBirth: 'Douglas, Cork, Ireland',
      credits: [
        MediaCredit(item: _oppenheimer, character: 'J. Robert Oppenheimer'),
        MediaCredit(item: _peakyBlinders, character: 'Thomas Shelby'),
      ],
    ),
    1050: PersonDetail(
      person: Person(
        id: 1050,
        name: 'Jordan Peele',
        profilePath: null,
        knownForDepartment: 'Acting',
      ),
      biography:
          'Jordan Peele is an American actor, director, and producer '
          'known for Get Out and Us.',
      biographyIsEnglishFallback: false,
      birthday: DateTime(1979, 2, 21),
      deathday: null,
      placeOfBirth: 'New York City, New York, USA',
      credits: [
        MediaCredit(item: _keanu, character: 'Rell'),
        MediaCredit(item: _getOut, job: 'Director'),
        MediaCredit(item: _theTwilightZone, job: 'Director'),
      ],
    ),
    1060: PersonDetail(
      person: Person(
        id: 1060,
        name: 'Walter Voss',
        profilePath: null,
        knownForDepartment: 'Acting',
      ),
      biography:
          'Walter Voss was a stage and screen actor active from the late '
          '1950s through the 1990s.',
      biographyIsEnglishFallback: false,
      birthday: DateTime(1930, 5, 2),
      deathday: DateTime(1998, 11, 10),
      placeOfBirth: 'Linz, Austria',
      credits: [MediaCredit(item: _theLongHorizon, character: 'Captain Reyes')],
    ),
    2010: PersonDetail(
      person: Person(
        id: 2010,
        name: 'Karl Urban',
        profilePath: null,
        knownForDepartment: 'Acting',
      ),
      biography:
          'Karl Urban is a New Zealand actor known for The Boys and '
          'Dredd.',
      biographyIsEnglishFallback: false,
      birthday: DateTime(1972, 6, 7),
      deathday: null,
      placeOfBirth: 'Wellington, New Zealand',
      credits: [
        MediaCredit(item: _theBoys, character: 'Billy Butcher'),
        MediaCredit(
          item: _oppenheimerFromMediaRepository,
          character: 'Lewis Strauss',
        ),
      ],
    ),
  };

  @override
  Future<Result<PersonDetail>> detail(int personId) async {
    await Future.delayed(_delay);

    final person = _people[personId];
    if (person == null) {
      return Failure(FailureReason.notFound);
    }
    return Success(person);
  }
}
