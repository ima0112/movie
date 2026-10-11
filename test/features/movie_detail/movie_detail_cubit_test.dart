import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/features/movie_detail/presentation/cubit/movie_detail_cubit.dart';

const _dune = MediaKey(type: MediaType.movie, tmdbId: 1);

void main() {
  group('MovieDetailCubit', () {
    test('starts in MovieDetailInitial', () {
      final cubit = MovieDetailCubit(
        FakeMediaRepository(),
        InMemoryUserLibraryRepository(),
      );
      expect(cubit.state, isA<MovieDetailInitial>());
      cubit.close();
    });

    test('loadDetail emits MovieDetailLoading before settling', () async {
      final cubit = MovieDetailCubit(
        FakeMediaRepository(),
        InMemoryUserLibraryRepository(),
      );

      // `emitsInOrder` subscribes right away, so it can't race the
      // eventual emit the way manually collecting into a list would.
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([isA<MovieDetailLoading>(), isA<MovieDetailLoaded>()]),
      );

      await cubit.loadDetail(_dune);
      await expectation;

      await cubit.close();
    });

    test('loadDetail ends in MovieDetailLoaded with the repository\'s detail '
        'for a known id', () async {
      final cubit = MovieDetailCubit(
        FakeMediaRepository(),
        InMemoryUserLibraryRepository(),
      );

      await cubit.loadDetail(_dune);

      final loaded = cubit.state as MovieDetailLoaded;
      final detail = loaded.detail as MovieDetail;
      expect(detail.item.id, 1);
      expect(detail.item.title, 'Dune: Part Two');
      expect(detail.trailer, isNotNull);

      await cubit.close();
    });

    test('loadDetail ends in MovieDetailError for an unknown id', () async {
      final cubit = MovieDetailCubit(
        FakeMediaRepository(),
        InMemoryUserLibraryRepository(),
      );

      await cubit.loadDetail(
        const MediaKey(type: MediaType.movie, tmdbId: 999),
      );

      expect(cubit.state, isA<MovieDetailError>());

      await cubit.close();
    });

    // MovieDetailCubit never actually gets a TV key in practice — D2 uses
    // its own TvDetailCubit — but the repository call itself is generic,
    // so this just confirms it doesn't special-case the type.
    test('loadDetail ends in MovieDetailLoaded for a TV show key too, '
        'since the repository call itself is type-agnostic', () async {
      final cubit = MovieDetailCubit(
        FakeMediaRepository(),
        InMemoryUserLibraryRepository(),
      );

      await cubit.loadDetail(
        const MediaKey(type: MediaType.tvShow, tmdbId: 101),
      );

      final loaded = cubit.state as MovieDetailLoaded;
      expect(loaded.detail.item.title, 'The Bear');

      await cubit.close();
    });

    group('lazy My List snapshot refresh', () {
      test('loadDetail refreshes an already-saved entry\'s catalog fields '
          '(poster, rating, year, runtime) without being asked', () async {
        final userLibraryRepository = InMemoryUserLibraryRepository();
        await userLibraryRepository.upsert(
          const UserMediaEntry(key: _dune, title: 'Stale title', isFavorite: true),
        );
        final cubit = MovieDetailCubit(
          FakeMediaRepository(),
          userLibraryRepository,
        );

        await cubit.loadDetail(_dune);

        final refreshed = await userLibraryRepository.watchEntry(_dune).first;
        expect(refreshed!.title, 'Dune: Part Two');
        expect(refreshed.voteAverage, 8.4);
        expect(refreshed.year, 2024);
        expect(refreshed.runtimeMinutes, 166);

        await cubit.close();
      });

      test('never creates an entry for a title the user never saved',
          () async {
        final userLibraryRepository = InMemoryUserLibraryRepository();
        final cubit = MovieDetailCubit(
          FakeMediaRepository(),
          userLibraryRepository,
        );

        await cubit.loadDetail(_dune);

        expect(await userLibraryRepository.watchEntry(_dune).first, isNull);

        await cubit.close();
      });

      test('a favorite toggle that lands while loadDetail is refreshing '
          'the catalog snapshot is not lost — the refresh only ever '
          'touches catalog columns', () async {
        final userLibraryRepository = InMemoryUserLibraryRepository();
        await userLibraryRepository.upsert(
          const UserMediaEntry(key: _dune, title: 'Stale title'),
        );
        final cubit = MovieDetailCubit(
          FakeMediaRepository(),
          userLibraryRepository,
        );

        // Simulates the toggle landing "during" loadDetail: both writes
        // are in flight together, with no guaranteed order between
        // them, exactly what MediaDetailActionRow's own upsert and this
        // cubit's refresh would do if the user tapped Favorite the
        // instant D1 finished loading.
        await Future.wait([
          cubit.loadDetail(_dune),
          userLibraryRepository.upsert(
            const UserMediaEntry(
              key: _dune,
              title: 'Stale title',
              isFavorite: true,
            ),
          ),
        ]);

        final result = await userLibraryRepository.watchEntry(_dune).first;
        expect(result!.isFavorite, isTrue);

        await cubit.close();
      });
    });
  });
}
