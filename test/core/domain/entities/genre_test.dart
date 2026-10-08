import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';

void main() {
  group('Genre', () {
    test('two genres with the same id are equal', () {
      const a = Genre(id: 'action');
      const b = Genre(id: 'action');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('genres with different ids are not equal', () {
      const action = Genre(id: 'action');
      const comedy = Genre(id: 'comedy');

      expect(action, isNot(equals(comedy)));
    });
  });
}
