import '../../domain/entities/media_detail.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/entities/media_type.dart';
import '../../domain/entities/person.dart';
import '../../domain/entities/season_summary.dart';
import '../../domain/entities/video.dart';
import '../../domain/entities/watch_providers.dart';
import 'dtos/tmdb_credits_dto.dart';
import 'dtos/tmdb_movie_detail_dto.dart';
import 'dtos/tmdb_season_detail_dto.dart';
import 'dtos/tmdb_tv_detail_dto.dart';
import 'dtos/tmdb_video_dto.dart';
import 'dtos/tmdb_watch_providers_dto.dart';
import 'tmdb_image_urls.dart';
import 'tmdb_mappers.dart';

/// D1/D2's own DTO → [MediaDetail] mapping — `tmdb_mappers.dart` covers
/// Discover's list-level items; this is the detail screens' own, much
/// richer, single-call response (`docs/DECISIONS.md` §2).
///
/// [region] is the user's own region (`TmdbMediaRepository`'s same
/// hardcoded `'ES'` default, passed in explicitly here rather than read
/// from config directly, so this stays a plain, easily unit-testable
/// function) — used to pick a single certification and a single
/// watch-providers region out of TMDB's own per-region lists/maps.
MovieDetail mediaDetailFromMovieDto(
  TmdbMovieDetailDto dto, {
  required TmdbImagesConfig imagesConfig,
  required String region,
}) {
  return MovieDetail(
    item: Movie(
      id: dto.id,
      title: dto.title,
      posterUrl: buildTmdbImageUrl(
        config: imagesConfig,
        kind: TmdbImageKind.poster,
        path: dto.posterPath,
        size: TmdbImageSizes.posterLarge, // D1's own full-bleed header.
      ),
      genres: genresFromTmdbIds(
        dto.genres.map((g) => g.id).toList(),
        MediaType.movie,
      ),
      releaseDate: parseTmdbDate(dto.releaseDate),
      voteAverage: dto.voteAverage,
    ),
    overview: dto.overview,
    cast: _castFrom(dto.credits.cast),
    crew: _crewFrom(dto.credits.crew),
    videos: _videosFrom(dto.videos.results),
    similar: dto.similar.results
        .map((m) => mediaItemFromMovieDto(m, imagesConfig: imagesConfig))
        .toList(),
    imdbId: dto.imdbId,
    tagline: _nullIfEmpty(dto.tagline),
    status: dto.status,
    watchProviders: _watchProvidersFrom(
      dto.watchProviders,
      region,
      imagesConfig,
    ),
    backdropUrl: _backdropUrl(dto.backdropPath, imagesConfig),
    runtimeMinutes: dto.runtime,
    releaseDate: parseTmdbDate(dto.releaseDate),
    certification: _certificationFromReleaseDates(dto.releaseDates, region),
  );
}

TvShowDetail mediaDetailFromTvDto(
  TmdbTvDetailDto dto, {
  required TmdbImagesConfig imagesConfig,
  required String region,
}) {
  return TvShowDetail(
    item: TvShow(
      id: dto.id,
      title: dto.name,
      posterUrl: buildTmdbImageUrl(
        config: imagesConfig,
        kind: TmdbImageKind.poster,
        path: dto.posterPath,
        size: TmdbImageSizes.posterLarge,
      ),
      genres: genresFromTmdbIds(
        dto.genres.map((g) => g.id).toList(),
        MediaType.tvShow,
      ),
      releaseDate: parseTmdbDate(dto.firstAirDate),
      voteAverage: dto.voteAverage,
    ),
    overview: dto.overview,
    cast: _castFrom(dto.credits.cast),
    crew: _crewFrom(dto.credits.crew),
    videos: _videosFrom(dto.videos.results),
    similar: dto.similar.results
        .map((t) => mediaItemFromTvDto(t, imagesConfig: imagesConfig))
        .toList(),
    imdbId: null, // TMDB's TV detail doesn't carry an imdb_id directly.
    tagline: null, // ...nor a tagline.
    status: dto.status,
    watchProviders: _watchProvidersFrom(
      dto.watchProviders,
      region,
      imagesConfig,
    ),
    backdropUrl: _backdropUrl(dto.backdropPath, imagesConfig),
    creators: dto.createdBy
        .map(
          (c) => Person(
            id: c.id,
            name: c.name,
            profilePath: c.profilePath,
            knownForDepartment: null,
          ),
        )
        .toList(),
    seasons: dto.seasons
        .map(
          (s) => SeasonSummary(
            seasonNumber: s.seasonNumber,
            name: s.name,
            episodeCount: s.episodeCount,
            posterPath: s.posterPath,
            airDate: parseTmdbDate(s.airDate),
          ),
        )
        .toList(),
    numberOfEpisodes: dto.numberOfEpisodes,
    episodeRuntimeMinutes: dto.episodeRunTime.isEmpty
        ? null
        : dto.episodeRunTime.first,
    firstAirDate: parseTmdbDate(dto.firstAirDate),
    lastAirDate: parseTmdbDate(dto.lastAirDate),
    inProduction: dto.inProduction,
    certification: _certificationFromContentRatings(dto.contentRatings, region),
  );
}

