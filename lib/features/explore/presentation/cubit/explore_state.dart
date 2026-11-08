import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/domain/entities/result.dart';

/// B2 (Explore)'s three states — `docs/SCREENS.md` B2: "State 1 — At
/// rest... State 2 — Typing... State 3 — Listing (see C1)."
///
/// Split out of `explore_cubit.dart` per CLAUDE.md rule 11.
sealed class ExploreState {
  const ExploreState({required this.segment});

  /// The segmented control's own selection — common to all three states
  /// (`docs/SCREENS.md` B2: "Common elements:... segmented All | Movies
  /// | TV Shows").
  final MediaSegment segment;
}

/// State 1 — the search field is empty: B2's "Recent" chips (up to the
/// last 10, most-recent-first) and its genre tiles.
///
/// [recentSearches] only — B2's genre tiles ("2-column tiles... backdrop
/// of the genre's most popular title") need a "most popular title per
/// genre" data source that doesn't exist anywhere yet, the same shape
/// gap `MyTastesCubit`'s own doc comment already flagged for a genre
/// catalog; out of this Cubit's own debounce/search-state scope, left
/// for whoever builds B2's actual genre-tile widget.
final class ExploreAtRest extends ExploreState {
  const ExploreAtRest({required super.segment, this.recentSearches = const []});

  final List<String> recentSearches;
}

/// State 2 — the field has text. [query] is the *live* text (updates on
/// every keystroke, before the 400 ms debounce fires) so the field
/// itself never lags behind typing; only [ExploreSearchLoaded]'s
/// [ExploreSearchLoaded.results] wait for the debounced search to
/// actually resolve.
sealed class ExploreSearching extends ExploreState {
  const ExploreSearching({required super.segment, required this.query});

  final String query;
}

/// The debounce has fired and `MediaRepository.searchMulti` is running.
final class ExploreSearchLoading extends ExploreSearching {
  const ExploreSearchLoading({required super.segment, required super.query});
}

/// `/search/multi` results for [query] — B2: "the segment filters
/// client-side" (All shows everything; Movies/TV Shows hide people),
/// which is why [results] holds the *unfiltered* set: applying the
/// segment is a presentation-layer concern over this same list, not a
/// second network call or a re-emitted state.
final class ExploreSearchLoaded extends ExploreSearching {
  const ExploreSearchLoaded({
    required super.segment,
    required super.query,
    required this.results,
  });

  final List<MediaItem> results;
}

/// The search itself failed (not "no results" — an empty [Success] list
/// is still [ExploreSearchLoaded], just with an empty [ExploreSearchLoaded.results]).
final class ExploreSearchError extends ExploreSearching {
  const ExploreSearchError({
    required super.segment,
    required super.query,
    required this.reason,
  });

  final FailureReason reason;
}

/// State 3 — B2 itself renders nothing for this: it's the signal to
/// push C1 ("State 3 — Listing (see C1)"), carrying whatever filter got
/// the user there (a genre tile, "See N results" from H8, "See all").
/// C1's own paginated results belong entirely to `FilteredListCubit`,
/// constructed once C1 is actually pushed — this state only exists so
/// the screen can react to "go to C1 now" (e.g. via a `BlocListener`).
final class ExploreListing extends ExploreState {
  const ExploreListing({
    required super.segment,
    required this.filter,
    required this.title,
  });

  final DiscoverFilter filter;

  /// C1's own top-bar title — e.g. the genre name, or "Results" for H8's
  /// "See N results" (`docs/SCREENS.md` C1: "title ('In theaters' /
  /// 'Horror' / 'Results')").
  final String title;
}
