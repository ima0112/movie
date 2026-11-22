import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/tmdb/tmdb_genre_mapper.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/genre_catalog.dart';
import 'package:movies/core/domain/entities/media_type.dart';

const _action = Genre(id: 'action');
const _sciFi = Genre(id: 'sci-fi');
const _fantasy = Genre(id: 'fantasy');
const _war = Genre(id: 'war');
const _western = Genre(id: 'western');

void main() {
  group('TmdbGenreMapper.fromTmdbId', () {
    test('resolves a known movie id', () {
      expect(TmdbGenreMapper.fromTmdbId(28, MediaType.movie), _action);
    });

    test('resolves fantasy (14) for movie — its own distinct TMDB id, '
        'no sharing with any other genre', () {
      expect(TmdbGenreMapper.fromTmdbId(14, MediaType.movie), _fantasy);
    });

    test("TV's merged \"Action & Adventure\" (10759) resolves to action", () {
      expect(TmdbGenreMapper.fromTmdbId(10759, MediaType.tvShow), _action);
    });

    test('TV\'s merged "Sci-Fi & Fantasy" (10765) still resolves to '
        'sci-fi, not fantasy — fromTmdbId can only ever answer one way '
        'for a shared id, and this one is unchanged from before fantasy '
        'existed', () {
      expect(TmdbGenreMapper.fromTmdbId(10765, MediaType.tvShow), _sciFi);
    });

    test('an id with no catalog equivalent at all (TV Movie, 10770) returns '
        'null for both types, not an error', () {
      expect(TmdbGenreMapper.fromTmdbId(10770, MediaType.movie), isNull);
      expect(TmdbGenreMapper.fromTmdbId(10770, MediaType.tvShow), isNull);
    });

    test('War and Western resolve: War is 10752 in movies and "War & '
        'Politics" (10768) in TV; Western is 37 in both', () {
      expect(TmdbGenreMapper.fromTmdbId(10752, MediaType.movie), _war);
      expect(TmdbGenreMapper.fromTmdbId(10768, MediaType.tvShow), _war);
      expect(TmdbGenreMapper.fromTmdbId(37, MediaType.movie), _western);
      expect(TmdbGenreMapper.fromTmdbId(37, MediaType.tvShow), _western);
    });

    test('a movie-only id means nothing on TV and the reverse', () {
      expect(TmdbGenreMapper.fromTmdbId(10752, MediaType.tvShow), isNull);
      expect(TmdbGenreMapper.fromTmdbId(10768, MediaType.movie), isNull);
    });
  });

  group('TmdbGenreMapper.toTmdbId', () {
    test('War and Western go back to each kind of title\'s own id', () {
      expect(TmdbGenreMapper.toTmdbId(_war, MediaType.movie), 10752);
      expect(TmdbGenreMapper.toTmdbId(_war, MediaType.tvShow), 10768);
      expect(TmdbGenreMapper.toTmdbId(_western, MediaType.movie), 37);
      expect(TmdbGenreMapper.toTmdbId(_western, MediaType.tvShow), 37);
    });

    test('resolves a known movie genre', () {
      expect(TmdbGenreMapper.toTmdbId(_action, MediaType.movie), 28);
    });

    test('fantasy resolves its own distinct id for movie (14)', () {
      expect(TmdbGenreMapper.toTmdbId(_fantasy, MediaType.movie), 14);
    });

    test('fantasy resolves to the shared "Sci-Fi & Fantasy" id (10765) '
        'for tv — the toTmdbId-only extra entry, since it has no row of '
        'its own in the id->genre table', () {
      expect(TmdbGenreMapper.toTmdbId(_fantasy, MediaType.tvShow), 10765);
    });

    test('sci-fi still resolves to the same shared id (10765) for tv — '
        'vetoing either one would exclude the same TMDB category', () {
      expect(TmdbGenreMapper.toTmdbId(_sciFi, MediaType.tvShow), 10765);
    });

    test('a genre with no TMDB id for this type returns null, not an '
        'error — e.g. romance has no TV-side entry at all', () {
      expect(
        TmdbGenreMapper.toTmdbId(const Genre(id: 'romance'), MediaType.tvShow),
        isNull,
      );
    });

    test('thriller has no TV id (37 is Western now, it used to be sent for '
        'thriller by mistake)', () {
      expect(
        TmdbGenreMapper.toTmdbId(const Genre(id: 'thriller'), MediaType.tvShow),
        isNull,
      );
      expect(TmdbGenreMapper.fromTmdbId(37, MediaType.tvShow), _western);
      expect(
        TmdbGenreMapper.toTmdbId(const Genre(id: 'thriller'), MediaType.movie),
        53,
      );
    });
  });

  group('TmdbGenreMapper.tvVetoKeywordIds', () {
    test('Horror, Romance, Thriller, History and Music stand in as keywords — '
        'History and Music with the whole set that stands in for them', () {
      expect(
        TmdbGenreMapper.tvVetoKeywordIds(const [
          Genre(id: 'horror'),
          Genre(id: 'romance'),
          Genre(id: 'thriller'),
        ]),
        {315058, 9840, 316362},
      );
      expect(TmdbGenreMapper.tvVetoKeywordIds(const [Genre(id: 'history')]), {
        15060,
        15126,
        282633,
      });
      expect(TmdbGenreMapper.tvVetoKeywordIds(const [Genre(id: 'music')]), {
        283297,
        4344,
        10229,
        186120,
        4048,
        311916,
        236650,
        6029,
      });
    });

    test('genres TV does have (or any other) add nothing', () {
      expect(
        TmdbGenreMapper.tvVetoKeywordIds(const [
          Genre(id: 'action'),
          Genre(id: 'comedy'),
          Genre(id: 'fantasy'),
        ]),
        isEmpty,
      );
    });
  });

  group('TmdbGenreMapper.tvStandInGenres', () {
    test('the keywords that stand in for a genre give the show that genre', () {
      expect(TmdbGenreMapper.tvStandInGenres([315058, 9840, 999]), {
        const Genre(id: 'horror'),
        const Genre(id: 'romance'),
      });
      expect(TmdbGenreMapper.tvStandInGenres(const []), isEmpty);
    });

    test('Music is not given to a talk show with a music keyword', () {
      expect(TmdbGenreMapper.tvStandInGenres([4344]), {
        const Genre(id: 'music'),
      });
      expect(
        TmdbGenreMapper.tvStandInGenres([4344], tmdbGenreIds: [10767]),
        isEmpty,
      );
    });
  });

  group('TmdbGenreMapper.isStandInOnTv', () {
    test('exactly the five genres TMDB\'s TV list lacks', () {
      final standIns = [
        for (final g in GenreCatalog.all)
          if (TmdbGenreMapper.isStandInOnTv(g)) g.id,
      ];
      expect(standIns, ['history', 'horror', 'music', 'romance', 'thriller']);
    });
  });

  group('TmdbGenreMapper.tvLikeGenreIds', () {
    test('a like asks for the genre\'s own TV id; Adventure and Fantasy ask '
        'for the combined ones', () {
      expect(
        TmdbGenreMapper.tvLikeGenreIds(const [
          Genre(id: 'comedy'),
          Genre(id: 'adventure'),
          Genre(id: 'fantasy'),
          Genre(id: 'war'),
          Genre(id: 'western'),
        ]),
        {35, 10759, 10765, 10768, 37},
      );
    });

    test('the stand-in genres have no TV id to like by', () {
      expect(
        TmdbGenreMapper.tvLikeGenreIds(const [
          Genre(id: 'horror'),
          Genre(id: 'history'),
        ]),
        isEmpty,
      );
    });
  });

  group('TmdbGenreMapper.tvVetoGenreIds', () {
    test('a plain genre is excluded by its own id', () {
      expect(
        TmdbGenreMapper.tvVetoGenreIds(const [
          Genre(id: 'comedy'),
          Genre(id: 'war'),
          Genre(id: 'western'),
        ]),
        {35, 10768, 37},
      );
    });

    test('vetoing Fantasy alone leaves Sci-Fi & Fantasy in; Sci-Fi alone too; '
        'both exclude it', () {
      expect(
        TmdbGenreMapper.tvVetoGenreIds(const [Genre(id: 'fantasy')]),
        isEmpty,
      );
      expect(
        TmdbGenreMapper.tvVetoGenreIds(const [Genre(id: 'sci-fi')]),
        isEmpty,
      );
      expect(
        TmdbGenreMapper.tvVetoGenreIds(const [
          Genre(id: 'sci-fi'),
          Genre(id: 'fantasy'),
        ]),
        {10765},
      );
    });

    test('Action & Adventure likewise needs both vetoed', () {
      expect(
        TmdbGenreMapper.tvVetoGenreIds(const [Genre(id: 'action')]),
        isEmpty,
      );
      expect(
        TmdbGenreMapper.tvVetoGenreIds(const [Genre(id: 'adventure')]),
        isEmpty,
      );
      expect(
        TmdbGenreMapper.tvVetoGenreIds(const [
          Genre(id: 'action'),
          Genre(id: 'adventure'),
        ]),
        {10759},
      );
    });

    test('a stand-in genre has no id to exclude by (a keyword does it)', () {
      expect(
        TmdbGenreMapper.tvVetoGenreIds(const [Genre(id: 'horror')]),
        isEmpty,
      );
    });
  });

  group('TmdbGenreMapper.tvStandInGroups', () {
    test('every stand-in but Music shares one group; Music has its own, with '
        'Talk left out', () {
      final groups = TmdbGenreMapper.tvStandInGroups(const [
        Genre(id: 'horror'),
        Genre(id: 'history'),
        Genre(id: 'music'),
        Genre(id: 'comedy'),
      ]);

      expect(groups, hasLength(2));
      expect(groups[0].keywordIds, {315058, 15060, 15126, 282633});
      expect(groups[0].withoutTmdbGenreIds, isEmpty);
      expect(groups[1].keywordIds, contains(283297));
      expect(groups[1].withoutTmdbGenreIds, {10767});
    });

    test('no stand-in among the genres, no group', () {
      expect(
        TmdbGenreMapper.tvStandInGroups(const [Genre(id: 'comedy')]),
        isEmpty,
      );
    });
  });
}
