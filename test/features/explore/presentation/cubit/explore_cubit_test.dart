import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_segment.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';
import 'package:movies/features/explore/domain/search_history_repository.dart';
import 'package:movies/features/explore/presentation/cubit/explore_cubit.dart';
import 'package:movies/features/explore/presentation/cubit/explore_state.dart';

/// `FakeMediaRepository`'s own internal delay (private to that file) —
/// mirrored here so a full round trip's elapse amount is documented
/// rather than a bare magic number: debounce (400ms) + this.
const _fakeRepositoryDelay = Duration(milliseconds: 400);
const _fullRoundTrip = Duration(
  milliseconds: 400 + 400,
); // ExploreCubit.debounceDuration + _fakeRepositoryDelay

/// In-memory stand-in for [SearchHistoryRepository] — same shape as
/// this session's other fake repositories (e.g.
/// `edit_profile_sheet_test.dart`'s `_InMemoryUserProfileRepository`).
class _InMemorySearchHistoryRepository implements SearchHistoryRepository {
  List<String> _history = [];
  final _controller = StreamController<List<String>>.broadcast();

  @override
  Stream<List<String>> watch() async* {
    yield _history;
    yield* _controller.stream;
  }

  @override
  Future<Result<void>> record(String query) async {
    _history = [query, ..._history.where((q) => q != query)].take(10).toList();
    _controller.add(_history);
    return const Success(null);
  }

  @override
  Future<Result<void>> remove(String query) async {
    _history = _history.where((q) => q != query).toList();
    _controller.add(_history);
    return const Success(null);
  }

  @override
  Future<Result<void>> clear() async {
    _history = [];
    _controller.add(_history);
    return const Success(null);
  }
}

