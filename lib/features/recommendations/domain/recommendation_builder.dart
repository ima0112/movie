import '../../../core/domain/entities/discover_filter.dart';
import '../../../core/domain/entities/genre.dart';
import '../../../core/domain/entities/media_item.dart';
import '../../../core/domain/entities/media_key.dart';
import '../../../core/domain/entities/media_type.dart';
import '../../../core/domain/entities/taste_profile.dart';
import '../../../core/domain/entities/user_media_entry.dart';
import '../../match_engine/domain/vibe_catalog.dart';

/// Builds B1's "For you" and "Because you like X" carousels —
/// `docs/DECISIONS.md` section 5/F1b. Pure domain: no Flutter, no
/// network — every method here only ever produces a [DiscoverFilter], a
/// seed [UserMediaEntry], or filters an already-fetched [MediaItem]
/// list. The actual TMDB calls (`MediaRepository.discover`/
/// `.recommendationsFor`) are the caller's job (`RecommendationsCubit`),
/// specifically so the derived request (filter/seed) can be compared
/// against what was last fetched and skip a redundant network call when
/// the underlying signal hasn't actually changed — see that Cubit's own
/// doc comment.
///
/// Deliberately does **not** reuse `MatchEngine`'s scoring/relaxation
/// machinery: that's built for resolving one best answer for N≥1
/// participants, with per-vibe satisfaction tracking. A B1 carousel is
/// just "rank by popularity," so pulling in the whole engine would be
/// duplicated complexity, not reuse. What it *does* share, so the
/// genre/keyword resolution itself isn't duplicated a second time:
/// [Vibe.genresFor]/[Vibe.keywordIdsFor] (the same mapping
/// `MatchEngineImpl._filterForVibe` uses) and [genreAffinityFrom] (the
/// same library-signal ranking `TasteProfileBuilder` uses for its own
/// inferred-profile case).
class RecommendationBuilder {
  const RecommendationBuilder(this.vibeCatalog);

  final VibeCatalog vibeCatalog;

  /// Below this many results (after excluding posterless items and
  /// anything already in the library), a section doesn't show at all —
  /// `docs/DECISIONS.md` F1b: a carousel with 2-3 items reads as broken,
  /// not curated. Applies to both sections (the design brief named it
  /// for "Because you like X" specifically, for `/recommendations`'
  /// thinner, title-dependent pool; it's applied the same way to "For
  /// you" for the same reason — a very short carousel looks the same
  /// regardless of which call produced it).
  static const int minRecommendationCount = 6;

  /// "For you": a [DiscoverFilter] built from [profile] if it's
  /// [TasteProfile.isUsableForSuggestions], else from [libraryEntries]'
  /// own signal (positive-affinity genres among favorites/well-rated
  /// watches — [genreAffinityFrom], the same ranking
  /// `TasteProfileBuilder`'s inferred-profile case uses). `null` means
  /// "no signal at all, don't show the section" — never an empty
  /// carousel or a generic one with no real basis.
  ///
  /// [type] is B1's own segment filter (`null` = "All" — passed straight
  /// through to [DiscoverFilter.type], which `MediaRepository.discover`
  /// already interleaves movie+tv for on its own, the same way
  /// `TmdbMediaRepository._allSegmentHero`/`.discover(type: null)`
  /// already does — no special-casing needed here for "All").
  ///
  /// Vetoed genres become [DiscoverFilter.withoutGenres] — explicit
  /// vetoes always win, same rule `TasteProfileBuilder` already follows.
  /// "Ya vistos o guardados" isn't representable as a `/discover`
  /// parameter at all (TMDB has none); [excludeLibraryItems] is the
  /// client-side half of that exclusion, applied by the caller to
  /// whatever `discover()` returns.
  DiscoverFilter? forYouFilter({
    required TasteProfile? profile,
    required List<UserMediaEntry> libraryEntries,
    required MediaType? type,
  }) {
    final Set<Genre> likedGenres;
    final Set<Genre> vetoedGenres;
    final Set<int> keywordIds;

    if (profile != null && profile.isUsableForSuggestions) {
      final vibes = profile.likedVibes
          .map(vibeCatalog.byId)
          .nonNulls
          .where((v) => type == null || v.isMeaningfulFor(type));
      likedGenres = {
        ...profile.likedGenres,
        for (final vibe in vibes) ...vibe.genresFor(type ?? MediaType.movie),
      };
      keywordIds = {
        for (final vibe in vibes) ...vibe.keywordIdsFor(type ?? MediaType.movie),
      };
      vetoedGenres = profile.vetoedGenres;
    } else {
      final affinity = genreAffinityFrom(libraryEntries);
      likedGenres = {
        for (final entry in affinity.entries)
          if (entry.value > 0) entry.key,
      };
      keywordIds = const {};
      vetoedGenres = const {};
    }

    if (likedGenres.isEmpty && keywordIds.isEmpty) return null;

    return DiscoverFilter(
      type: type,
      withGenres: likedGenres,
      withoutGenres: vetoedGenres,
      withKeywords: keywordIds,
      sortBy: DiscoverSortBy.popularity,
    );
  }

