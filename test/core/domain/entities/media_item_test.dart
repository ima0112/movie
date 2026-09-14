import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/media_type.dart';

Movie _movie({required int id, double voteAverage = 7}) {
  return Movie(
    id: id,
    title: 'Movie $id',
    posterUrl: null,
    genres: const [Genre(id: 'action', name: 'Action')],
    releaseDate: DateTime(2024),
    voteAverage: voteAverage,
  );
}

TvShow _tvShow({required int id}) {
  return TvShow(
    id: id,
    title: 'Show $id',
    posterUrl: null,
    genres: const [],
    releaseDate: null,
    voteAverage: 8,
  );
}

void main() {
  group('MediaItem', () {
    test('type reflects the concrete subclass', () {
      expect(_movie(id: 1).type, MediaType.movie);
      expect(_tvShow(id: 1).type, MediaType.tvShow);
    });

    test('two movies with the same id are equal, even if other fields '
        'drift between fetches', () {
      final a = _movie(id: 1, voteAverage: 7);
      final b = _movie(id: 1, voteAverage: 7.4);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('a movie and a TV show with the same id are not equal', () {
      final movie = _movie(id: 1);
      final tvShow = _tvShow(id: 1);

      expect(movie, isNot(equals(tvShow)));
    });

    test('items with different ids are not equal', () {
      expect(_movie(id: 1), isNot(equals(_movie(id: 2))));
    });
  });
}
