import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/discover_page.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/repositories/media_repository.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/features/section_listing/domain/listing_source.dart';
import 'package:movies/features/section_listing/presentation/cubit/section_listing_cubit.dart';
import 'package:movies/features/section_listing/presentation/cubit/section_listing_state.dart';

Movie _movie(int id) => Movie(
  id: id,
  title: 'Movie $id',
  posterUrl: null,
  genres: const [],
  releaseDate: null,
  voteAverage: 7,
);

/// Serves [totalPages] pages of [perPage] titles each, and records requests.
class _Repo extends FakeMediaRepository {
  int totalPages = 3;
  static const perPage = 4;
  final filters = <DiscoverFilter>[];
  final collectionCalls = <(CarouselSection, int)>[];
  final pagesRequested = <int>[];
  Completer<void>? gate;
  Set<int> failPages = {};

  /// Ids a page repeats from the one before (to test de-duplication).
  int Function(int page) firstId = (page) => (page - 1) * perPage + 1;

  Future<Result<DiscoverPage>> _page(int page) async {
    pagesRequested.add(page);
    final g = gate;
    if (g != null) await g.future;
    if (failPages.contains(page)) return Failure(FailureReason.network);
    final start = firstId(page);
    return Success(
      DiscoverPage(
        items: [for (var i = 0; i < perPage; i++) _movie(start + i)],
        page: page,
        totalPages: totalPages,
        totalResults: totalPages * perPage,
      ),
    );
  }

  @override
  Future<Result<DiscoverPage>> discoverPage(
    DiscoverFilter filter, {
    int page = 1,
  }) {
    filters.add(filter);
    return _page(page);
  }

  @override
  Future<Result<DiscoverPage>> carouselSectionPage(
    CarouselSection section, {
    MediaType? type,
    int page = 1,
  }) {
    collectionCalls.add((section, page));
    return _page(page);
  }
}

final _today = DateTime(2026, 5, 4);

SectionListingCubit _cubit(_Repo repo, ListingSource source) {
  final cubit = SectionListingCubit(repo, source, clock: () => _today);
  addTearDown(cubit.close);
  return cubit;
}

final _plain = FilterListing(const DiscoverFilter(), today: _today);

SectionListingLoaded _loaded(SectionListingCubit c) =>
    c.state as SectionListingLoaded;

