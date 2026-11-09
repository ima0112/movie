import '../entities/discover_filter.dart';
import '../entities/media_detail.dart';
import '../entities/media_item.dart';
import '../entities/media_key.dart';
import '../entities/media_type.dart';
import '../entities/result.dart';
import '../entities/season_summary.dart';

/// One of Discover's named carousels.
///
/// Source of truth: `docs/SCREENS.md` B1 (Discover) — "All: Popular
/// this week · Watch later. Movies: In theaters · Trending · Top rated
/// · Upcoming. TV Shows: Airing now · Trending · Top rated · Popular."
/// "For you"/"Because you like X" are **not** here — unlike every
/// other entry, they need local signal (`TasteProfile`/
/// `UserLibraryRepository`) this repository has no access to, plus
/// their own independent loading/error/retry per section (CLAUDE.md
/// rule 9), which this enum's single-batch `getCarouselSection` loop
/// (`DiscoverCubit.loadDiscover`) can't give them. They're built by
/// `RecommendationBuilder` (`features/recommendations/domain/`) and
/// fetched via [MediaRepository.recommendationsFor]/`.discover`
/// directly from `RecommendationsCubit`, a separate Cubit from
/// `DiscoverCubit` entirely.
enum CarouselSection {
  /// "All" segment only.
  popularThisWeek,

  /// "All" segment only; the screen only shows this section once there
  /// are 3+ items in Watch later.
  watchLater,

  /// Movies only.
  inTheaters,

  /// Movies and TV shows (the query differs per [MediaType]).
  trending,

  /// Movies and TV shows (the query differs per [MediaType]).
  topRated,

  /// Movies only.
  upcoming,

  /// TV shows only.
  airingNow,

  /// TV shows only.
  popular,
}

/// Read access to the movie/TV catalog for Discover's hero and carousels.
///
/// Source of truth: `docs/STRUCTURE.md` (`core/domain/repositories/
/// media_repository.dart`) and `docs/SCREENS.md` B1 (Discover).
///
/// `domain` contract only, per the project's CLAUDE.md rule 2 — the only
/// place that actually talks to TMDB is
/// `data/repositories/media_repository_impl.dart`.
abstract interface class MediaRepository {
  /// The Discover hero: up to 8 curated cards. [type] picks the segment
  /// (`null` is the "All" segment's own curated mix — see SCREENS.md B1).
  Future<Result<List<MediaItem>>> getHeroItems({MediaType? type});

  /// One named Discover carousel. [type] picks the segment the same way
  /// as [getHeroItems].
  Future<Result<List<MediaItem>>> getCarouselSection(
    CarouselSection section, {
    MediaType? type,
  });

  /// B1's "Because you like X" (`RecommendationBuilder`'s own seed
  /// pick) — `/movie|tv/{id}/recommendations`, picked by [seed]'s own
  /// type. Collaborative-filtering based, which is a closer fit for
  /// "people who liked this also liked…" than `/similar` (genre/keyword
  /// based) — and cheaper than fetching [seed]'s full `detail()` just
  /// to read `MediaDetail.similar`.
  Future<Result<List<MediaItem>>> recommendationsFor(MediaKey seed);

  /// D1 (movie) / D2 (TV show) full detail for one catalog item.
  Future<Result<MediaDetail>> detail(MediaKey key);

  /// H4 (season sheet), fetched on demand once a D2 "Seasons" row is
  /// tapped — never bundled into [detail]'s own `TvShowDetail.seasons`
  /// (`docs/DECISIONS.md` §2: "seasons on demand via
  /// `/tv/{id}/season/{n}`").
  Future<Result<SeasonDetail>> season(int tvId, int seasonNumber);

  /// B2's typing-state `/search/multi` — matches on title.
  ///
  /// Movies/TV shows only for now, despite the name: full TMDB "multi"
  /// search also returns people (`docs/SCREENS.md` B2: "Row = thumbnail
  /// (circular for people), title, 'Year · Movie/TV Show' or
  /// 'Department · Person'"), which needs `Person` search wired up
  /// separately — a later branch's job. The method keeps the
  /// TMDB-matching name since that's what it'll fully become.
  Future<Result<List<MediaItem>>> searchMulti(String query);

  /// C1 (Filtered listing) / B2's genre-tile listing — `/discover/
  /// {movie|tv}` with [filter]'s criteria. `filter.type == null` means
  /// "All" (`docs/SCREENS.md` C1: "All = both interleaved").
  Future<Result<List<MediaItem>>> discover(DiscoverFilter filter);

  /// A2 step 0's own poster wall background — deliberately **not**
  /// `getCarouselSection(CarouselSection.popularThisWeek)`, which is
  /// shared with B1's own small "Popular this week" carousel and capped
  /// at 10 items for that context. The wall needs a much bigger, varied
  /// pool (at least 10 distinct posters per column, so a column's own
  /// visible tiles — and every other column's — never repeat a poster
  /// on screen at once), so this combines trending movies and trending
  /// TV shows for the week instead, deduplicated.
  Future<Result<List<MediaItem>>> getPosterWallItems();
}
