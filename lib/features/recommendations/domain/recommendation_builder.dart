import '../../../core/domain/entities/media_item.dart';
import '../../../core/domain/entities/media_key.dart';

/// The shared client-side finishing of B1's recommendation sections —
/// `docs/DECISIONS.md` F1b. What each section is *about* is decided by
/// `RecommendationPlanner`; this only cleans up what TMDB returned: drops
/// anything already in My List and anything without a poster, and hides a
/// section that ends up too thin. Pure domain: no Flutter, no network.
class RecommendationBuilder {
  const RecommendationBuilder();

  /// Below this many results (after excluding posterless items and
  /// anything already in the library), a section doesn't show at all —
  /// `docs/DECISIONS.md` F1b: a carousel with 2-3 items reads as broken,
  /// not curated. Applies to both sections (the design brief named it
  /// for "Because you like X" specifically, for `/recommendations`'
  /// thinner, title-dependent pool; it's applied the same way to "For
  /// you" for the same reason — a very short carousel looks the same
  /// regardless of which call produced it).
  static const int minRecommendationCount = 6;

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