void main() {
  group('ExploreCubit', () {
    test('starts in ExploreAtRest, segment All, no recent searches', () {
      final cubit = ExploreCubit(
        FakeMediaRepository(),
        _InMemorySearchHistoryRepository(),
      );

      final state = cubit.state;
      expect(state, isA<ExploreAtRest>());
      expect(state.segment, MediaSegment.all);
      expect((state as ExploreAtRest).recentSearches, isEmpty);

      cubit.close();
    });

    test('recent searches already saved show up in the initial state '
        'once the history stream emits', () async {
      final history = _InMemorySearchHistoryRepository();
      await history.record('dune');
      final cubit = ExploreCubit(FakeMediaRepository(), history);

      await Future<void>.delayed(Duration.zero);

      expect((cubit.state as ExploreAtRest).recentSearches, ['dune']);
      await cubit.close();
    });

    test('onQueryChanged emits Loading immediately, before the debounce '
        'fires', () {
      fakeAsync((async) {
        final cubit = ExploreCubit(
          FakeMediaRepository(),
          _InMemorySearchHistoryRepository(),
        );

        cubit.onQueryChanged('dune');

        expect(cubit.state, isA<ExploreSearchLoading>());
        expect((cubit.state as ExploreSearchLoading).query, 'dune');

        cubit.close();
      });
    });

    test('a keystroke does not even start searching until 400ms of '
        'silence pass', () {
      fakeAsync((async) {
        final cubit = ExploreCubit(
          FakeMediaRepository(),
          _InMemorySearchHistoryRepository(),
        );

        cubit.onQueryChanged('d');
        async.elapse(const Duration(milliseconds: 399));
        // The debounce hasn't fired yet — still Loading, not Loaded.
        expect(cubit.state, isA<ExploreSearchLoading>());

        // Past the debounce, but the fake repository's own network
        // delay hasn't resolved yet either.
        async.elapse(const Duration(milliseconds: 2));
        expect(cubit.state, isA<ExploreSearchLoading>());

        // The rest of the fake network delay elapses.
        async.elapse(_fakeRepositoryDelay);
        expect(cubit.state, isA<ExploreSearchLoaded>());

        cubit.close();
      });
    });

    test('rapid-fire keystrokes only search once, for the final text', () {
      fakeAsync((async) {
        final cubit = ExploreCubit(
          FakeMediaRepository(),
          _InMemorySearchHistoryRepository(),
        );

        cubit.onQueryChanged('d');
        async.elapse(const Duration(milliseconds: 100));
        cubit.onQueryChanged('du');
        async.elapse(const Duration(milliseconds: 100));
        cubit.onQueryChanged('dune');
        // Only 400ms of silence after the *last* keystroke should even
        // start a search.
        async.elapse(const Duration(milliseconds: 399));
        expect(cubit.state, isA<ExploreSearchLoading>());

        async.elapse(const Duration(milliseconds: 1) + _fakeRepositoryDelay);
        final loaded = cubit.state as ExploreSearchLoaded;
        expect(loaded.query, 'dune');
        expect(loaded.results.map((i) => i.title), ['Dune: Part Two']);

        cubit.close();
      });
    });

    test('a superseded search response never overwrites a newer one', () {
      fakeAsync((async) {
        final cubit = ExploreCubit(
          FakeMediaRepository(),
          _InMemorySearchHistoryRepository(),
        );

        // First search settles (debounce + fake network delay)...
        cubit.onQueryChanged('dune');
        async.elapse(_fullRoundTrip);
        expect((cubit.state as ExploreSearchLoaded).query, 'dune');

        // ...then a second one runs to completion too — the point is
        // *what shows once everything resolves* is always the latest
        // query, never a stale one racing back late.
        cubit.onQueryChanged('oppenheimer');
        async.elapse(_fullRoundTrip);

        expect((cubit.state as ExploreSearchLoaded).query, 'oppenheimer');

        cubit.close();
      });
    });

    test('clearing the query (empty string) skips the debounce entirely '
        'and returns to ExploreAtRest', () {
      fakeAsync((async) {
        final cubit = ExploreCubit(
          FakeMediaRepository(),
          _InMemorySearchHistoryRepository(),
        );
        cubit.onQueryChanged('dune');

        cubit.onQueryChanged('');

        expect(cubit.state, isA<ExploreAtRest>());
        async.elapse(_fullRoundTrip);
        // Still at rest — the pending debounce/search for 'dune' was
        // canceled outright, not just superseded by an empty query.
        expect(cubit.state, isA<ExploreAtRest>());

        cubit.close();
      });
    });

    test('clearQuery() returns to ExploreAtRest and cancels any pending '
        'debounce', () {
      fakeAsync((async) {
        final cubit = ExploreCubit(
          FakeMediaRepository(),
          _InMemorySearchHistoryRepository(),
        );
        cubit.onQueryChanged('dune');

        cubit.clearQuery();
        async.elapse(_fullRoundTrip);

        expect(cubit.state, isA<ExploreAtRest>());

        cubit.close();
      });
    });

    test('runRecentSearch() runs immediately, no debounce wait', () {
      fakeAsync((async) {
        final cubit = ExploreCubit(
          FakeMediaRepository(),
          _InMemorySearchHistoryRepository(),
        );

        cubit.runRecentSearch('dune');
        // Only the fake repository's own network delay, no 400ms
        // debounce on top of it.
        async.elapse(_fakeRepositoryDelay + const Duration(milliseconds: 1));

        expect((cubit.state as ExploreSearchLoaded).query, 'dune');

        cubit.close();
      });
    });

    test('a successful search is recorded to search history', () {
      fakeAsync((async) {
        final history = _InMemorySearchHistoryRepository();
        final cubit = ExploreCubit(FakeMediaRepository(), history);

        cubit.onQueryChanged('dune');
        async.elapse(_fullRoundTrip);

        expect(history._history, contains('dune'));
        cubit.close();
      });
    });

    test('selectSegment updates the segment without touching search '
        'results', () {
      fakeAsync((async) {
        final cubit = ExploreCubit(
          FakeMediaRepository(),
          _InMemorySearchHistoryRepository(),
        );
        cubit.onQueryChanged('dune');
        async.elapse(_fullRoundTrip);
        final resultsBefore = (cubit.state as ExploreSearchLoaded).results;

        cubit.selectSegment(MediaSegment.movie);

        final after = cubit.state as ExploreSearchLoaded;
        expect(after.segment, MediaSegment.movie);
        expect(after.query, 'dune');
        expect(after.results, resultsBefore);

        cubit.close();
      });
    });
  });
}
