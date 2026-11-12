import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/person.dart';
import 'package:movies/core/domain/entities/search_result.dart';
import 'package:movies/features/explore/domain/search_result_order.dart';

MediaResult _movie(int id, String title) => MediaResult(
  Movie(
    id: id,
    title: title,
    posterUrl: null,
    genres: const [],
    releaseDate: null,
    voteAverage: 7,
  ),
);

PersonResult _person(int id, String name) => PersonResult(
  Person(id: id, name: name, profilePath: null, knownForDepartment: 'Acting'),
);

String _label(SearchResult r) => switch (r) {
  MediaResult(:final item) => item.title,
  PersonResult(:final person) => person.name,
};

void main() {
  test('people sort last, titles keep their order', () {
    final ordered = orderSearchResults('dune', [
      _person(1, 'Dune Walker'),
      _movie(2, 'Dune'),
      _person(3, 'Duncan'),
      _movie(4, 'Dune: Part Two'),
    ]);

    expect(ordered.map(_label), [
      'Dune',
      'Dune: Part Two',
      'Dune Walker',
      'Duncan',
    ]);
  });

  test(
    'a person with exactly that name goes first (case/space-insensitive)',
    () {
      final ordered = orderSearchResults('  zendaya ', [
        _movie(1, 'Zendaya: The Film'),
        _person(2, 'Zendaya Stone'),
        _person(3, 'Zendaya'),
      ]);

      expect(ordered.map(_label), [
        'Zendaya',
        'Zendaya: The Film',
        'Zendaya Stone',
      ]);
    },
  );

  test('empty and title-only lists pass through', () {
    expect(orderSearchResults('x', []), isEmpty);
    final only = [_movie(1, 'A'), _movie(2, 'B')];
    expect(orderSearchResults('x', only).map(_label), ['A', 'B']);
  });
}
