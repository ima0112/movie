import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/features/tv_detail/presentation/cubit/tv_detail_cubit.dart';

const _theBoys = MediaKey(type: MediaType.tvShow, tmdbId: 106);

void main() {
  group('TvDetailCubit', () {
    test('starts in TvDetailInitial', () {
      final cubit = TvDetailCubit(
        FakeMediaRepository(),
        InMemoryUserLibraryRepository(),
      );
      expect(cubit.state, isA<TvDetailInitial>());
      cubit.close();
    });

    test('loadDetail emits TvDetailLoading before settling', () async {
      final cubit = TvDetailCubit(
        FakeMediaRepository(),
        InMemoryUserLibraryRepository(),
      );

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
      final cubit = TvDetailCubit(
        FakeMediaRepository(),
        InMemoryUserLibraryRepository(),
      );

      await cubit.loadDetail(_theBoys);

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
      final cubit = TvDetailCubit(
        FakeMediaRepository(),
        InMemoryUserLibraryRepository(),
      );

      await cubit.loadDetail(
        const MediaKey(type: MediaType.tvShow, tmdbId: 999),
      );

      expect(cubit.state, isA<TvDetailError>());

      await cubit.close();
    });

    group('lazy My List snapshot refresh', () {
      test(
        'loadDetail refreshes an already-saved entry\'s catalog fields '
        '(rating, year, episode count/runtime) without being asked',
        () async {
          final userLibraryRepository = InMemoryUserLibraryRepository();
          await userLibraryRepository.upsert(
            const UserMediaEntry(
              key: _theBoys,
              title: 'Stale title',
              isWatchLater: true,
            ),
          );
          final cubit = TvDetailCubit(
            FakeMediaRepository(),
            userLibraryRepository,
          );

          await cubit.loadDetail(_theBoys);

          final refreshed = await userLibraryRepository
              .watchEntry(_theBoys)
              .first;
          expect(refreshed!.title, 'The Boys');
          expect(refreshed.voteAverage, 8.4);
          expect(refreshed.year, 2019);
          expect(refreshed.episodeCount, 32);
          expect(refreshed.episodeRuntimeMinutes, 60);

          await cubit.close();
        },
      );

      test('a favorite toggle that lands while loadDetail is refreshing '
          'the catalog snapshot is not lost', () async {
        final userLibraryRepository = InMemoryUserLibraryRepository();
        await userLibraryRepository.upsert(
          const UserMediaEntry(key: _theBoys, title: 'Stale title'),
        );
        final cubit = TvDetailCubit(
          FakeMediaRepository(),
          userLibraryRepository,
        );

        await Future.wait([
          cubit.loadDetail(_theBoys),
          userLibraryRepository.upsert(
            const UserMediaEntry(
              key: _theBoys,
              title: 'Stale title',
              isFavorite: true,
            ),
          ),
        ]);

        final result = await userLibraryRepository.watchEntry(_theBoys).first;
        expect(result!.isFavorite, isTrue);

        await cubit.close();
      });
    });
  });
}
