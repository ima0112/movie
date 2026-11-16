import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/tmdb/tmdb_genre_mapper.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_type.dart';

const _action = Genre(id: 'action');
const _sciFi = Genre(id: 'sci-fi');
const _fantasy = Genre(id: 'fantasy');

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

    test('an id with no catalog equivalent at all (War, 10752) returns '
        'null for both types, not an error', () {
      expect(TmdbGenreMapper.fromTmdbId(10752, MediaType.movie), isNull);
      expect(TmdbGenreMapper.fromTmdbId(10752, MediaType.tvShow), isNull);
    });
  });

  group('TmdbGenreMapper.toTmdbId', () {
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

    test('thriller has no TV id (37 is Western — it used to map there)', () {
      expect(
        TmdbGenreMapper.toTmdbId(const Genre(id: 'thriller'), MediaType.tvShow),
        isNull,
      );
      expect(TmdbGenreMapper.fromTmdbId(37, MediaType.tvShow), isNull);
      expect(
        TmdbGenreMapper.toTmdbId(const Genre(id: 'thriller'), MediaType.movie),
        53,
      );
    });
  });

  group('TmdbGenreMapper.tvVetoKeywordIds', () {
    test(
      'Horror, Romance, Thriller, History and Music stand in as keywords',
      () {
        expect(
          TmdbGenreMapper.tvVetoKeywordIds(const [
            Genre(id: 'horror'),
            Genre(id: 'romance'),
            Genre(id: 'thriller'),
            Genre(id: 'history'),
            Genre(id: 'music'),
          ]),
          {315058, 9840, 316362, 282633, 283297},
        );
      },
    );

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
}
