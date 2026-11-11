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

/// Title [id] with figures that don't follow the id, so each order differs
/// from the section's own.
Movie _movie(int id) => Movie(
  id: id,
  title: 'Movie $id',
  posterUrl: null,
  genres: const [],
  releaseDate: DateTime(2000).add(Duration(days: (id * 53) % 400)),
  voteAverage: 5 + (id * 7) % 40 / 10,
  voteCount: 100 + (id * 31) % 900,
  popularity: ((id * 17) % 97).toDouble(),
);

/// Serves [totalPages] pages of [perPage] titles (like TMDB's 20), and
/// records requests.
class _Repo extends FakeMediaRepository {
  int totalPages = 30;
  static const perPage = 20;
  final filters = <DiscoverFilter>[];
  final collectionCalls = <int>[];
  final pagesRequested = <int>[];
  Completer<void>? gate;
  Set<int> failPages = {};

  /// The id a page starts at (to make pages overlap).
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
    collectionCalls.add(page);
    return _page(page);
  }
}

final _today = DateTime(2026, 5, 4);
final _plain = FilterListing(const DiscoverFilter(), today: _today);

SectionListingCubit _cubit(_Repo repo, ListingSource source) {
  final cubit = SectionListingCubit(repo, source);
  addTearDown(cubit.close);
  return cubit;
}

SectionListingLoaded _loaded(SectionListingCubit c) =>
    c.state as SectionListingLoaded;

List<int> _ids(SectionListingCubit c) => [
  for (final m in _loaded(c).items) m.id,
];

