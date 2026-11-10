import '../entities/discover_filter.dart';
import '../entities/discover_page.dart';
import '../entities/media_detail.dart';
import '../entities/media_item.dart';
import '../entities/media_key.dart';
import '../entities/media_type.dart';
import '../entities/result.dart';
import '../entities/search_result.dart';
import '../entities/streaming_service.dart';
import '../entities/trailer_item.dart';
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

  /// "All" segment only — movies and shows releasing in the next 90 days.
  comingSoon,

  /// TV shows only — series that have ended, best rated first.
  finishedShows,
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
  ///
  /// [regionCode] (ISO 3166-1) overrides the user's saved region for this one
  /// read only — where-to-watch and the certification are per region. `null`
  /// means the saved region.
  Future<Result<MediaDetail>> detail(MediaKey key, {String? regionCode});

  /// H4 (season sheet), fetched on demand once a D2 "Seasons" row is
  /// tapped — never bundled into [detail]'s own `TvShowDetail.seasons`
  /// (`docs/DECISIONS.md` §2: "seasons on demand via
  /// `/tv/{id}/season/{n}`").
  Future<Result<SeasonDetail>> season(int tvId, int seasonNumber);

  /// B2's typing-state `/search/multi` — movies, TV shows **and people**, in
  /// TMDB's own ranked order (`docs/SCREENS.md` B2: "Row = thumbnail
  /// (circular for people), title, 'Year · Movie/TV Show' or
  /// 'Department · Person'"). A blank query is an empty success with no
  /// request.
  Future<Result<List<SearchResult>>> searchMulti(String query);

  /// C1 (Filtered listing) / B2's genre-tile listing — `/discover/
  /// {movie|tv}` with [filter]'s criteria. `filter.type == null` means
  /// "All" (`docs/SCREENS.md` C1: "All = both interleaved").
  Future<Result<List<MediaItem>>> discover(DiscoverFilter filter);

  /// One page of [discover]'s results, for a listing that loads as it
  /// scrolls (B1/B2's "See all"). Same filter semantics as [discover];
  /// `filter.type == null` interleaves both types, page by page. A [page]
  /// past the end is an empty page, not a failure.
  Future<Result<DiscoverPage>> discoverPage(
    DiscoverFilter filter, {
    int page = 1,
  });

  /// One page of a Discover collection's own endpoint (the list behind a B1
  /// carousel), so "See all" opens with exactly the order the carousel
  /// previewed. [type] is the segment (`null` = All).
  Future<Result<DiscoverPage>> carouselSectionPage(
    CarouselSection section, {
    MediaType? type,
    int page = 1,
  });

  /// B2's "Platform" pills: the streaming services available in the user's
  /// region (Settings), most relevant first, capped to a short list. [type]
  /// picks movies or TV shows; `null` (All) merges both without repeats.
  Future<Result<List<StreamingService>>> streamingServices({MediaType? type});

  /// B1's "Latest trailers": up to [limit] current and upcoming movies, each
  /// with its trailer (titles with no YouTube video are skipped). Needs one
  /// `/movie/{id}/videos` call per candidate — so it is only fetched when
  /// the section nears the viewport.
  Future<Result<List<TrailerItem>>> latestTrailers({int limit = 8});

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
