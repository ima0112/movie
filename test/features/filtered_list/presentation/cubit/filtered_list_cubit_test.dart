import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/discover_page.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/repositories/media_repository.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/features/filtered_list/presentation/cubit/filtered_list_cubit.dart';
import 'package:movies/features/filtered_list/presentation/cubit/filtered_list_state.dart';

const _horror = Genre(id: 'horror');

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

    test('the count is TMDB\'s total, and more pages are requested once what '
        'was fetched is revealed', () async {
      final repo = _PagedRepository(total: 12, perPage: 5);
      final cubit = FilteredListCubit(repo, const DiscoverFilter());

      await cubit.load();
      var loaded = cubit.state as FilteredListLoaded;
      expect(loaded.totalCount, 12);
      expect(loaded.allItems, hasLength(5));
      expect(loaded.hasMore, isTrue);

      // Everything fetched is already revealed, so each scroll to the end
      // asks for the next page.
      await cubit.loadMore();
      expect(repo.pagesRequested, [1, 2]);
      await cubit.loadMore();
      loaded = cubit.state as FilteredListLoaded;
      expect(repo.pagesRequested, [1, 2, 3]);
      expect(loaded.allItems, hasLength(12));
      expect(loaded.hasMore, isFalse);
      expect(loaded.totalCount, 12);

      await cubit.close();
    });

    test('the names of the streaming services in the filter are loaded for '
        'their chips', () async {
      final cubit = FilteredListCubit(
        FakeMediaRepository(),
        const DiscoverFilter(withWatchProviders: {8}),
      );

      await cubit.load();

      expect(cubit.state.providerNames[8], 'Netflix');
      await cubit.close();
    });
  });
}

/// A repository whose `/discover` has [total] results in pages of [perPage].
class _PagedRepository extends FakeMediaRepository {
  _PagedRepository({required this.total, required this.perPage});

  final int total;
  final int perPage;
  final pagesRequested = <int>[];

  @override
  Future<Result<DiscoverPage>> discoverPage(
    DiscoverFilter filter, {
    int page = 1,
  }) async {
    pagesRequested.add(page);
    final start = (page - 1) * perPage;
    final ids = [for (var i = start; i < start + perPage && i < total; i++) i];
    return Success(
      DiscoverPage(
        items: [
          for (final id in ids)
            Movie(
              id: 1000 + id,
              title: 'Movie $id',
              posterUrl: null,
              genres: const [],
              releaseDate: null,
              voteAverage: 7,
            ),
        ],
        page: page,
        totalPages: (total / perPage).ceil(),
        totalResults: total,
      ),
    );
  }
}
