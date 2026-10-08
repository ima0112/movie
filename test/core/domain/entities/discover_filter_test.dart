import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_type.dart';

const _drama = Genre(id: 'drama');
const _comedy = Genre(id: 'comedy');

void main() {
  group('DiscoverFilter', () {
    test('the default instance is isDefault', () {
      expect(const DiscoverFilter().isDefault, isTrue);
    });

    test('any non-default field makes isDefault false', () {
      expect(const DiscoverFilter(type: MediaType.movie).isDefault, isFalse);
    });

    test('two instances with the same fields are equal, genre sets '
        'compared by content', () {
      final a = DiscoverFilter(withGenres: {_drama, _comedy});
      final b = DiscoverFilter(withGenres: {_comedy, _drama});

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('a different sortBy makes two instances unequal', () {
      const a = DiscoverFilter();
      const b = DiscoverFilter(sortBy: DiscoverSortBy.title);

      expect(a, isNot(equals(b)));
    });

    test('a different maxRuntimeMinutes or tvStatus makes two instances '
        'unequal too', () {
      const base = DiscoverFilter(type: MediaType.movie);

      expect(
        base,
        isNot(
          equals(
            const DiscoverFilter(type: MediaType.movie, maxRuntimeMinutes: 120),
          ),
        ),
      );
      expect(
        const DiscoverFilter(type: MediaType.tvShow),
        isNot(
          equals(
            const DiscoverFilter(
              type: MediaType.tvShow,
              tvStatus: DiscoverTvStatus.ended,
            ),
          ),
        ),
      );
    });
  });

  group('DiscoverFilter.copyWith', () {
    test('a field not passed at all stays unchanged', () {
      const original = DiscoverFilter(type: MediaType.movie, minVoteAverage: 7);

      final copy = original.copyWith(sortBy: DiscoverSortBy.title);

      expect(copy.type, MediaType.movie);
      expect(copy.minVoteAverage, 7);
      expect(copy.sortBy, DiscoverSortBy.title);
    });

    test('a nullable field can be explicitly cleared to null', () {
      const original = DiscoverFilter(type: MediaType.movie, yearFrom: 2000);

      final copy = original.copyWith(yearFrom: () => null);

      expect(copy.yearFrom, isNull);
      expect(copy.type, MediaType.movie);
    });

    test('withGenres/withoutGenres/sortBy use the plain "not passed" '
        'form, no wrapper function needed', () {
      const genre = Genre(id: 'drama');
      const original = DiscoverFilter();

      final copy = original.copyWith(withGenres: {genre});

      expect(copy.withGenres, {genre});
      expect(copy.withoutGenres, isEmpty);
    });
  });
}
