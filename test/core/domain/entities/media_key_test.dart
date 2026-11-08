import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';

void main() {
  group('MediaKey', () {
    test('two keys with the same type and tmdbId are equal', () {
      const a = MediaKey(type: MediaType.movie, tmdbId: 1);
      const b = MediaKey(type: MediaType.movie, tmdbId: 1);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('same tmdbId but different type are not equal', () {
      const movie = MediaKey(type: MediaType.movie, tmdbId: 1);
      const tvShow = MediaKey(type: MediaType.tvShow, tmdbId: 1);

      expect(movie, isNot(equals(tvShow)));
    });

    test('works as a Map key', () {
      const key = MediaKey(type: MediaType.movie, tmdbId: 1);
      final map = {key: 'value'};

      expect(map[const MediaKey(type: MediaType.movie, tmdbId: 1)], 'value');
    });
  });
}