/// `/tv/{id}/season/{n}` → [SeasonDetail] — H4's own fetch
/// (`MediaRepository.season`), built on top of [episodesFromSeasonDetail].
SeasonDetail seasonDetailFromDto(TmdbSeasonDetailDto dto) {
  return SeasonDetail(
    seasonNumber: dto.seasonNumber,
    name: dto.name,
    overview: dto.overview,
    episodes: episodesFromSeasonDetail(dto),
  );
}

/// `/tv/{id}/season/{n}` → `Episode`s, fetched on demand (never part of
/// [mediaDetailFromTvDto]'s own, single `/tv/{id}` call).
List<Episode> episodesFromSeasonDetail(TmdbSeasonDetailDto dto) {
  return dto.episodes
      .map(
        (e) => Episode(
          episodeNumber: e.episodeNumber,
          name: e.name,
          overview: e.overview,
          stillPath: e.stillPath,
          airDate: parseTmdbDate(e.airDate),
          runtimeMinutes: e.runtime,
        ),
      )
      .toList();
}

List<CastMember> _castFrom(List<TmdbCastMemberDto> cast) {
  return cast
      .map(
        (c) => CastMember(
          person: Person(
            id: c.id,
            name: c.name,
            profilePath: c.profilePath,
            knownForDepartment: c.knownForDepartment,
          ),
          character: c.character,
          order: c.order,
        ),
      )
      .toList();
}

List<CrewMember> _crewFrom(List<TmdbCrewMemberDto> crew) {
  return crew
      .map(
        (c) => CrewMember(
          person: Person(
            id: c.id,
            name: c.name,
            profilePath: c.profilePath,
            knownForDepartment: c.knownForDepartment,
          ),
          job: c.job,
          department: c.department,
        ),
      )
      .toList();
}

List<Video> _videosFrom(List<TmdbVideoDto> videos) {
  return videos
      .map(
        (v) => Video(
          key: v.key,
          site: v.site,
          type: v.type,
          name: v.name,
          official: v.official,
          iso6391: v.iso6391,
        ),
      )
      .toList();
}

WatchProviders _watchProvidersFrom(
  TmdbWatchProvidersDto dto,
  String region,
  TmdbImagesConfig imagesConfig,
) {
  final forRegion = dto.results[region];
  if (forRegion == null) return WatchProviders.empty;

  // `w92` is in TMDB's poster-size list and is also one of its logo sizes,
  // so the poster list validates it — no separate logo-size config needed.
  final logos = <String, String>{
    for (final p in [
      ...forRegion.flatrate,
      ...forRegion.rent,
      ...forRegion.buy,
    ])
      p.providerName: ?buildTmdbImageUrl(
        config: imagesConfig,
        kind: TmdbImageKind.poster,
        path: p.logoPath,
        size: 'w92',
      ),
  };

  return WatchProviders(
    flatrate: forRegion.flatrate.map((p) => p.providerName).toList(),
    rent: forRegion.rent.map((p) => p.providerName).toList(),
    buy: forRegion.buy.map((p) => p.providerName).toList(),
    link: forRegion.link,
    logos: logos,
  );
}

/// The first non-empty certification TMDB reports for [region] — a
/// region can list more than one `release_dates` entry (re-releases,
/// different release types); the first with an actual value is good
/// enough, since D1 only ever shows one certification string.
String? _certificationFromReleaseDates(TmdbReleaseDatesDto dto, String region) {
  for (final r in dto.results) {
    if (r.iso31661 != region) continue;
    for (final entry in r.releaseDates) {
      if (entry.certification.isNotEmpty) return entry.certification;
    }
  }
  return null;
}

String? _certificationFromContentRatings(
  TmdbContentRatingsDto dto,
  String region,
) {
  for (final entry in dto.results) {
    if (entry.iso31661 == region && entry.rating.isNotEmpty) {
      return entry.rating;
    }
  }
  return null;
}

String? _nullIfEmpty(String? value) =>
    (value == null || value.isEmpty) ? null : value;

String? _backdropUrl(String? path, TmdbImagesConfig config) =>
    buildTmdbImageUrl(
      config: config,
      kind: TmdbImageKind.backdrop,
      path: path,
      size: TmdbImageSizes.backdropMedium,
    );
