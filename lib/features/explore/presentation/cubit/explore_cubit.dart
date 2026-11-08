import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/app_settings.dart';
import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/domain/repositories/settings_repository.dart';
import '../../domain/search_history_repository.dart';
import 'explore_state.dart';

/// B2 (Explore)'s state machine — `docs/SCREENS.md` B2. Owns the
/// search field's 400 ms debounce and the transitions between its three
/// states; screen-local (built where B2's own `BlocProvider` sits, per
/// CLAUDE.md rule 10 — nothing else needs to know what's being typed
/// into Explore's search field).
///
/// Subscribes to [SearchHistoryRepository] for State 1's "Recent" chips
/// and records every search that actually runs against it — the same
/// "read/write through the one real source, don't hold a competing
/// copy" discipline `MyTastesCubit` already applies to `TasteProfileCubit`.
///
/// No `Timer` cancellation race is left dangling: a monotonic
/// [_searchGeneration] counter, bumped on every new keystroke/recent-
/// chip tap, is checked before a debounced search's result is ever
/// emitted — a slow, superseded search response arriving after a newer
/// one can't overwrite it (the same class of bug a naive
/// "just emit whatever comes back" implementation would have).
///
/// Also subscribes to [SettingsRepository.watch] so a language/region
/// change (F11) re-runs whatever search is currently showing — never
/// the user's own still-being-typed text, and never when there's no
/// active search to repeat at all (State 1 "at rest", or State 3
/// "listing" has nothing to re-run here). Cancelled in [close], same
/// discipline as [_historySubscription].
class ExploreCubit extends Cubit<ExploreState> {
  ExploreCubit(
    this._mediaRepository,
    this._searchHistoryRepository,
    this._settingsRepository,
  ) : super(const ExploreAtRest(segment: MediaSegment.all)) {
    _historySubscription = _searchHistoryRepository.watch().listen(
      _onHistoryChanged,
    );
    _settingsSubscription = _settingsRepository
        .watch()
        .distinct()
        .skip(1)
        .listen(_onSettingsChanged);
  }

  final MediaRepository _mediaRepository;
  final SearchHistoryRepository _searchHistoryRepository;
  final SettingsRepository _settingsRepository;
  late final StreamSubscription<List<String>> _historySubscription;
  late final StreamSubscription<AppSettings> _settingsSubscription;
  Timer? _debounce;
  int _searchGeneration = 0;

  static const debounceDuration = Duration(milliseconds: 400);

  void _onHistoryChanged(List<String> history) {
    if (state case ExploreAtRest(:final segment)) {
      emit(ExploreAtRest(segment: segment, recentSearches: history));
    }
  }

  /// B2's segmented control. Only ever re-filters client-side (B2: "the
  /// segment filters client-side") — never re-queries, so this is a
  /// plain re-emit of whichever state is current with a new [segment].
  void selectSegment(MediaSegment segment) {
    switch (state) {
      case ExploreAtRest(:final recentSearches):
        emit(ExploreAtRest(segment: segment, recentSearches: recentSearches));
      case ExploreSearchLoading(:final query):
        emit(ExploreSearchLoading(segment: segment, query: query));
      case ExploreSearchLoaded(:final query, :final results):
        emit(
          ExploreSearchLoaded(segment: segment, query: query, results: results),
        );
      case ExploreSearchError(:final query, :final reason):
        emit(
          ExploreSearchError(segment: segment, query: query, reason: reason),
        );
      case ExploreListing(:final filter, :final title):
        emit(ExploreListing(segment: segment, filter: filter, title: title));
    }
  }

  /// Called on every keystroke. An empty [query] goes straight back to
  /// State 1 (B2's own "×" clears to this too — see [clearQuery]);
  /// anything else starts (or restarts) the 400 ms debounce.
  void onQueryChanged(String query) {
    final segment = state.segment;
    if (query.trim().isEmpty) {
      _debounce?.cancel();
      emit(ExploreAtRest(segment: segment));
      return;
    }

    emit(ExploreSearchLoading(segment: segment, query: query));
    _debounce?.cancel();
    final generation = ++_searchGeneration;
    _debounce = Timer(
      debounceDuration,
      () => unawaited(_runSearch(query, generation)),
    );
  }

  /// B2's "Recent" chip tap — "tap to run": no debounce wait, it runs
  /// immediately.
  void runRecentSearch(String query) {
    _debounce?.cancel();
    emit(ExploreSearchLoading(segment: state.segment, query: query));
    unawaited(_runSearch(query, ++_searchGeneration));
  }

  Future<void> _runSearch(String query, int generation) async {
    final result = await _mediaRepository.searchMulti(query);
    // Superseded by a newer keystroke/chip tap while this was in
    // flight — dropping it silently is correct, not a bug: the newer
    // search's own result (or lack of one yet) is what should be showing.
    if (generation != _searchGeneration || isClosed) return;

    switch (result) {
      case Success<List<MediaItem>>(:final value):
        unawaited(_searchHistoryRepository.record(query));
        emit(
          ExploreSearchLoaded(
            segment: state.segment,
            query: query,
            results: value,
          ),
        );
      case Failure<List<MediaItem>>(:final reason):
        emit(
          ExploreSearchError(
            segment: state.segment,
            query: query,
            reason: reason,
          ),
        );
    }
  }

  /// The field's "×" / "Cancel" — back to State 1.
  void clearQuery() {
    _debounce?.cancel();
    emit(ExploreAtRest(segment: state.segment));
  }

  /// A "Recent" chip's long-press. Fire-and-forget, same as [_runSearch]'s
  /// own [SearchHistoryRepository.record] call — [_onHistoryChanged]
  /// picks up the result via the repository's own stream, no need to
  /// await or emit anything here directly.
  void removeRecentSearch(String query) =>
      unawaited(_searchHistoryRepository.remove(query));

  /// "Clear all".
  void clearRecentSearches() => unawaited(_searchHistoryRepository.clear());

  /// A genre tile tap, "See N results" (H8), or "See all" — → C1.
  void openListing({required DiscoverFilter filter, required String title}) {
    _debounce?.cancel();
    emit(ExploreListing(segment: state.segment, filter: filter, title: title));
  }

  /// Repeats whatever search is currently showing — only when there is
  /// one ([ExploreSearching] covers Loading/Loaded/Error, all of which
  /// carry a [query]). [ExploreAtRest] (nothing typed) and
  /// [ExploreListing] (not a text query) are left alone, so this never
  /// touches what the user is actively typing.
  void _onSettingsChanged(AppSettings _) {
    if (isClosed) return;
    if (state case ExploreSearching(:final query)) {
      _debounce?.cancel();
      emit(ExploreSearchLoading(segment: state.segment, query: query));
      unawaited(_runSearch(query, ++_searchGeneration));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    unawaited(_historySubscription.cancel());
    unawaited(_settingsSubscription.cancel());
    return super.close();
  }
}
