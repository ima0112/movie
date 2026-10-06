import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/person.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/features/person_detail/data/repositories/fake_person_repository.dart';

void main() {
  group('FakePersonRepository.detail', () {
    final repository = FakePersonRepository();

    test('fails for an unknown person id', () async {
      final result = await repository.detail(999);

      expect(result, isA<Failure<PersonDetail>>());
    });

    test(
      'Karl Urban (2010) shares ids with FakeMediaRepository\'s own '
      'sample data — The Boys (106, TV) and Oppenheimer (2, movie)',
      () async {
        final result = await repository.detail(2010);

        final detail = (result as Success<PersonDetail>).value;
        expect(detail.person.name, 'Karl Urban');

        final theBoysCredit = detail.credits.firstWhere(
          (c) => c.item.type == MediaType.tvShow,
        );
        expect(theBoysCredit.item.id, 106);

        final oppenheimerCredit = detail.credits.firstWhere(
          (c) => c.item.type == MediaType.movie,
        );
        expect(oppenheimerCredit.item.id, 2);
        expect(oppenheimerCredit.item.title, 'Oppenheimer');
      },
    );
  });
}
