import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/person_detail/data/repositories/fake_person_repository.dart';
import 'package:movies/features/person_detail/presentation/cubit/person_detail_cubit.dart';

void main() {
  group('PersonDetailCubit', () {
    test('starts in PersonDetailInitial', () {
      final cubit = PersonDetailCubit(FakePersonRepository());
      expect(cubit.state, isA<PersonDetailInitial>());
      cubit.close();
    });

    test('loadDetail emits PersonDetailLoading before settling', () async {
      final cubit = PersonDetailCubit(FakePersonRepository());

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([isA<PersonDetailLoading>(), isA<PersonDetailLoaded>()]),
      );

      await cubit.loadDetail(1001);
      await expectation;

      await cubit.close();
    });

    test('loadDetail ends in PersonDetailLoaded with the repository\'s '
        'detail for a known id', () async {
      final cubit = PersonDetailCubit(FakePersonRepository());

      await cubit.loadDetail(1001);

      final loaded = cubit.state as PersonDetailLoaded;
      expect(loaded.detail.person.name, 'Timothée Chalamet');

      await cubit.close();
    });

    test('loadDetail ends in PersonDetailError for an unknown id', () async {
      final cubit = PersonDetailCubit(FakePersonRepository());

      await cubit.loadDetail(999);

      expect(cubit.state, isA<PersonDetailError>());

      await cubit.close();
    });
  });
}
