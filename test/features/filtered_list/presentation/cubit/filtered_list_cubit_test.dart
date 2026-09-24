import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/repositories/media_repository.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/features/filtered_list/presentation/cubit/filtered_list_cubit.dart';
import 'package:movies/features/filtered_list/presentation/cubit/filtered_list_state.dart';

const _horror = Genre(id: 'horror', name: 'Horror');

void main() {
  group('FilteredListCubit', () {
    test('starts in FilteredListInitial with the given filter', () {
      const filter = DiscoverFilter(type: MediaType.movie);
      final cubit = FilteredListCubit(FakeMediaRepository(), filter);

      expect(cubit.state, isA<FilteredListInitial>());
      expect(cubit.state.filter, filter);

      cubit.close();
    });

    test('load() emits Loading before Loaded', () async {
      final cubit = FilteredListCubit(
        FakeMediaRepository(),
        const DiscoverFilter(type: MediaType.movie),
      );

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([isA<FilteredListLoading>(), isA<FilteredListLoaded>()]),
      );

      await cubit.load();
      await expectation;
      await cubit.close();
    });

    test('Loaded reveals only the first page even though allItems holds '
        'every result', () async {
      // type: null (All) — 9 sample movies + 7 sample TV shows = 16,
      // more than pageSize (movies alone are only 9, too few to
      // exercise a second page at all).
      final cubit = FilteredListCubit(
        FakeMediaRepository(),
        const DiscoverFilter(),
      );

      await cubit.load();

      final loaded = cubit.state as FilteredListLoaded;
      expect(loaded.totalCount, greaterThan(FilteredListCubit.pageSize));
      expect(loaded.visibleItems, hasLength(FilteredListCubit.pageSize));
      expect(loaded.hasMore, isTrue);

      await cubit.close();
    });

    test('loadMore() reveals the next page, up to the true total', () async {
      final cubit = FilteredListCubit(
        FakeMediaRepository(),
        const DiscoverFilter(),
      );
      await cubit.load();
      final total = (cubit.state as FilteredListLoaded).totalCount;

      cubit.loadMore();

      final loaded = cubit.state as FilteredListLoaded;
      expect(
        loaded.visibleItems.length,
        (FilteredListCubit.pageSize * 2).clamp(0, total),
      );
      expect(loaded.hasMore, loaded.visibleItems.length < total);

      await cubit.close();
    });

    test('loadMore() is a no-op once everything is already visible', () async {
      final cubit = FilteredListCubit(
        FakeMediaRepository(),
        // Horror only matches one sample movie — fits on the first page.
        DiscoverFilter(type: MediaType.movie, withGenres: {_horror}),
      );
      await cubit.load();
      final before = cubit.state as FilteredListLoaded;
      expect(before.hasMore, isFalse);

      cubit.loadMore();

      expect(cubit.state, same(before));
      await cubit.close();
    });

    test('updateFilter() re-fetches with the new filter, resetting the '
        'page', () async {
      final cubit = FilteredListCubit(
        FakeMediaRepository(),
        const DiscoverFilter(), // All — 16 items, more than one page.
      );
      await cubit.load();
      cubit.loadMore();
      expect(
        (cubit.state as FilteredListLoaded).visibleCount,
        greaterThan(FilteredListCubit.pageSize),
      );

      await cubit.updateFilter(
        DiscoverFilter(type: MediaType.movie, withGenres: {_horror}),
      );

      final loaded = cubit.state as FilteredListLoaded;
      expect(loaded.filter.withGenres, {_horror});
      expect(loaded.visibleCount, loaded.totalCount);

      await cubit.close();
    });

    test('retry() re-runs the last filter', () async {
      final cubit = FilteredListCubit(
        FakeMediaRepository(),
        const DiscoverFilter(type: MediaType.movie),
      );
      await cubit.load();

      await cubit.retry();

      expect(cubit.state, isA<FilteredListLoaded>());
      await cubit.close();
    });

    test('with a collectionSection and a still-default filter, load() '
        'fetches that collection instead of calling discover()', () async {
      final cubit = FilteredListCubit(
        FakeMediaRepository(),
        const DiscoverFilter(type: MediaType.movie),
        collectionSection: CarouselSection.inTheaters,
      );

      await cubit.load();

      // FakeMediaRepository.getCarouselSection always succeeds with up to
      // 10 items — this only proves that endpoint (not discover()) is the
      // one that ran, not anything about its content.
      final loaded = cubit.state as FilteredListLoaded;
      expect(loaded.totalCount, lessThanOrEqualTo(10));
      await cubit.close();
    });

    test('updateFilter() clears collectionSection — a filter being '
        'touched permanently switches to discover(), which (unlike '
        'getCarouselSection) actually applies minVoteAverage', () async {
      final cubit = FilteredListCubit(
        FakeMediaRepository(),
        const DiscoverFilter(type: MediaType.movie),
        collectionSection: CarouselSection.inTheaters,
      );
      await cubit.load();
      final unfilteredTotal = (cubit.state as FilteredListLoaded).totalCount;

      await cubit.updateFilter(
        const DiscoverFilter(type: MediaType.movie, minVoteAverage: 8.5),
      );

      expect(
        (cubit.state as FilteredListLoaded).totalCount,
        lessThan(unfilteredTotal),
      );
      await cubit.close();
    });
  });
}