void main() {
  test('opens on page 1 in the default order', () async {
    final repo = _Repo();
    final cubit = _cubit(repo, _plain);
    await cubit.load();

    final s = _loaded(cubit);
    expect(s.sort, ListingSort.byDefault);
    expect(s.items.map((m) => m.id), [1, 2, 3, 4]);
    expect(s.totalResults, 12);
    expect(s.hasMore, isTrue);
    expect(repo.filters.single.sortBy, DiscoverSortBy.popularity);
  });

  test('loadMore appends the next page and stops at the last one', () async {
    final repo = _Repo();
    final cubit = _cubit(repo, _plain);
    await cubit.load();

    await cubit.loadMore();
    expect(_loaded(cubit).items, hasLength(8));
    await cubit.loadMore();
    expect(_loaded(cubit).items, hasLength(12));
    expect(_loaded(cubit).hasMore, isFalse);

    await cubit.loadMore(); // nothing left
    expect(repo.pagesRequested, [1, 2, 3]);
  });

  test('loadMore is idempotent while a page is in flight', () async {
    final repo = _Repo();
    final cubit = _cubit(repo, _plain);
    await cubit.load();

    repo.gate = Completer();
    final first = cubit.loadMore();
    final second = cubit.loadMore();
    await pumpEventQueue();
    expect(_loaded(cubit).loadingMore, isTrue);
    repo.gate!.complete();
    await Future.wait([first, second]);

    expect(repo.pagesRequested, [1, 2]); // one request for page 2
    expect(_loaded(cubit).items, hasLength(8));
  });

  test('titles already shown are not repeated; a page of only repeats '
      'moves on to the next', () async {
    final repo = _Repo()
      ..totalPages = 4
      // Page 2 repeats page 1 entirely; page 3 overlaps page 1 by one title.
      ..firstId = (page) => switch (page) {
        1 || 2 => 1,
        3 => 4,
        _ => 100 * page,
      };
    final cubit = _cubit(repo, _plain);
    await cubit.load();
    await cubit.loadMore();

    final ids = _loaded(cubit).items.map((m) => m.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
    expect(ids, [1, 2, 3, 4, 5, 6, 7]); // page 3 added 5, 6, 7
    expect(repo.pagesRequested, [1, 2, 3]);
  });

  test('a failed next page keeps what is shown and can be retried', () async {
    final repo = _Repo()..failPages = {2};
    final cubit = _cubit(repo, _plain);
    await cubit.load();

    await cubit.loadMore();
    var s = _loaded(cubit);
    expect(s.moreFailed, isTrue);
    expect(s.items, hasLength(4));
    expect(s.loadingMore, isFalse);

    repo.failPages = {};
    await cubit.retryMore();
    s = _loaded(cubit);
    expect(s.moreFailed, isFalse);
    expect(s.items, hasLength(8));
  });

  test('a failed first page is an error that retry recovers from', () async {
    final repo = _Repo()..failPages = {1};
    final cubit = _cubit(repo, _plain);
    await cubit.load();
    expect(cubit.state, isA<SectionListingError>());

    repo.failPages = {};
    await cubit.retry();
    expect(cubit.state, isA<SectionListingLoaded>());
  });

  group('sorting', () {
    test('re-sorting reloads from page 1 with that sort', () async {
      final repo = _Repo();
      final cubit = _cubit(repo, _plain);
      await cubit.load();
      await cubit.loadMore();

      await cubit.setSort(ListingSort.newest);

      final s = _loaded(cubit);
      expect(s.sort, ListingSort.newest);
      expect(s.items, hasLength(4)); // started again
      expect(repo.filters.last.sortBy, DiscoverSortBy.releaseDate);
      await cubit.loadMore(); // and keeps that sort for later pages
      expect(repo.filters.last.sortBy, DiscoverSortBy.releaseDate);
    });

    test('the same sort again does nothing', () async {
      final repo = _Repo();
      final cubit = _cubit(repo, _plain);
      await cubit.load();
      final calls = repo.pagesRequested.length;
      await cubit.setSort(ListingSort.byDefault);
      expect(repo.pagesRequested, hasLength(calls));
    });

    test('Rating keeps the section\'s own vote floor but never below '
        '${SectionListingCubit.ratingMinVotes}', () async {
      final repo = _Repo();
      final soon = FilterListing(
        const DiscoverFilter(minVoteCount: 0),
        today: _today,
      );
      final cubit = _cubit(repo, soon);
      await cubit.load();
      await cubit.setSort(ListingSort.rating);
      expect(
        repo.filters.last.minVoteCount,
        SectionListingCubit.ratingMinVotes,
      );

      final strict = _cubit(
        repo,
        FilterListing(const DiscoverFilter(minVoteCount: 1000), today: _today),
      );
      await strict.load();
      await strict.setSort(ListingSort.rating);
      expect(repo.filters.last.minVoteCount, 1000);
    });

    test('the rest of the section\'s filter survives a re-sort', () async {
      final repo = _Repo();
      final window = FilterListing(
        DiscoverFilter(
          type: MediaType.movie,
          withWatchProviders: const {8},
          maxVoteCount: 1500,
          releasedFrom: DateTime(2026, 1, 1),
        ),
        today: _today,
      );
      final cubit = _cubit(repo, window);
      await cubit.load();
      await cubit.setSort(ListingSort.mostVoted);

      final f = repo.filters.last;
      expect(f.sortBy, DiscoverSortBy.voteCount);
      expect(f.type, MediaType.movie);
      expect(f.withWatchProviders, {8});
      expect(f.maxVoteCount, 1500);
      expect(f.releasedFrom, DateTime(2026, 1, 1));
    });

    test(
      'a slow page from the old sort cannot overwrite the new one',
      () async {
        final repo = _Repo();
        final cubit = _cubit(repo, _plain);
        await cubit.load();

        final gate = Completer<void>();
        repo.gate = gate;
        final slow = cubit.loadMore(); // page 2 of the default order, stalled
        await pumpEventQueue();
        repo.gate = null;
        await cubit.setSort(ListingSort.popularity);
        gate.complete();
        await slow;
        expect(_loaded(cubit).sort, ListingSort.popularity);
        expect(_loaded(cubit).items, hasLength(4));
      },
    );

    test('unreleased windows offer no Rating or Most voted', () {
      final soon = FilterListing(
        DiscoverFilter(releasedFrom: DateTime(2026, 5, 5)),
        today: _today,
      );
      expect(soon.sorts, [
        ListingSort.byDefault,
        ListingSort.popularity,
        ListingSort.newest,
      ]);
      expect(_plain.sorts, ListingSort.values);
    });

    test('a sort the listing does not offer is ignored', () async {
      final repo = _Repo();
      final soon = FilterListing(
        DiscoverFilter(releasedFrom: DateTime(2026, 5, 5)),
        today: _today,
      );
      final cubit = _cubit(repo, soon);
      await cubit.load();
      await cubit.setSort(ListingSort.rating);
      expect(_loaded(cubit).sort, ListingSort.byDefault);
    });
  });

  group('a Home collection', () {
    const source = CollectionListing(
      CarouselSection.inTheaters,
      type: MediaType.movie,
    );

    test('opens with its own endpoint, in its own order', () async {
      final repo = _Repo();
      final cubit = _cubit(repo, source);
      await cubit.load();
      await cubit.loadMore();

      expect(repo.collectionCalls, [
        (CarouselSection.inTheaters, 1),
        (CarouselSection.inTheaters, 2),
      ]);
      expect(repo.filters, isEmpty);
    });

    test('another sort switches to the equivalent /discover', () async {
      final repo = _Repo();
      final cubit = _cubit(repo, source);
      await cubit.load();
      await cubit.setSort(ListingSort.rating);

      final f = repo.filters.single;
      expect(f.type, MediaType.movie);
      expect(f.sortBy, DiscoverSortBy.rating);
      expect(f.releasedTo, _today); // "in theaters" = recently released
      // ...and back to the default returns to the collection endpoint.
      await cubit.setSort(ListingSort.byDefault);
      expect(repo.collectionCalls.last, (CarouselSection.inTheaters, 1));
    });

    test('Coming soon offers only the sorts that make sense', () {
      const soon = CollectionListing(CarouselSection.comingSoon, type: null);
      expect(soon.sorts, hasLength(3));
    });
  });
}
