import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';

void main() {
  group('Genre', () {
    test('two genres with the same id are equal, regardless of name', () {
      const a = Genre(id: 'action', name: 'Action');
      const b = Genre(id: 'action', name: 'Something else');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('genres with different ids are not equal', () {
      const action = Genre(id: 'action', name: 'Action');
      const comedy = Genre(id: 'comedy', name: 'Comedy');

      expect(action, isNot(equals(comedy)));
    });
  });
}
