import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_segment.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/repositories/media_repository.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/features/discover/presentation/bloc/discover_cubit.dart';

void main() {
  group('DiscoverCubit', () {
    test('starts in DiscoverInitial', () {
      final cubit = DiscoverCubit(FakeMediaRepository());
      expect(cubit.state, isA<DiscoverInitial>());
      cubit.close();
    });

    test('loadDiscover emits DiscoverLoading before settling', () async {
      final cubit = DiscoverCubit(FakeMediaRepository());

      // `emitsInOrder` subscribes right away, so it can't race the
      // eventual emit the way manually collecting into a list would.
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([isA<DiscoverLoading>(), isA<DiscoverLoaded>()]),
      );

      await cubit.loadDiscover(MediaSegment.movie);
      await expectation;

      await cubit.close();
    });

    test(
      'loadDiscover(movie) ends in DiscoverLoaded with movie-only data '
      'and the Movies-segment carousels',
      () async {
        final cubit = DiscoverCubit(FakeMediaRepository());

        await cubit.loadDiscover(MediaSegment.movie);

        final loaded = cubit.state as DiscoverLoaded;
        expect(loaded.segment, MediaSegment.movie);
        expect(loaded.heroItems, isNotEmpty);
        expect(
          loaded.heroItems.every((item) => item.type == MediaType.movie),
          isTrue,
        );
        expect(loaded.carousels.keys, [
          CarouselSection.inTheaters,
          CarouselSection.trending,
          CarouselSection.topRated,
          CarouselSection.upcoming,
        ]);
        for (final items in loaded.carousels.values) {
          expect(items.every((item) => item.type == MediaType.movie), isTrue);
        }

        await cubit.close();
      },
    );

    test('loadDiscover(all) uses the All-segment carousels', () async {
      final cubit = DiscoverCubit(FakeMediaRepository());

      await cubit.loadDiscover(MediaSegment.all);

      final loaded = cubit.state as DiscoverLoaded;
      expect(loaded.carousels.keys, [
        CarouselSection.popularThisWeek,
        CarouselSection.watchLater,
      ]);

      await cubit.close();
    });
  });
}
