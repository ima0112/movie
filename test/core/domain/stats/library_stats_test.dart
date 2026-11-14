import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/stats/library_stats.dart';

LibraryStats _stats({
  List<(Genre, int)> topGenres = const [],
  List<int>? monthlyActivity,
}) => LibraryStats(
  moviesWatched: 3,
  tvShowsWatched: 2,
  movieHours: 4.5,
  estimatedTvHours: 6,
  averageRating: 4,
  topGenres: topGenres,
  mostWatchedYear: 2024,
  monthlyActivity: monthlyActivity ?? List.filled(12, 0),
);

void main() {
  group('LibraryStats', () {
    test('requires exactly 12 monthlyActivity values', () {
      expect(
        () => _stats(monthlyActivity: List.filled(11, 0)),
        throwsA(isA<AssertionError>()),
      );
    });

    test('two instances with the same fields are equal', () {
      const action = Genre(id: 'action');
      final a = _stats(topGenres: [(action, 3)]);
      final b = _stats(topGenres: [(action, 3)]);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('a different topGenres order makes two instances unequal — it\'s '
        'a ranking, not a set', () {
      const action = Genre(id: 'action');
      const drama = Genre(id: 'drama');
      final a = _stats(topGenres: [(action, 3), (drama, 2)]);
      final b = _stats(topGenres: [(drama, 2), (action, 3)]);

      expect(a, isNot(equals(b)));
    });

    test('a different monthlyActivity makes two instances unequal', () {
      final a = _stats(monthlyActivity: List.filled(12, 0));
      final b = _stats(monthlyActivity: [1, ...List.filled(11, 0)]);

      expect(a, isNot(equals(b)));
    });
  });
}
