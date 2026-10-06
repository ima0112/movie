import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/person_detail/presentation/widgets/person_age.dart';

void main() {
  group('personAge', () {
    test('null when there is no birthday at all', () {
      expect(personAge(null, null), isNull);
    });

    test('a living person: whole years since birthday, as of reference', () {
      final age = personAge(
        DateTime(1995, 12, 27),
        null,
        reference: DateTime(2024, 3, 1),
      );

      expect(age, 28);
    });

    test("hasn't had this year's birthday yet: still last year's age", () {
      final age = personAge(
        DateTime(1995, 12, 27),
        null,
        reference: DateTime(2024, 1, 1),
      );

      // Born 1995-12-27: already 28 by 2023-12-27, so still 28 on
      // 2024-01-01 — the new birthday (and age 29) isn't due until
      // 2024-12-27.
      expect(age, 28);
    });

    test('exactly on the birthday: the new age already counts', () {
      final age = personAge(
        DateTime(1995, 12, 27),
        null,
        reference: DateTime(2024, 12, 27),
      );

      expect(age, 29);
    });

    test(
      'a deceased person: years lived, ignoring any later reference date',
      () {
        final age = personAge(
          DateTime(1930, 5, 2),
          DateTime(1998, 11, 10),
          reference: DateTime(2026, 1, 1),
        );

        expect(age, 68);
      },
    );

    test("a deceased person who died before that year's birthday: one "
        'year less', () {
      final age = personAge(DateTime(1930, 5, 2), DateTime(1998, 3, 1));

      expect(age, 67);
    });
  });
}
