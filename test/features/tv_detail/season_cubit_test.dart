import 'package:flutter_test/flutter_test.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/features/tv_detail/presentation/cubit/season_cubit.dart';

void main() {
  group('SeasonCubit', () {
    test('starts in SeasonInitial', () {
      final cubit = SeasonCubit(FakeMediaRepository());
      expect(cubit.state, isA<SeasonInitial>());
      cubit.close();
    });

    test('loadSeason emits SeasonLoading before settling', () async {
      final cubit = SeasonCubit(FakeMediaRepository());

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([isA<SeasonLoading>(), isA<SeasonLoaded>()]),
      );

      await cubit.loadSeason(101, 1); // The Bear, Season 1
      await expectation;

      await cubit.close();
    });

    test('loadSeason ends in SeasonLoaded with the repository\'s season '
        'for a known show/season pair', () async {
      final cubit = SeasonCubit(FakeMediaRepository());

      await cubit.loadSeason(101, 0); // The Bear's special season

      final loaded = cubit.state as SeasonLoaded;
      expect(loaded.season.seasonNumber, 0);
      expect(loaded.season.name, 'Specials');
      expect(loaded.season.episodes, isNotEmpty);

      await cubit.close();
    });

    test('loadSeason ends in SeasonError for a season with no sample '
        'data', () async {
      final cubit = SeasonCubit(FakeMediaRepository());

      await cubit.loadSeason(106, 2); // The Boys, Season 2 (not detailed)

      expect(cubit.state, isA<SeasonError>());

      await cubit.close();
    });

    test('loadSeason ends in SeasonError for an unknown show id', () async {
      final cubit = SeasonCubit(FakeMediaRepository());

      await cubit.loadSeason(999, 1);

      expect(cubit.state, isA<SeasonError>());

      await cubit.close();
    });
  });
}
