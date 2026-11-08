import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/person.dart';
import 'package:movies/features/person_detail/presentation/widgets/known_for.dart';

Movie _movie(int id, String title, double voteAverage) => Movie(
  id: id,
  title: title,
  posterUrl: null,
  genres: const [],
  releaseDate: null,
  voteAverage: voteAverage,
);

void main() {
  group('PersonKnownFor.knownForItems', () {
    test('sorts by voteAverage descending', () {
      final credits = [
        MediaCredit(item: _movie(1, 'Low', 5), character: 'A'),
        MediaCredit(item: _movie(2, 'High', 9), character: 'B'),
        MediaCredit(item: _movie(3, 'Mid', 7), character: 'C'),
      ];

      final items = credits.knownForItems();

      expect(items.map((i) => i.title), ['High', 'Mid', 'Low']);
    });

    test('dedupes repeated titles (e.g. acted in and also wrote one)', () {
      final sameMovie = _movie(1, 'Dual Credit', 8);
      final credits = [
        MediaCredit(item: sameMovie, character: 'Lead'),
        MediaCredit(item: sameMovie, job: 'Writer'),
        MediaCredit(item: _movie(2, 'Other', 6), character: 'B'),
      ];

      final items = credits.knownForItems();

      expect(items.map((i) => i.title), ['Dual Credit', 'Other']);
    });

    test('caps at the given limit (6 by default)', () {
      final credits = List.generate(
        10,
        (i) => MediaCredit(
          item: _movie(i, 'Title $i', i.toDouble()),
          character: 'Role',
        ),
      );

      expect(credits.knownForItems(), hasLength(6));
      expect(credits.knownForItems(limit: 3), hasLength(3));
    });
  });
}
