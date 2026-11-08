import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/features/tv_detail/presentation/cubit/tv_detail_cubit.dart';

void main() {
  group('TvDetailCubit', () {
    test('starts in TvDetailInitial', () {
      final cubit = TvDetailCubit(FakeMediaRepository());
      expect(cubit.state, isA<TvDetailInitial>());
      cubit.close();
    });

    test('loadDetail emits TvDetailLoading before settling', () async {
      final cubit = TvDetailCubit(FakeMediaRepository());

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([isA<TvDetailLoading>(), isA<TvDetailLoaded>()]),
      );

      await cubit.loadDetail(
        const MediaKey(type: MediaType.tvShow, tmdbId: 101),
      );
      await expectation;

      await cubit.close();
    });

    test('loadDetail ends in TvDetailLoaded with the repository\'s detail '
        'for a known id', () async {
      final cubit = TvDetailCubit(FakeMediaRepository());

      await cubit.loadDetail(
        const MediaKey(type: MediaType.tvShow, tmdbId: 106),
      );

      final loaded = cubit.state as TvDetailLoaded;
      final detail = loaded.detail as TvShowDetail;
      expect(detail.item.id, 106);
      expect(detail.item.title, 'The Boys');
      expect(detail.status, 'Returning Series');
      expect(detail.inProduction, isTrue);
      expect(detail.seasons, hasLength(4));

      await cubit.close();
    });

    test('loadDetail ends in TvDetailError for an unknown id', () async {
      final cubit = TvDetailCubit(FakeMediaRepository());

      await cubit.loadDetail(
        const MediaKey(type: MediaType.tvShow, tmdbId: 999),
      );

      expect(cubit.state, isA<TvDetailError>());

      await cubit.close();
    });
  });
}
