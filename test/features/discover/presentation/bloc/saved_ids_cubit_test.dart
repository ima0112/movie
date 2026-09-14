import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/discover/presentation/bloc/saved_ids_cubit.dart';

void main() {
  group('SavedIdsCubit', () {
    test('starts empty', () {
      final cubit = SavedIdsCubit();
      expect(cubit.state, isEmpty);
      cubit.close();
    });

    test('toggle adds an id not yet saved', () {
      final cubit = SavedIdsCubit();
      cubit.toggle(1);
      expect(cubit.state, {1});
      cubit.close();
    });

    test('toggle removes an id already saved', () {
      final cubit = SavedIdsCubit();
      cubit.toggle(1);
      cubit.toggle(1);
      expect(cubit.state, isEmpty);
      cubit.close();
    });

    test('toggling one id never affects another', () {
      final cubit = SavedIdsCubit();
      cubit.toggle(1);
      cubit.toggle(2);
      cubit.toggle(1);
      expect(cubit.state, {2});
      cubit.close();
    });
  });
}
