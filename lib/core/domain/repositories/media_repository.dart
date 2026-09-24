import '../entities/discover_filter.dart';
import '../entities/genre.dart';
import '../entities/media_detail.dart';
import '../entities/media_item.dart';
import '../entities/media_key.dart';
import '../entities/media_type.dart';
import '../entities/result.dart';

/// One of Discover's named carousels.
///
/// Source of truth: `docs/SCREENS.md` B1 (Discover) —
/// "All: For You · Popular this week · Because you like [genre] · Watch
/// later. Movies: In theaters · Trending · Top rated · Upcoming. TV Shows:
/// Airing now · Trending · Top rated · Popular."
enum CarouselSection {
  /// "All" segment only.
  forYou,

  /// "All" segment only.
  popularThisWeek,

  /// "All" segment only. Needs a genre — see
  /// [MediaRepository.getCarouselSection].
  becauseYouLike,

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
  /// as [getHeroItems]. [genre] is required when [section] is
  /// [CarouselSection.becauseYouLike] and ignored otherwise.
  Future<Result<List<MediaItem>>> getCarouselSection(
    CarouselSection section, {
    MediaType? type,
    Genre? genre,
  });

  /// D1 (movie) / D2 (TV show) full detail for one catalog item.
  Future<Result<MediaDetail>> detail(MediaKey key);

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
}