void main() {
  test(
    'opens on page 1 in the section\'s own order with one request',
    () async {
      final repo = _Repo();
      final cubit = _cubit(repo, _plain);
      await cubit.load();

      final s = _loaded(cubit);
      expect(s.sort, ListingSort.byDefault);
      expect(_ids(cubit), List.generate(20, (i) => i + 1));
      expect(s.hasMore, isTrue);
      expect(repo.pagesRequested, [1]);
    },
  );

  test('loadMore appends pages and stops at the 100-title cap', () async {
    final repo = _Repo();
    final cubit = _cubit(repo, _plain);
    await cubit.load();
    for (var i = 0; i < 10; i++) {
      await cubit.loadMore();
    }

    final s = _loaded(cubit);
    expect(s.items, hasLength(100));
    expect(_ids(cubit), List.generate(100, (i) => i + 1));
    expect(s.hasMore, isFalse);
    expect(repo.pagesRequested, [1, 2, 3, 4, 5]); // never a sixth
  });

  test('a short list ends at its last page, whatever the cap', () async {
    final repo = _Repo()..totalPages = 2;
    final cubit = _cubit(repo, _plain);
    await cubit.load();
    await cubit.loadMore();

    final s = _loaded(cubit);
    expect(s.items, hasLength(40));
    expect(s.hasMore, isFalse);
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
    expect(_loaded(cubit).items, hasLength(40));
  });

  test('titles already shown are not repeated; a page of only repeats moves '
      'on to the next', () async {
    final repo = _Repo()
      // Page 2 repeats page 1 entirely; page 3 overlaps page 1 by one title.
      ..firstId = (page) => switch (page) {
        1 || 2 => 1,
        3 => 20,
        _ => (page - 1) * 20 + 1,
      };
    final cubit = _cubit(repo, _plain);
    await cubit.load();
    await cubit.loadMore();

    final ids = _ids(cubit);
    expect(ids.toSet(), hasLength(ids.length));
    expect(ids, List.generate(39, (i) => i + 1)); // page 3 added 21..39
    expect(repo.pagesRequested, [1, 2, 3]);
  });

  test('a failed next page keeps what is shown and can be retried', () async {
    final repo = _Repo()..failPages = {2};
    final cubit = _cubit(repo, _plain);
    await cubit.load();

    await cubit.loadMore();
    var s = _loaded(cubit);
    expect(s.moreFailed, isTrue);
    expect(s.items, hasLength(20));
    expect(s.loadingMore, isFalse);

    repo.failPages = {};
    await cubit.retryMore();
    s = _loaded(cubit);
    expect(s.moreFailed, isFalse);
    expect(s.items, hasLength(40));
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

  group('re-sorting reorders the same list', () {
    Future<SectionListingCubit> opened(_Repo repo) async {
      final cubit = _cubit(repo, _plain);
      await cubit.load();
      await cubit.loadMore(); // two pages in; the rest is still to come
      return cubit;
    }

    test('another order completes the set to 100, in parallel, and keeps '
        'exactly the titles of the section\'s own list', () async {
      final repo = _Repo();
      final cubit = await opened(repo);
      final own = _ids(cubit);
      repo.pagesRequested.clear();

      await cubit.setSort(ListingSort.popularity);

      final s = _loaded(cubit);
      expect(s.sort, ListingSort.popularity);
      expect(s.items, hasLength(100));
      expect(s.hasMore, isFalse); // the whole set is here: no pagination
      expect(repo.pagesRequested, [3, 4, 5]); // just what was missing
      // The same hundred titles the own order reaches — only reordered.
      await cubit.setSort(ListingSort.byDefault);
      expect(_ids(cubit).take(own.length), own);
      expect(_ids(cubit).toSet(), hasLength(100));
    });

    test('each order sorts the set by its own figure, ties broken by votes '
        '(rating) or the section\'s order', () async {
      final repo = _Repo();
      final cubit = await opened(repo);
      await cubit.setSort(ListingSort.popularity);
      final set = {for (final m in _loaded(cubit).items) m.id: m};

      void expectOrder(
        ListingSort sort,
        num Function(MediaItem) figure, {
        bool asc = false,
      }) {
        final items = _loaded(cubit).items;
        for (var i = 1; i < items.length; i++) {
          final a = figure(items[i - 1]);
          final b = figure(items[i]);
          expect(asc ? a <= b : a >= b, isTrue, reason: '$sort at $i');
          if (a == b) {
            if (sort == ListingSort.rating) {
              // Equal ratings: the one with more votes first.
              expect(
                items[i - 1].voteCount!,
                greaterThanOrEqualTo(items[i].voteCount!),
                reason: 'rating tie',
              );
            } else {
              // Any other tie keeps the section's own order.
              expect(
                items[i - 1].id,
                lessThan(items[i].id),
                reason: '$sort tie',
              );
            }
          }
        }
        expect(items.map((m) => m.id).toSet(), set.keys.toSet());
      }

      expectOrder(ListingSort.popularity, (m) => m.popularity!);
      await cubit.setSort(ListingSort.mostVoted);
      expectOrder(ListingSort.mostVoted, (m) => m.voteCount!);
      await cubit.setSort(ListingSort.rating);
      expectOrder(ListingSort.rating, (m) => m.voteAverage);
      await cubit.setSort(ListingSort.newest);
      expectOrder(
        ListingSort.newest,
        (m) => m.releaseDate!.millisecondsSinceEpoch,
      );
    });

    test('once the set is in, changing order costs no request', () async {
      final repo = _Repo();
      final cubit = await opened(repo);
      await cubit.setSort(ListingSort.rating);
      final requests = repo.pagesRequested.length;

      await cubit.setSort(ListingSort.mostVoted);
      await cubit.setSort(ListingSort.byDefault);
      await cubit.setSort(ListingSort.newest);

      expect(repo.pagesRequested, hasLength(requests));
    });

    test('back to the section\'s own order after completing it: the whole '
        'list, no further pagination', () async {
      final repo = _Repo();
      final cubit = await opened(repo);
      await cubit.setSort(ListingSort.rating);
      await cubit.setSort(ListingSort.byDefault);

      final s = _loaded(cubit);
      expect(s.items, hasLength(100));
      expect(s.hasMore, isFalse);
      expect(_ids(cubit), List.generate(100, (i) => i + 1));
    });

    test('the section\'s filter is never touched by a re-sort', () async {
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

      expect(repo.filters.toSet(), hasLength(1)); // every request the same
      expect(repo.filters.first.sortBy, DiscoverSortBy.popularity); // its own
    });

    test('a short list needs only its remaining pages', () async {
      final repo = _Repo()..totalPages = 3;
      final cubit = _cubit(repo, _plain);
      await cubit.load();
      repo.pagesRequested.clear();

      await cubit.setSort(ListingSort.rating);

      expect(repo.pagesRequested, [2, 3]);
      expect(_loaded(cubit).items, hasLength(60));
    });

    test('a failure while completing the set is an error that retry '
        'recovers from', () async {
      final repo = _Repo()..failPages = {4};
      final cubit = await opened(repo);

      await cubit.setSort(ListingSort.rating);
      expect(cubit.state, isA<SectionListingError>());
      expect(cubit.state.sort, ListingSort.rating);

      repo.failPages = {};
      await cubit.retry();
      expect(_loaded(cubit).sort, ListingSort.rating);
      expect(_loaded(cubit).items, hasLength(100));
    });

    test('a slow page from before a re-sort cannot overwrite it', () async {
      final repo = _Repo();
      final cubit = _cubit(repo, _plain);
      await cubit.load();

      final gate = Completer<void>();
      repo.gate = gate;
      final slow = cubit.loadMore(); // page 2 of the own order, stalled
      await pumpEventQueue();
      repo.gate = null;
      await cubit.setSort(ListingSort.popularity);
      gate.complete();
      await slow;

      expect(_loaded(cubit).sort, ListingSort.popularity);
      expect(_loaded(cubit).items, hasLength(100));
    });

    test('pull to refresh drops the pool and asks again', () async {
      final repo = _Repo();
      final cubit = await opened(repo);
      await cubit.setSort(ListingSort.rating);
      repo.pagesRequested.clear();

      await cubit.refresh();

      expect(repo.pagesRequested.first, 1); // starts over
      expect(_loaded(cubit).sort, ListingSort.rating); // in the same order
      expect(_loaded(cubit).items, hasLength(100));
    });

    test('unreleased windows offer no Rating or Most voted, and a sort the '
        'listing does not offer is ignored', () async {
      final repo = _Repo();
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

    test(
      'every page — and every order — comes from its own endpoint',
      () async {
        final repo = _Repo();
        final cubit = _cubit(repo, source);
        await cubit.load();
        await cubit.loadMore();
        await cubit.setSort(ListingSort.rating);

        expect(repo.filters, isEmpty); // never a different (approximate) query
        expect(repo.collectionCalls, [1, 2, 3, 4, 5]);
        expect(_loaded(cubit).items, hasLength(100));
      },
    );

    test('Coming soon offers only the sorts that make sense', () {
      const soon = CollectionListing(CarouselSection.comingSoon, type: null);
      expect(soon.sorts, hasLength(3));
    });
  });
}
