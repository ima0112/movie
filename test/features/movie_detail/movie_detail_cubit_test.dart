import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/features/movie_detail/presentation/cubit/movie_detail_cubit.dart';

void main() {
  group('MovieDetailCubit', () {
    test('starts in MovieDetailInitial', () {
      final cubit = MovieDetailCubit(FakeMediaRepository());
      expect(cubit.state, isA<MovieDetailInitial>());
      cubit.close();
    });

    test('loadDetail emits MovieDetailLoading before settling', () async {
      final cubit = MovieDetailCubit(FakeMediaRepository());

      // `emitsInOrder` subscribes right away, so it can't race the
      // eventual emit the way manually collecting into a list would.
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([isA<MovieDetailLoading>(), isA<MovieDetailLoaded>()]),
      );

      await cubit.loadDetail(const MediaKey(type: MediaType.movie, tmdbId: 1));
      await expectation;

      await cubit.close();
    });

    test('loadDetail ends in MovieDetailLoaded with the repository\'s detail '
        'for a known id', () async {
      final cubit = MovieDetailCubit(FakeMediaRepository());

      await cubit.loadDetail(const MediaKey(type: MediaType.movie, tmdbId: 1));

      final loaded = cubit.state as MovieDetailLoaded;
      final detail = loaded.detail as MovieDetail;
      expect(detail.item.id, 1);
      expect(detail.item.title, 'Dune: Part Two');
      expect(detail.trailer, isNotNull);

      await cubit.close();
    });

    test('loadDetail ends in MovieDetailError for an unknown id', () async {
      final cubit = MovieDetailCubit(FakeMediaRepository());

      await cubit.loadDetail(
        const MediaKey(type: MediaType.movie, tmdbId: 999),
      );

      expect(cubit.state, isA<MovieDetailError>());

      await cubit.close();
    });

    test('loadDetail ends in MovieDetailError for a TV show key '
        '(D2 not implemented yet)', () async {
      final cubit = MovieDetailCubit(FakeMediaRepository());

      await cubit.loadDetail(
        const MediaKey(type: MediaType.tvShow, tmdbId: 101),
      );

      expect(cubit.state, isA<MovieDetailError>());

      await cubit.close();
    });
  });
}