  /// "Because you like X"'s seed: the library entry most worth basing a
  /// recommendation on — favorite or rated ≥4, ranked by rating
  /// (favorites with no rating count as a 5), most-recently-watched
  /// first, [MediaKey.tmdbId] as a final, fully deterministic tiebreak.
  /// No randomness anywhere in this — `docs/DECISIONS.md` F1b's own
  /// "deterministic, documented" requirement.
  ///
  /// [type] filters candidates to B1's current segment first (`null` =
  /// "All," either type is eligible). `null` means no eligible entry at
  /// all — hide the section.
  UserMediaEntry? becauseYouLikeSeed({
    required List<UserMediaEntry> libraryEntries,
    required MediaType? type,
  }) {
    final candidates = libraryEntries.where((e) {
      if (type != null && e.key.type != type) return false;
      return e.isFavorite || (e.rating != null && e.rating! >= 4);
    }).toList();

    if (candidates.isEmpty) return null;

    candidates.sort((a, b) {
      final byRating = _rankingRating(b).compareTo(_rankingRating(a));
      if (byRating != 0) return byRating;

      final aWatched = a.watchedAt;
      final bWatched = b.watchedAt;
      if (aWatched != bWatched) {
        if (aWatched == null) return 1;
        if (bWatched == null) return -1;
        final byWatchedAt = bWatched.compareTo(aWatched);
        if (byWatchedAt != 0) return byWatchedAt;
      }

      return b.key.tmdbId.compareTo(a.key.tmdbId);
    });

    return candidates.first;
  }

  int _rankingRating(UserMediaEntry entry) => entry.rating ?? 5;

  /// Drops anything from [candidates] that's already in [libraryKeys] —
  /// shared by both sections ("Para ti" excludes already-saved/-watched;
  /// "Porque te gusta" excludes anything already in the library), so
  /// this membership check lives in exactly one place. Order-preserving
  /// (`Iterable.where` never reorders), which is what "orden estable"
  /// means for this step: whatever order the repository call returned,
  /// minus the excluded ones, not a re-sort.
  List<MediaItem> excludeLibraryItems(
    List<MediaItem> candidates,
    Set<MediaKey> libraryKeys,
  ) {
    return candidates.where((item) => !libraryKeys.contains(item.key)).toList();
  }

  /// [excludeLibraryItems] plus dropping anything with no poster
  /// (`docs/DECISIONS.md` F1b: `/recommendations`' own doc-brief ask —
  /// applied to both sections, same reasoning as
  /// [minRecommendationCount]'s own doc comment) — then
  /// [minRecommendationCount]'s own cutoff. `null` = below the
  /// threshold, hide the section; never a thin, half-empty carousel.
  List<MediaItem>? filterAndThreshold(
    List<MediaItem> candidates,
    Set<MediaKey> libraryKeys,
  ) {
    final filtered = excludeLibraryItems(
      candidates.where((item) => item.posterUrl != null).toList(),
      libraryKeys,
    );
    return filtered.length < minRecommendationCount ? null : filtered;
  }
}
